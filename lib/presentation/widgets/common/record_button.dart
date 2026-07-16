import 'package:flutter/material.dart';

/// Record button — hold to record audio.
class RecordButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isRecording;

  const RecordButton({
    super.key,
    required this.onPressed,
    this.isRecording = false,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onPressed(),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isRecording
              ? Colors.red.shade400
              : Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          widget.isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}