import io
import math
import wave

import numpy as np
import torch
from fastapi import FastAPI, File, UploadFile
from pydantic import BaseModel
from transformers import (
    AutoFeatureExtractor,
    AutoModelForAudioClassification,
    AutoModelForCausalLM,
    AutoTokenizer,
)

app = FastAPI()

model_name = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
device = "cuda" if torch.cuda.is_available() else "cpu"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name).to(device)
model.eval()

baby_cry_model_name = "Wiam/baby-cry-classification-finetuned-babycry-v4"
baby_cry_processor = None
baby_cry_model = None


class ChatRequest(BaseModel):
    message: str


@app.get("/")
def root():
    return {
        "status": "TinyLlama medical chatbot server is running",
        "device": device,
    }


@app.post("/chat")
def chat(req: ChatRequest):
    user_message = req.message.strip()

    if not user_message:
        return {"reply": "Please write a question."}

    prompt = (
        "<|system|>\n"
        "You are a helpful medical assistant. "
        "Explain clearly and simply. "
        "Do not diagnose. "
        "For serious symptoms, advise seeing a doctor.\n"
        "<|user|>\n"
        f"{user_message}\n"
        "<|assistant|>\n"
    )

    inputs = tokenizer(prompt, return_tensors="pt").to(device)

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=80,
            do_sample=False,
            repetition_penalty=1.05,
            no_repeat_ngram_size=3,
            pad_token_id=tokenizer.eos_token_id,
        )

    full_text = tokenizer.decode(outputs[0], skip_special_tokens=True)

    if "<|assistant|>" in full_text:
        reply = full_text.split("<|assistant|>")[-1].strip()
    else:
        reply = full_text.replace(prompt, "").strip()

    if not reply:
        reply = "Sorry, I could not generate a clear answer."

    return {"reply": reply}


@app.post("/baby-cry/analyze")
async def analyze_baby_cry(file: UploadFile = File(...)):
    audio_bytes = await file.read()

    if not audio_bytes:
        return {"error": "No audio file was uploaded."}

    features = _extract_audio_features(audio_bytes)
    model_result = _classify_with_baby_cry_model(audio_bytes, file.filename)

    if model_result is None:
        label, score, predictions = _classify_baby_cry_from_features(features)
        source = "signal-fallback"
        model_used = "audio-feature fallback"
    else:
        label = model_result["label"]
        score = model_result["score"]
        predictions = model_result["predictions"]
        source = "huggingface-model"
        model_used = baby_cry_model_name

    return {
        "label": label,
        "score": score,
        "predictions": predictions,
        "source": source,
        "model": model_used,
        "debug": features,
    }


def _extract_audio_features(audio_bytes: bytes):
    try:
        with wave.open(io.BytesIO(audio_bytes), "rb") as wav_file:
            sample_width = wav_file.getsampwidth()
            frame_count = wav_file.getnframes()
            sample_rate = wav_file.getframerate()
            frames = wav_file.readframes(frame_count)
    except wave.Error:
        frames = audio_bytes
        sample_width = 1
        sample_rate = 16000

    if sample_width <= 0:
        sample_width = 1

    samples = []
    max_value = float(2 ** (8 * sample_width - 1))

    for index in range(0, len(frames) - sample_width + 1, sample_width):
        chunk = frames[index:index + sample_width]
        value = int.from_bytes(chunk, byteorder="little", signed=sample_width > 1)
        samples.append(value / max_value)

    if not samples:
        return {"energy": 0.0, "variation": 0.0, "peak": 0.0, "duration": 0.0}

    abs_samples = [abs(sample) for sample in samples]
    energy = sum(abs_samples) / len(samples)
    peak = max(abs(sample) for sample in samples)
    mean = sum(samples) / len(samples)
    variation = math.sqrt(
        sum((sample - mean) ** 2 for sample in samples) / len(samples)
    )
    duration = len(samples) / sample_rate if sample_rate else 0.0
    zero_crossings = sum(
        1
        for previous, current in zip(samples, samples[1:])
        if (previous < 0 <= current) or (previous > 0 >= current)
    )
    zero_crossing_rate = zero_crossings / max(1, len(samples) - 1)
    loud_ratio = sum(1 for sample in abs_samples if sample > 0.08) / len(samples)

    if energy < 0.004 and peak < 0.025:
        sound_level = "mostly silence"
    elif energy < 0.02 and peak < 0.10:
        sound_level = "very quiet"
    elif energy < 0.08:
        sound_level = "moderate"
    else:
        sound_level = "loud"

    return {
        "durationSeconds": round(duration, 2),
        "sampleRate": sample_rate,
        "averageAmplitude": round(energy, 5),
        "rms": round(variation, 5),
        "peakAmplitude": round(peak, 5),
        "zeroCrossingRate": round(zero_crossing_rate, 5),
        "loudRatio": round(loud_ratio, 5),
        "soundLevel": sound_level,
    }


