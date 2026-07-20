import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import 'exercise_shared.dart';

/// Dialogue completion exercise view.
class DialogueView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const DialogueView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<DialogueView> createState() => _DialogueViewState();
}

class _DialogueViewState extends State<DialogueView> {
  final Map<int, TextEditingController> _controllers = {};
  bool answered = false;
  bool? isCorrect;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Get or create a controller for a given blank index.
  TextEditingController _controllerFor(int blankIdx) {
    return _controllers.putIfAbsent(blankIdx, () => TextEditingController());
  }

  /// Build dialogue line widgets, assigning a unique controller per blank.
  List<Widget> _buildDialogueLines(
    List<Map<String, dynamic>> lines,
    BuildContext context,
  ) {
    int blankCounter = 0;
    return lines.map((line) {
      final isUser = line['speaker'] == 'you';
      final text = line['text'] as String;
      final containsBlank = text.contains('___');

      if (containsBlank) {
        final blankIdx = blankCounter++;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllerFor(blankIdx),
                  enabled: !answered,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Your answer',
                  ),
                  onSubmitted: answered ? null : (_) => _checkAnswer(),
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line['speaker'] as String,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(text),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final acceptedRaw = data['accepted_answers'] as List<dynamic>;

    // Collect answers from all controllers in order.
    final blankIndices = _controllers.keys.toList()..sort();
    final userParts =
        blankIndices
            .map((idx) => normalizeAnswer(_controllers[idx]!.text))
            .toList();

    // Multi-blank accepted answers use | separators.
    final correct = acceptedRaw.cast<String>().any((a) {
      final parts = a.split('|').map(normalizeAnswer).toList();
      if (parts.length != userParts.length) return false;
      for (var i = 0; i < parts.length; i++) {
        if (parts[i] != userParts[i]) return false;
      }
      return true;
    });

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    widget.onAnswered(
      ExerciseResult(
        isCorrect: correct,
        explanation: data['explanation'] as String?,
        correctAnswer: acceptedRaw.first as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final lines = (data['lines'] as List<dynamic>).cast<Map<String, dynamic>>();
    final scenario = data['scenario'] as String?;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (scenario != null)
            Text(
              'Scenario: $scenario',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 16),

          // Dialogue lines
          ..._buildDialogueLines(lines, context),

          const SizedBox(height: 16),
          if (!answered)
            FilledButton(onPressed: _checkAnswer, child: const Text('Check')),
        ],
      ),
    );
  }
}