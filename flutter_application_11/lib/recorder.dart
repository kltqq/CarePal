import 'dart:async';

import 'package:flutter/material.dart';

import 'alerts_service.dart';
import 'app_theme.dart';
import 'fake_ai_service.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  bool _recording = false;
  bool _analyzed = false;
  int _seconds = 0;
  Timer? _timer;
  String _result = 'Press the microphone to start recording.';

  void _startRecording() {
    _timer?.cancel();
    setState(() {
      _recording = true;
      _analyzed = false;
      _seconds = 0;
      _result = 'Listening...';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final analysis = FakeAIService.analyzeBabyCry();
    await AlertsService.addAlert('New baby sound analysis saved.');

    if (!mounted) return;
    setState(() {
      _recording = false;
      _analyzed = true;
      _result = analysis;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heights = _recording
        ? <double>[28, 52, 36, 60, 42, 54, 26]
        : <double>[20, 24, 18, 22, 20, 24, 18];

    return Scaffold(
      appBar: AppBar(title: const Text('Baby Sound Recorder')),
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
                                  .withOpacity(0.35),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _recording ? _stopRecording : _startRecording,
                          icon: Icon(
                            _recording ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _recording ? 'Recording...' : 'Tap to record',
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
                      if (_analyzed) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Note: This is a frontend demo result only.',
                          style: TextStyle(color: Colors.orange),
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
