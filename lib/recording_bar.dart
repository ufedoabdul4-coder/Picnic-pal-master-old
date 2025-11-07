import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';

class RecordingBar extends StatefulWidget {
  final bool isVisible;
  final Function(String) onConfirm;
  final VoidCallback onCancel;

  const RecordingBar({
    super.key,
    required this.isVisible,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<RecordingBar> {
  late final RecorderController _recorderController;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController();
  }

  @override
  void didUpdateWidget(covariant RecordingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _audioPath = '${tempDir.path}/recording.wav';

    // Start audio recording using the waveform controller.
    await _recorderController.record(path: _audioPath!);
    setState(() {}); // Update UI to show waveform
  }

  Future<void> _stopRecordingAndConfirm() async {
    await _stopAll();
    widget.onConfirm(_audioPath ?? '');
  }

  Future<void> _stopRecordingAndCancel() async {
    await _stopAll();
    widget.onCancel();
  }

  Future<void> _stopAll() async {
    await _recorderController.stop();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: widget.isVisible ? Offset.zero : const Offset(0, 1),
      child: Material(
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Waveform
                AudioWaveforms(
                  size: const Size(80, 40),
                  recorderController: _recorderController,
                  waveStyle: WaveStyle(
                    waveColor: theme.colorScheme.primary,
                    showDurationLabel: false,
                    spacing: 4.0,
                    waveThickness: 2.0,
                  ),
                ),
                const SizedBox(width: 16),
                // Transcription Text
                Expanded(
                  child: Text(
                    "Listening...",
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                // Action Buttons
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 28),
                  onPressed: _stopRecordingAndCancel,
                ),
                IconButton(
                  icon: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 28),
                  onPressed: _stopRecordingAndConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}