import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:developer' as developer;

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
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  bool _isRecordingActive = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void didUpdateWidget(covariant RecordingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        developer.log("Microphone permission not granted");
        widget.onCancel(); // Cancel if no permission
        return;
      }

      final tempDir = await getTemporaryDirectory();
      _audioPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      developer.log("Starting recording to: $_audioPath");

     const config = RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1);

      await _audioRecorder.start(config, path: _audioPath!);

      if (mounted) {
        setState(() {
          _isRecordingActive = true;
        });
      }
      developer.log("Recording started successfully");
    } catch (e) {
      developer.log("Error starting recording: $e");
      _isRecordingActive = false;
    }
  }

  Future<void> _stopRecordingAndConfirm() async {
    if (!_isRecordingActive) {
      developer.log("Recording not active, ignoring confirm");
      return;
    }
    
    await _stopRecording();
    
    if (_audioPath != null) {
      final file = File(_audioPath!);
      final exists = await file.exists();
      final fileSize = exists ? await file.length() : 0;
      
      developer.log("Audio file check - Path: $_audioPath, Exists: $exists, Size: $fileSize bytes");
      
      if (exists && fileSize > 0) {
        developer.log("Audio file is valid, sending to transcription");
        widget.onConfirm(_audioPath!);
      } else {
        developer.log("Audio file is empty or doesn't exist");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recording failed. Please try again.")),
          );
        }
      }
    }
  }

  Future<void> _stopRecordingAndCancel() async {
    if (!_isRecordingActive) {
      developer.log("Recording not active, ignoring cancel");
      return;
    }
    
    await _stopRecording();
    
    // Clean up the audio file if cancel is pressed
    if (_audioPath != null) {
      final file = File(_audioPath!);
      try {
        if (await file.exists()) {
          await file.delete();
          developer.log("Cancelled recording deleted: $_audioPath");
        }
      } catch (e) {
        developer.log("Error deleting audio file: $e");
      }
    }
    
    widget.onCancel();
  }

  Future<void> _stopRecording() async {
    try {
      developer.log("Stopping recording...");
      await _audioRecorder.stop();
      developer.log("Recording stopped successfully.");
    } catch (e) {
      developer.log("Error stopping recording: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isRecordingActive = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
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
                // Recording Icon
                Icon(Icons.mic, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                // Transcription text / status
                Expanded(
                  child: Text(
                    "Listening...",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                // Cancel button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 28),
                  onPressed: _stopRecordingAndCancel,
                ),
                // Confirm button
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
