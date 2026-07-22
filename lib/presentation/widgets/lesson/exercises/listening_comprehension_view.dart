import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import 'exercise_shared.dart';

/// Listening comprehension exercise — listen to a Czech dialogue/recording,
/// then answer multiple-choice questions.
///
/// Until audio files are generated, the transcript is shown as a fallback
/// with a TTS button to read it aloud.
class ListeningComprehensionView extends StatelessWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const ListeningComprehensionView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final data = exercise.data;
    final transcriptCz = data['transcript_cz'] as String? ?? '';
    final promptEn = data['prompt_en'] as String? ?? exercise.prompt;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prompt
          Text(
            promptEn,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Audio note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Audio recording coming soon. '
                    'Read the transcript below, or tap the speaker to hear it read aloud.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
                if (transcriptCz.isNotEmpty)
                  TtsButton(text: transcriptCz, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Transcript (collapsible?)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.record_voice_over, size: 18,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Transcript',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          transcriptCz,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Questions — reuse the same layout as reading comprehension
                  // by extracting the question rendering into a shared widget.
                  // For now, build inline.
                  _ListeningQuestions(
                    data: data,
                    onComplete: (isCorrect, explanation, correctAnswer) {
                      onAnswered(
                        ExerciseResult(
                          isCorrect: isCorrect,
                          explanation: explanation,
                          correctAnswer: correctAnswer,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Questions section extracted from reading comprehension logic.
class _ListeningQuestions extends StatefulWidget {
  final Map<String, dynamic> data;
  final void Function(bool isCorrect, String? explanation, String? correctAnswer) onComplete;

  const _ListeningQuestions({
    required this.data,
    required this.onComplete,
  });

  @override
  State<_ListeningQuestions> createState() => _ListeningQuestionsState();
}

class _ListeningQuestionsState extends State<_ListeningQuestions> {
  final List<int?> _selectedAnswers = [];
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    final questions = widget.data['questions'] as List<dynamic>? ?? [];
    _selectedAnswers.addAll(List.filled(questions.length, null));
  }

  List<Map<String, dynamic>> get _questions {
    final raw = widget.data['questions'] as List<dynamic>? ?? [];
    return raw.cast<Map<String, dynamic>>();
  }

  bool get _allAnswered => _selectedAnswers.every((a) => a != null);

  int get _correctCount {
    int c = 0;
    for (int i = 0; i < _questions.length; i++) {
      final correctIdx = (_questions[i]['correct_index'] as num).toInt();
      if (_selectedAnswers[i] == correctIdx) c++;
    }
    return c;
  }

  bool get _allCorrect => _correctCount == _questions.length;

  void _submit() {
    setState(() => submitted = true);
    widget.onComplete(
      _allCorrect,
      _allCorrect
          ? 'All questions answered correctly!'
          : '$_correctCount/${_questions.length} correct.',
      _questions
          .map((q) => (q['options'] as List<dynamic>)[
                (q['correct_index'] as num).toInt()]
              as String)
          .join(', '),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int qIdx = 0; qIdx < _questions.length; qIdx++) ...[
          _buildQuestion(qIdx, theme),
          const SizedBox(height: 12),
        ],
        if (_allAnswered && !submitted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Check Answers'),
            ),
          ),
        if (submitted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  _allCorrect ? Icons.check_circle : Icons.error_outline,
                  color: _allCorrect ? Colors.green.shade600 : Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _allCorrect ? 'All correct!' : '$_correctCount/${_questions.length} correct',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _allCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuestion(int qIdx, ThemeData theme) {
    final q = _questions[qIdx];
    final questionEn = q['question_en'] as String? ?? '';
    final options = (q['options'] as List<dynamic>).cast<String>();
    final correctIdx = (q['correct_index'] as num).toInt();
    final selected = _selectedAnswers[qIdx];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${qIdx + 1}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary, fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(questionEn,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          for (int i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: GestureDetector(
                onTap: submitted ? null : () => setState(() => _selectedAnswers[qIdx] = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: submitted
                        ? (i == correctIdx
                            ? Colors.green.shade50
                            : selected == i
                                ? Colors.red.shade50
                                : Colors.grey.shade50)
                        : (selected == i
                            ? theme.colorScheme.primaryContainer
                            : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: submitted
                          ? (i == correctIdx
                              ? Colors.green.shade500
                              : selected == i
                                  ? Colors.red.shade500
                                  : Colors.grey.shade300)
                          : (selected == i
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300),
                      width: (selected == i || submitted) ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(options[i], style: const TextStyle(fontSize: 15))),
                      if (submitted && i == correctIdx)
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                      if (submitted && selected == i && i != correctIdx)
                        Icon(Icons.cancel, color: Colors.red.shade600, size: 18),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