def _classify_with_baby_cry_model(audio_bytes: bytes, filename: str | None):
    global baby_cry_processor, baby_cry_model

    try:
        samples, sample_rate = _read_wav_samples(audio_bytes)

        if baby_cry_processor is None or baby_cry_model is None:
            baby_cry_processor = AutoFeatureExtractor.from_pretrained(
                baby_cry_model_name
            )
            baby_cry_model = AutoModelForAudioClassification.from_pretrained(
                baby_cry_model_name
            ).to(device)
            baby_cry_model.eval()

        target_rate = getattr(
            baby_cry_processor, "sampling_rate", sample_rate
        )
        audio = _resample(samples, sample_rate, target_rate)
        inputs = baby_cry_processor(
            audio,
            sampling_rate=target_rate,
            return_tensors="pt",
        )
        inputs = {key: value.to(device) for key, value in inputs.items()}

        with torch.no_grad():
            logits = baby_cry_model(**inputs).logits[0]
            scores = torch.softmax(logits, dim=-1).detach().cpu().tolist()
    except Exception:
        return None

    id_to_label = baby_cry_model.config.id2label
    predictions = [
        {
            "label": id_to_label.get(index, str(index)).replace("_", " ").title(),
            "score": round(float(score), 4),
        }
        for index, score in enumerate(scores)
    ]
    predictions.sort(key=lambda item: item["score"], reverse=True)

    if not predictions:
        return None

    best = predictions[0]
    return {
        "label": best["label"],
        "score": best["score"],
        "predictions": predictions,
    }


def _read_wav_samples(audio_bytes: bytes):
    with wave.open(io.BytesIO(audio_bytes), "rb") as wav_file:
        sample_width = wav_file.getsampwidth()
        frame_count = wav_file.getnframes()
        sample_rate = wav_file.getframerate()
        frames = wav_file.readframes(frame_count)

    if sample_width != 2:
        raise ValueError("Only 16-bit WAV audio is supported by the model path.")

    samples = np.frombuffer(frames, dtype="<i2").astype(np.float32) / 32768.0
    return samples, sample_rate


def _resample(samples, source_rate, target_rate):
    if source_rate == target_rate or len(samples) == 0:
        return samples

    duration = len(samples) / source_rate
    source_times = np.linspace(0, duration, num=len(samples), endpoint=False)
    target_count = max(1, int(duration * target_rate))
    target_times = np.linspace(0, duration, num=target_count, endpoint=False)
    return np.interp(target_times, source_times, samples).astype(np.float32)


def _classify_baby_cry_from_features(features):
    energy = features["averageAmplitude"]
    variation = features["rms"]
    peak = features["peakAmplitude"]
    duration = features["durationSeconds"]
    zero_crossing_rate = features["zeroCrossingRate"]
    loud_ratio = features["loudRatio"]

    if features["soundLevel"] == "mostly silence":
        predictions = [
            {"label": "No clear cry detected", "score": 0.88},
            {"label": "Tired", "score": 0.08},
            {"label": "Discomfort", "score": 0.04},
        ]
        return predictions[0]["label"], predictions[0]["score"], predictions

    hungry = min(0.95, 0.24 + energy * 2.4 + loud_ratio * 0.35 + duration * 0.01)
    tired = min(0.92, 0.22 + max(0.0, 0.12 - variation) * 2.3)
    discomfort = min(
        0.94,
        0.20 + peak * 0.60 + variation * 1.4 + zero_crossing_rate * 0.75,
    )
    burping = min(0.90, 0.18 + zero_crossing_rate * 1.1 + loud_ratio * 0.2)

    predictions = [
        {"label": "Hungry", "score": round(hungry, 3)},
        {"label": "Tired", "score": round(tired, 3)},
        {"label": "Discomfort", "score": round(discomfort, 3)},
        {"label": "Burping", "score": round(burping, 3)},
    ]
    predictions.sort(key=lambda item: item["score"], reverse=True)

    best = predictions[0]
    return best["label"], best["score"], predictions
