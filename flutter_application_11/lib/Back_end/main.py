import torch
from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer

app = FastAPI()

model_name = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
device = "cuda" if torch.cuda.is_available() else "cpu"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name).to(device)
model.eval()


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