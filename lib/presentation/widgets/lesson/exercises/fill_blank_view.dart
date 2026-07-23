import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import 'exercise_shared.dart';

/// Fill-in-the-blank exercise view.
class FillBlankView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const FillBlankView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  State<FillBlankView> createState() => _FillBlankViewState();
}

class _FillBlankViewState extends State<FillBlankView> {
  // Blanks are written as runs of underscores. Length varies across the
  // content (a single "_" for one missing letter, "___"/"_____" for words),
  // so match one-or-more. Underscores only ever appear as blanks in the
  // sentence text, so this won't over-match.
  static final _blankPattern = RegExp(r'_+');

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

  /// One controller per blank, stable across rebuilds.
  TextEditingController _controllerFor(int blankIdx) {
    return _controllers.putIfAbsent(blankIdx, () => TextEditingController());
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final accepted = (data['blank_answers'] as List<dynamic>)
        .map((answers) => (answers as List<dynamic>).cast<String>())
        .toList();

    final blankIndices = _controllers.keys.toList()..sort();
    final userParts = blankIndices
        .map((idx) => normalizeAnswer(_controllers[idx]!.text))
        .toList();

    final correct =
        accepted.length == userParts.length &&
        List.generate(
          userParts.length,
          (index) =>
              accepted[index].map(normalizeAnswer).contains(userParts[index]),
        ).every((matches) => matches);

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    widget.onAnswered(
      ExerciseResult(
        isCorrect: correct,
        explanation: data['explanation'] as String?,
        correctAnswer: _displayAnswer(data),
      ),
    );
  }

  /// First accepted answer, with | separators made readable.
  String _displayAnswer(Map<String, dynamic> data) {
    return (data['blank_answers'] as List<dynamic>)
        .map((answers) => (answers as List<dynamic>).first as String)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final sentence = data['sentence'] as String;

    // Split sentence at underscore runs to show blanks visually
    final parts = sentence.split(_blankPattern);

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

          // Sentence with one inline input per blank
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                Text(parts[i], style: Theme.of(context).textTheme.bodyLarge),
                if (i < parts.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _controllerFor(i),
                        enabled: !answered,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        style: TextStyle(
                          color: isCorrect == false ? Colors.red : null,
                          fontWeight: FontWeight.bold,
                        ),
                        onSubmitted: answered ? null : (_) => _checkAnswer(),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          if (!answered)
            FilledButton(onPressed: _checkAnswer, child: const Text('Check')),
        ],
      ),
    );
  }
}
