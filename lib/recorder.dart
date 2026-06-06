import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'app_theme.dart';
import 'baby_cry_service.dart';

class RecorderPage extends StatefulWidget {
  static const String routeName = '/baby-cry-ai';

  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  static const int _recordingDurationSeconds = 8;

  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool _analyzing = false;
  int _seconds = 0;
  Timer? _timer;
  String _result = 'Press the microphone to start recording.';
  BabyCryResult? _analysis;

  Future<({AudioEncoder encoder, String extension})?> _chooseEncoder() async {
    if (await _recorder.isEncoderSupported(AudioEncoder.wav)) {
      return (encoder: AudioEncoder.wav, extension: 'wav');
    }

    if (await _recorder.isEncoderSupported(AudioEncoder.aacLc)) {
      return (encoder: AudioEncoder.aacLc, extension: 'm4a');
    }

    return null;
  }

  Future<void> _startRecording() async {
    if (_analyzing) return;

    try {
      final hasPermission = await _recorder.hasPermission();

      if (!hasPermission) {
        setState(() {
          _result = 'Microphone permission is needed to analyze baby sounds.';
        });
        return;
      }

      final encoder = await _chooseEncoder();

      if (encoder == null) {
        setState(() {
          _result = 'Audio recording is not supported on this device.';
        });
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/baby_cry_${DateTime.now().millisecondsSinceEpoch}.${encoder.extension}';

      await _recorder.start(
        RecordConfig(
          encoder: encoder.encoder,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );

      _timer?.cancel();
      setState(() {
        _recording = true;
        _analyzing = false;
        _analysis = null;
        _seconds = 0;
        _result = 'Listening...';
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);

        if (_seconds >= _recordingDurationSeconds && _recording) {
          _stopRecording();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _analyzing = false;
        _result = 'Could not start recording. Check microphone permission.';
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    setState(() {
      _recording = false;
      _analyzing = true;
      _result = 'Analyzing baby sound...';
    });

    try {
      final filePath = await _recorder.stop();

      if (filePath == null || filePath.isEmpty) {
        throw Exception('No audio file was recorded.');
      }

      final analysis = await BabyCryService.analyzeAudio(filePath);

      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _analysis = analysis;
        _result = analysis.displayText;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().contains('TimeoutException')
          ? 'Analysis timed out. Start the backend first, then try again.'
          : 'Could not analyze the recording. Make sure the backend server is running.';

      setState(() {
        _analyzing = false;
        _analysis = null;
        _result = message;
      });
    }
  }

  Future<void> _handleRecordButtonPressed() async {
    if (_analyzing || _recording) return;

    await _startRecording();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$sec';
  }

  Widget _waveBar(double height) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heights = _recording
        ? <double>[28, 52, 36, 60, 42, 54, 26]
        : <double>[20, 24, 18, 22, 20, 24, 18];

    return Scaffold(
      appBar: AppBar(title: const Text('Baby Cry AI')),
      body: AppShell(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              children: [
                AppCard(
                  child: Column(
                    children: [
                      Text(
                        _formatTime(_seconds),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: heights
                            .map(
                              (height) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _waveBar(height),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 26),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: _recording ? 118 : 96,
                        height: _recording ? 118 : 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _recording ? Colors.red : AppColors.accent,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              color: (_recording ? Colors.red : AppColors.accent)
                                  .withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed:
                              (_analyzing || _recording)
                                  ? null
                                  : _handleRecordButtonPressed,
                          icon: Icon(
                            _recording
                                ? Icons.stop_rounded
                                : _analyzing
                                    ? Icons.hourglass_top_rounded
                                    : Icons.mic_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _recording
                            ? 'Recording... stops at 8 seconds'
                            : _analyzing
                                ? 'Analyzing...'
                                : 'Tap to record',
                        style: TextStyle(
                          color: _recording ? Colors.red : AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analysis',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(_result),
                      if (_analysis != null) ...[
                        const SizedBox(height: 14),
                        _ScoreBreakdown(analysis: _analysis!),
                        const SizedBox(height: 14),
                        _AudioDebug(analysis: _analysis!),
                        const SizedBox(height: 12),
                        const Text(
                          'Result generated by the backend baby cry analyzer.',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final BabyCryResult analysis;

  const _ScoreBreakdown({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final predictions = analysis.predictions.take(4).toList();

    if (predictions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Scores',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        ...predictions.map(
          (prediction) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 112,
                  child: Text(
                    prediction.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: prediction.score.clamp(0, 1).toDouble(),
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(999),
                    color: AppColors.accent,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.14),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(prediction.score * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AudioDebug extends StatelessWidget {
  final BabyCryResult analysis;

  const _AudioDebug({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final debug = analysis.debug;
    final soundLevel = debug['soundLevel']?.toString() ?? 'unknown';
    final duration = debug['durationSeconds']?.toString() ?? '-';
    final average = debug['averageAmplitude']?.toString() ?? '-';
    final peak = debug['peakAmplitude']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Debug',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text('Sound level: $soundLevel'),
          Text('Duration: ${duration}s'),
          Text('Average amplitude: $average'),
          Text('Peak amplitude: $peak'),
          Text('Analyzer: ${analysis.source}'),
        ],
      ),
    );
  }
}
