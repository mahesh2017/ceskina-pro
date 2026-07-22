import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import 'exercise_shared.dart';

/// Writing task exercise — write a short text in Czech based on a prompt.
/// For automated checking, accepted_answers provides keyword/phrase matches;
/// otherwise the exercise is self-assessed or evaluated by the LLM.
class WritingTaskView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const WritingTaskView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<WritingTaskView> createState() => _WritingTaskViewState();
}

class _WritingTaskViewState extends State<WritingTaskView> {
  final _controller = TextEditingController();
  bool answered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _prompt {
    return (widget.exercise.data['prompt_en'] ??
        widget.exercise.prompt) as String;
  }

  String? get _promptCz => widget.exercise.data['prompt_cz'] as String?;

  List<String>? get _keyVocab {
    final raw = widget.exercise.data['key_vocab'];
    if (raw is List) return raw.cast<String>();
    return null;
  }

  int? get _minWords => widget.exercise.data['min_words'] as int?;

  void _submit() {
    final text = _controller.text.trim();
    final acceptedAnswers = widget.exercise.answerKey != null
        ? [widget.exercise.answerKey!]
        : <String>[];

    // Simple keyword-based checking
    final wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    final meetsMinWords = _minWords == null || wordCount >= _minWords!;
    final hasContent = text.isNotEmpty;

    setState(() => answered = true);

    widget.onAnswered(
      ExerciseResult(
        isCorrect: hasContent && meetsMinWords,
        explanation: acceptedAnswers.isNotEmpty
            ? 'Suggested answer: ${acceptedAnswers.first}'
            : 'You wrote $wordCount words. ${meetsMinWords ? "✓" : "Write at least $_minWords words for full credit."}',
        correctAnswer: acceptedAnswers.isNotEmpty
            ? acceptedAnswers.first
            : null,
      ),
    );
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
              ),
            ),
          ],
          if (_minWords != null) ...[
            const SizedBox(height: 8),
            Text(
              'Write at least $_minWords words.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Key vocab hint
          if (_keyVocab != null && _keyVocab!.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Try using: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _keyVocab!.map((v) => Chip(
                      label: Text(v, style: const TextStyle(fontSize: 13)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Writing area
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !answered,
              decoration: const InputDecoration(
                hintText: 'Write your answer in Czech...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(height: 8),
          if (!answered) CzechCharBar(controller: _controller),

          // Submit
          if (!answered)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ),

          // Word count
          if (!answered)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_controller.text.trim().isEmpty ? 0 : _controller.text.trim().split(RegExp(r'\s+')).length} words',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
