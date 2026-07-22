import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../providers/stt_providers.dart';
import 'exercise_shared.dart';

/// Speaking task exercise — record yourself speaking Czech in response to
/// a prompt. The recording is transcribed and compared to expected phrases.
class SpeakingTaskView extends ConsumerStatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const SpeakingTaskView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  ConsumerState<SpeakingTaskView> createState() => _SpeakingTaskViewState();
}

class _SpeakingTaskViewState extends ConsumerState<SpeakingTaskView> {
  bool isRecording = false;
  bool hasRecorded = false;
  bool isProcessing = false;
  String? transcription;
  String? feedback;

  String get _prompt {
    return (widget.exercise.data['prompt_en'] ??
        widget.exercise.prompt) as String;
  }

  String? get _promptCz => widget.exercise.data['prompt_cz'] as String?;

  List<String> get _expectedPhrases {
    final raw = widget.exercise.data['expected_phrases'];
    if (raw is List) return raw.cast<String>();
    if (widget.exercise.answerKey != null) return [widget.exercise.answerKey!];
    return [];
  }

  Future<void> _toggleRecording() async {
    if (isProcessing) return;

    if (isRecording) {
      setState(() => isRecording = false);
      return;
    }

    setState(() {
      isRecording = true;
      hasRecorded = false;
      transcription = null;
      feedback = null;
    });

    try {
      final stt = ref.read(sttServiceProvider) as NativeSttService;
      final recorded = (await stt.listenFor(
        timeout: const Duration(seconds: 15),
      )).trim();
      var score = 0.0;

      // Compare against expected phrases
      for (final phrase in _expectedPhrases) {
        if (matchAnswer([phrase], recorded) != AnswerMatch.none) {
          score = 1.0;
          break;
        }
      }

      // Partial match: check if transcription contains key words
      if (score < 1.0 && recorded.isNotEmpty) {
        final words = recorded.toLowerCase().split(RegExp(r'\s+'));
        final expectedWords = _expectedPhrases
            .expand((p) => p.toLowerCase().split(RegExp(r'\s+')))
            .toSet();
        final matched = words.where((w) => expectedWords.contains(w)).length;
        if (expectedWords.isNotEmpty) {
          score = matched / expectedWords.length;
        }
        if (score > 1.0) score = 1.0;
      }

      setState(() {
        hasRecorded = true;
        isRecording = false;
        isProcessing = false;
        transcription = recorded;
        feedback = score >= 0.5
            ? 'Good! You said the right things.'
            : 'Try again. Expected phrases include: ${_expectedPhrases.join(", ")}';
      });

      // Auto-submit after a short delay so the user can see their result.
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onAnswered(
            ExerciseResult(
              isCorrect: score >= 0.5,
              explanation: feedback,
              correctAnswer: _expectedPhrases.join('; '),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        isRecording = false;
        isProcessing = false;
        feedback = 'Recording failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prompt
          Text(
            _prompt,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_promptCz != null) ...[
            const SizedBox(height: 4),
            Text(
              _promptCz!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Expected phrases hint
          if (_expectedPhrases.isNotEmpty) ...[
            Text(
              'Try to say:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            ..._expectedPhrases.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.record_voice_over, size: 16,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(p, style: const TextStyle(fontSize: 15)),
                ],
              ),
            )),
            const SizedBox(height: 20),
          ],

          // Record button
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? Colors.red.shade400
                          : theme.colorScheme.primary,
                      boxShadow: [
                        if (isRecording)
                          BoxShadow(
                            color: Colors.red.shade200.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isRecording
                      ? 'Recording... tap to stop'
                      : hasRecorded
                          ? 'Tap to re-record'
                          : 'Tap to speak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transcription & feedback
          if (transcription != null && transcription!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You said: "$transcription"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (feedback != null)
            Text(
              feedback!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: feedback!.contains('Good')
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
