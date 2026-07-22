import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/score_colors.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../providers/pronunciation_providers.dart';
import 'exercise_shared.dart';

/// Pronunciation exercise view: record and get feedback.
///
/// Uses the [pronunciationAssessmentProvider] which tries Whisper first
/// (high-quality Czech transcription with word-level confidence) and falls
/// back to OS-native STT when unavailable.
class PronunciationView extends ConsumerStatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const PronunciationView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  ConsumerState<PronunciationView> createState() => _PronunciationViewState();
}

class _PronunciationViewState extends ConsumerState<PronunciationView> {
  double? score;
  String? feedback;
  bool hasRecorded = false;

  Future<void> _toggleRecording() async {
    if (ref.read(pronunciationProvider).isProcessing) return;

    final notifier = ref.read(pronunciationProvider.notifier);
    final currentState = ref.read(pronunciationProvider);

    if (currentState.isRecording) {
      await notifier.stopRecording();
      return;
    }

    // Reset state
    setState(() {
      score = null;
      feedback = null;
      hasRecorded = false;
    });

    await notifier.startRecording();
  }

  void _submitResult() {
    final data = widget.exercise.data;
    final minScore = (data['min_score'] as num?)?.toDouble() ?? 0.65;
    final passed = (score ?? 0) >= minScore;

    widget.onAnswered(
      ExerciseResult(
        isCorrect: passed,
        explanation: data['note'] as String? ??
            (passed
                ? 'Good pronunciation!'
                : 'Try again — focus on the highlighted sounds.'),
        correctAnswer: data['target_text'] as String?,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final targetText = data['target_text'] as String;
    final translation = data['translation_en'] as String?;
    final focusSounds = (data['focus_sounds'] as List<dynamic>?) ?? [];

    final pronState = ref.watch(pronunciationProvider);
    final isRecording = pronState.isRecording;
    final isProcessing = pronState.isProcessing;
    final result = pronState.result;

    // Update local score/feedback when result arrives
    if (result != null && score == null) {
      score = result.overallScore;
      feedback = result.feedback;
      hasRecorded = true;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.exercise.prompt,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Target text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    targetText,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (translation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      translation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // TTS button to hear correct pronunciation
                  TtsButton(text: targetText, size: 20),
                ],
              ),
            ),
          ),

          // Focus sounds chips
          if (focusSounds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text('Focus: ', style: Theme.of(context).textTheme.bodySmall),
                ...focusSounds.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Chip(
                      label: Text(s as String),
                      padding: EdgeInsets.zero,
                      labelStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Record button
          GestureDetector(
            onTap: isProcessing ? null : _toggleRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording
                    ? Colors.red.shade400
                    : Theme.of(context).colorScheme.primary,
              ),
              child: isProcessing
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? 'Listening... tap to stop'
                : isProcessing
                    ? 'Analyzing...'
                    : hasRecorded
                        ? 'Recorded! Tap to try again'
                        : 'Tap to record',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          // Engine indicator
          if (pronState.usedWhisper && hasRecorded) ...[
            const SizedBox(height: 4),
            Text(
              '✓ Whisper AI',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Escape hatch: pronunciation should never hard-block progress.
          if (!isProcessing)
            TextButton(
              onPressed: () => widget.onAnswered(
                ExerciseResult(
                  isCorrect: true,
                  explanation: 'Skipped — keep practising this one aloud with '
                      'the 🔊 button.',
                  correctAnswer: targetText,
                ),
              ),
              child: Text(
                hasRecorded && (score ?? 0) == 0
                    ? 'Mic not working? Skip'
                    : "Can't record right now? Skip",
              ),
            ),

          // Score display
          if (hasRecorded && score != null) ...[
            const SizedBox(height: 24),
            ScoreDisplay(score: score!),
            if (feedback != null) ...[
              const SizedBox(height: 8),
              Text(
                feedback!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitResult,
              child: const Text('Continue'),
            ),
          ],
        ],
      ),
    );
  }
}

class ScoreDisplay extends StatelessWidget {
  final double score;

  const ScoreDisplay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).round();
    final color = ScoreColors.of(score);

    return Column(
      children: [
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        LinearProgressIndicator(
          value: score,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          ScoreColors.label(score),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}