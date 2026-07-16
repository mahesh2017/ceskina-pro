import 'package:flutter/material.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/enums.dart';

/// Result of an exercise answer submission.
class ExerciseResult {
  final bool isCorrect;
  final String? explanation;
  final String? correctAnswer;

  const ExerciseResult({
    required this.isCorrect,
    this.explanation,
    this.correctAnswer,
  });
}

/// Callback type for when an exercise is answered.
typedef OnExerciseAnswered = void Function(ExerciseResult result);

/// Base widget for all exercise types.
/// Dispatches to the correct exercise widget based on [Exercise.type].
class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return switch (exercise.type) {
      ExerciseType.multipleChoice => _MultipleChoiceView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.translation => _TranslationView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.fillBlank => _FillBlankView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.wordOrder => _WordOrderView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.dictation => _DictationView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.pronunciation => _PronunciationView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.dialogue => _DialogueView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.declensionTable => _DeclensionTableView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.aspectRecognition => _MultipleChoiceView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.prepositionCase => _MultipleChoiceView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      ExerciseType.listening => _DictationView(
          exercise: exercise,
          onAnswered: onAnswered,
        ),
    };
  }
}

/// Placeholder views for exercise types that are built in separate files.
/// These are imported and replaced as each widget is implemented.

// Multiple Choice — fully implemented below
class _MultipleChoiceView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _MultipleChoiceView({required this.exercise, required this.onAnswered});

  @override
  State<_MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<_MultipleChoiceView> {
  int? selectedIdx;
  bool answered = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final options = (data['options'] as List<dynamic>).cast<String>();
    final correctIdx = data['correct_index'] as int;
    final questionEn = data['question_en'] as String? ?? widget.exercise.prompt;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question
          Text(
            questionEn,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (data['question_cz'] != null) ...[
            const SizedBox(height: 8),
            Text(
              data['question_cz'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),

          // Options
          ...List.generate(options.length, (i) {
            final isCorrect = i == correctIdx;
            final isSelected = i == selectedIdx;
            Color? cardColor;
            Color? borderColor;
            IconData? icon;

            if (answered && isCorrect) {
              cardColor = Colors.green.shade50;
              borderColor = Colors.green;
              icon = Icons.check_circle;
            } else if (answered && isSelected && !isCorrect) {
              cardColor = Colors.red.shade50;
              borderColor = Colors.red;
              icon = Icons.cancel;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: borderColor != null
                      ? BorderSide(color: borderColor, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: icon != null
                      ? Icon(icon,
                          color: isCorrect ? Colors.green : Colors.red)
                      : Text(
                          String.fromCharCode(65 + i),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                  title: Text(options[i]),
                  onTap: answered
                      ? null
                      : () {
                          setState(() {
                            selectedIdx = i;
                            answered = true;
                          });
                          final result = ExerciseResult(
                            isCorrect: i == correctIdx,
                            explanation: data['explanation'] as String?,
                            correctAnswer: options[correctIdx],
                          );
                          // Delay to let user see the result
                          Future.delayed(const Duration(milliseconds: 1500),
                              () {
                            if (mounted) widget.onAnswered(result);
                          });
                        },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Translation — fully implemented below
class _TranslationView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _TranslationView({required this.exercise, required this.onAnswered});

  @override
  State<_TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<_TranslationView> {
  final _controller = TextEditingController();
  bool answered = false;
  bool? isCorrect;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final accepted = (data['accepted_answers'] as List<dynamic>)
        .map((e) => (e as String).trim().toLowerCase())
        .toList();
    final userAnswer = _controller.text.trim().toLowerCase();
    final correct = accepted.any((a) => a == userAnswer);

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final result = ExerciseResult(
      isCorrect: correct,
      explanation: data['grammar_note'] as String?,
      correctAnswer: (data['accepted_answers'] as List<dynamic>).first as String,
    );

    Future.delayed(const Duration(milliseconds: 1500),
        () {
      if (mounted) widget.onAnswered(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final direction = data['direction'] as String? ?? 'en_to_cz';
    final source = data['source'] as String;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Direction label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              direction == 'en_to_cz' ? 'EN → CZ' : 'CZ → EN',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Source text
          Text(
            source,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Input field
          TextField(
            controller: _controller,
            enabled: !answered,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: direction == 'en_to_cz' ? 'Type in Czech' : 'Type in English',
              suffixIcon: isCorrect == true
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : isCorrect == false
                      ? const Icon(Icons.cancel, color: Colors.red)
                      : null,
            ),
            onSubmitted: answered ? null : (_) => _checkAnswer(),
          ),
          const SizedBox(height: 16),

          // Submit button
          if (!answered)
            FilledButton(
              onPressed: _checkAnswer,
              child: const Text('Check'),
            ),

          // Show correct answer if wrong
          if (answered == true && isCorrect == false) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Correct: ${(data['accepted_answers'] as List<dynamic>).first}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Fill in the Blank
class _FillBlankView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _FillBlankView({required this.exercise, required this.onAnswered});

  @override
  State<_FillBlankView> createState() => _FillBlankViewState();
}

class _FillBlankViewState extends State<_FillBlankView> {
  final _controller = TextEditingController();
  bool answered = false;
  bool? isCorrect;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final accepted = (data['accepted_answers'] as List<dynamic>)
        .map((e) => (e as String).trim().toLowerCase())
        .toList();
    final userAnswer = _controller.text.trim().toLowerCase();
    // Support multi-blank with | separator
    final correct = accepted.any((a) {
      if (a.contains('|')) {
        final parts = a.split('|').map((p) => p.trim().toLowerCase()).toList();
        final userParts = userAnswer.split('|').map((p) => p.trim().toLowerCase()).toList();
        if (parts.length != userParts.length) return false;
        for (var i = 0; i < parts.length; i++) {
          if (parts[i] != userParts[i]) return false;
        }
        return true;
      }
      return a == userAnswer;
    });

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final result = ExerciseResult(
      isCorrect: correct,
      explanation: data['explanation'] as String?,
      correctAnswer: (data['accepted_answers'] as List<dynamic>).first as String,
    );

    Future.delayed(const Duration(milliseconds: 1500),
        () {
      if (mounted) widget.onAnswered(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final sentence = data['sentence'] as String;

    // Split sentence at ___ to show blanks visually
    final parts = sentence.split('___');

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

          // Sentence with inline input
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
                        controller: _controller,
                        enabled: !answered,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
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
            FilledButton(
              onPressed: _checkAnswer,
              child: const Text('Check'),
            ),

          if (answered == true && isCorrect == false) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Correct: ${(data['accepted_answers'] as List<dynamic>).first}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Word Order — tap words to build sentence
class _WordOrderView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _WordOrderView({required this.exercise, required this.onAnswered});

  @override
  State<_WordOrderView> createState() => _WordOrderViewState();
}

class _WordOrderViewState extends State<_WordOrderView> {
  List<String> available = [];
  List<String> selected = [];
  bool answered = false;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    final data = widget.exercise.data;
    // Filter out English words (after — separator) and non-word items
    final allWords = (data['words'] as List<dynamic>).cast<String>();
    // Find the separator index — Czech words come before it
    final sepIdx = allWords.indexOf('—');
    if (sepIdx >= 0) {
      available = allWords.sublist(0, sepIdx);
    } else {
      available = allWords.where((w) => !_isEnglish(w)).toList();
    }
    available = List.from(available)..shuffle();
  }

  bool _isEnglish(String w) {
    // Simple heuristic: English words don't contain Czech diacritics
    // and the translation part starts after —
    return false;
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final correctOrder = (data['correct_order'] as List<dynamic>).cast<int>();
    final allWords = (data['words'] as List<dynamic>).cast<String>();
    final sepIdx = allWords.indexOf('—');
    final czechWords = sepIdx >= 0
        ? allWords.sublist(0, sepIdx)
        : allWords.where((w) => w != '—').toList();

    // Compare by position, not by indexOf (which breaks on duplicate words).
    // The user's selected list should match the correct_order indices.
    final correct = selected.length == correctOrder.length &&
        _checkOrder(selected, czechWords, correctOrder);

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final correctSentence = correctOrder.map((i) => czechWords[i]).join(' ');
    final result = ExerciseResult(
      isCorrect: correct,
      explanation: data['explanation'] as String?,
      correctAnswer: correctSentence,
    );

    Future.delayed(const Duration(milliseconds: 1500),
        () {
      if (mounted) widget.onAnswered(result);
    });
  }

  /// Build the correct sentence from the exercise data for display.
  String _buildCorrectSentence(Map<String, dynamic> data) {
    final allWords = (data['words'] as List<dynamic>).cast<String>();
    final sepIdx = allWords.indexOf('—');
    final czechWords = sepIdx >= 0
        ? allWords.sublist(0, sepIdx)
        : allWords.where((w) => w != '—').toList();
    final correctOrder = (data['correct_order'] as List<dynamic>).cast<int>();
    return correctOrder.map((i) => czechWords[i]).join(' ');
  }

  /// Check that the selected words match the correct order indices.
  /// Handles duplicate words correctly by comparing the word at each
  /// correct_order index to the user's selection at that position.
  bool _checkOrder(
      List<String> selected, List<String> czechWords, List<int> correctOrder) {
    if (selected.length != correctOrder.length) return false;
    for (var i = 0; i < correctOrder.length; i++) {
      final expectedWord = czechWords[correctOrder[i]];
      if (selected[i] != expectedWord) return false;
    }
    return true;
  }

  bool listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
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

          // Selected words area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minHeight: 60),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected.asMap().entries.map((entry) {
                return _WordChip(
                  word: entry.value,
                  onTap: answered
                      ? null
                      : () {
                          setState(() {
                            available.add(selected.removeAt(entry.key));
                          });
                        },
                  color: answered
                      ? (isCorrect == true
                          ? Colors.green.shade50
                          : Colors.red.shade50)
                      : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Available words
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available.asMap().entries.map((entry) {
              return _WordChip(
                word: entry.value,
                onTap: answered
                    ? null
                    : () {
                        setState(() {
                          selected.add(available.removeAt(entry.key));
                        });
                      },
              );
            }).toList(),
          ),
          const Spacer(),
          if (!answered && selected.isNotEmpty)
            FilledButton(
              onPressed: _checkAnswer,
              child: const Text('Check'),
            ),
          if (answered == true && isCorrect == false) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Correct: ${widget.exercise.data['correct_answer'] ?? _buildCorrectSentence(widget.exercise.data)}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final VoidCallback? onTap;
  final Color? color;

  const _WordChip({required this.word, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(word),
      onPressed: onTap,
      backgroundColor: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

// Dictation — listen and type
class _DictationView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _DictationView({required this.exercise, required this.onAnswered});

  @override
  State<_DictationView> createState() => _DictationViewState();
}

class _DictationViewState extends State<_DictationView> {
  final _controller = TextEditingController();
  bool answered = false;
  bool? isCorrect;
  bool _normalizeCompare(String a, String b) {
    // Compare case-insensitive, ignoring trailing punctuation
    String norm(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?]+$'), '');
    return norm(a) == norm(b);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final expected = data['expected_text'] as String;
    final correct = _normalizeCompare(_controller.text, expected);

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final result = ExerciseResult(
      isCorrect: correct,
      explanation: data['note'] as String?,
      correctAnswer: expected,
    );

    Future.delayed(const Duration(milliseconds: 1500),
        () {
      if (mounted) widget.onAnswered(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;

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

          // Audio play button (placeholder — will connect to TTS later)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.volume_up,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              // TODO: Play audio via TTS service
            },
            icon: const Icon(Icons.replay),
            label: const Text('Play again'),
          ),
          const SizedBox(height: 24),

          // Input field
          TextField(
            controller: _controller,
            enabled: !answered,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Type what you heard',
              suffixIcon: isCorrect == true
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : isCorrect == false
                      ? const Icon(Icons.cancel, color: Colors.red)
                      : null,
            ),
            onSubmitted: answered ? null : (_) => _checkAnswer(),
          ),
          const SizedBox(height: 16),

          if (!answered)
            FilledButton(
              onPressed: _checkAnswer,
              child: const Text('Check'),
            ),

          if (answered == true && isCorrect == false) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Correct: ${data['expected_text']}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Pronunciation — record and get feedback
class _PronunciationView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _PronunciationView({required this.exercise, required this.onAnswered});

  @override
  State<_PronunciationView> createState() => _PronunciationViewState();
}

class _PronunciationViewState extends State<_PronunciationView> {
  bool isRecording = false;
  bool hasRecorded = false;
  double? score;

  void _toggleRecording() {
    // TODO: Connect to actual recording + STT + pronunciation scoring
    setState(() {
      if (isRecording) {
        isRecording = false;
        hasRecorded = true;
        // Placeholder score — will be replaced by real scoring
        score = 0.75;
      } else {
        isRecording = true;
        hasRecorded = false;
        score = null;
      }
    });
  }

  void _submitResult() {
    final data = widget.exercise.data;
    final minScore = (data['min_score'] as num?)?.toDouble() ?? 0.65;
    final passed = (score ?? 0) >= minScore;

    widget.onAnswered(ExerciseResult(
      isCorrect: passed,
      explanation: data['note'] as String? ??
          (passed ? 'Good pronunciation!' : 'Try again — focus on the highlighted sounds.'),
      correctAnswer: data['target_text'] as String?,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final targetText = data['target_text'] as String;
    final translation = data['translation_en'] as String?;
    final focusSounds = (data['focus_sounds'] as List<dynamic>?) ?? [];

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
                ...focusSounds.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Chip(
                        label: Text(s as String),
                        padding: EdgeInsets.zero,
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    )),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Record button
          GestureDetector(
            onTap: _toggleRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording
                    ? Colors.red.shade400
                    : Theme.of(context).colorScheme.primary,
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? 'Recording... tap to stop'
                : hasRecorded
                    ? 'Recorded! Tap to try again'
                    : 'Tap to record',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          // Score display
          if (hasRecorded && score != null) ...[
            const SizedBox(height: 24),
            _ScoreDisplay(score: score!),
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

class _ScoreDisplay extends StatelessWidget {
  final double score;

  const _ScoreDisplay({required this.score});

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).round();
    final color = score >= 0.8
        ? Colors.green
        : score >= 0.65
            ? Colors.orange
            : Colors.red;

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
          score >= 0.8
              ? 'Výborně! Excellent!'
              : score >= 0.65
                  ? 'Dobře. Good — keep practicing.'
                  : 'Zkuste znovu. Try again.',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Dialogue completion
class _DialogueView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _DialogueView({required this.exercise, required this.onAnswered});

  @override
  State<_DialogueView> createState() => _DialogueViewState();
}

class _DialogueViewState extends State<_DialogueView> {
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
      List<Map<String, dynamic>> lines, BuildContext context) {
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
          alignment: isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
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
    // Support multi-blank with | separator
    final accepted = acceptedRaw.map((a) {
      final s = (a as String).trim().toLowerCase();
      return s;
    }).toList();

    // Collect answers from all controllers in order
    final blankIndices = _controllers.keys.toList()..sort();
    final userAnswer = blankIndices
        .map((idx) => _controllers[idx]!.text.trim())
        .join('|')
        .toLowerCase();

    // Check if user answer matches any accepted answer (or partial for multi-blank)
    final correct = accepted.any((a) {
      if (a.contains('|')) {
        final parts = a.split('|').map((p) => p.trim().toLowerCase()).toList();
        final userParts =
            userAnswer.split('|').map((p) => p.trim().toLowerCase()).toList();
        if (parts.length != userParts.length) return false;
        for (var i = 0; i < parts.length; i++) {
          if (parts[i] != userParts[i]) return false;
        }
        return true;
      }
      return a == userAnswer;
    });

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final result = ExerciseResult(
      isCorrect: correct,
      explanation: data['explanation'] as String?,
      correctAnswer: acceptedRaw.first as String,
    );

    Future.delayed(const Duration(milliseconds: 1500),
        () {
      if (mounted) widget.onAnswered(result);
    });
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          const SizedBox(height: 16),

          // Dialogue lines
          ..._buildDialogueLines(lines, context),

          const SizedBox(height: 16),
          if (!answered)
            FilledButton(
              onPressed: _checkAnswer,
              child: const Text('Check'),
            ),

          if (answered == true && isCorrect == false) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Correct: ${(data['accepted_answers'] as List<dynamic>).first}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Declension table — Czech-specific exercise
class _DeclensionTableView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _DeclensionTableView({required this.exercise, required this.onAnswered});

  @override
  State<_DeclensionTableView> createState() => _DeclensionTableViewState();
}

class _DeclensionTableViewState extends State<_DeclensionTableView> {
  final Map<String, TextEditingController> _controllers = {};
  bool answered = false;
  int correctCount = 0;
  int totalBlanks = 0;

  @override
  void initState() {
    super.initState();
    final data = widget.exercise.data;
    final cases = (data['cases'] as List<dynamic>).cast<String>();
    totalBlanks = cases.length;
    for (final caseName in cases) {
      _controllers[caseName] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkAnswers() {
    final data = widget.exercise.data;
    final answerKey =
        Map<String, String>.from(data['answer_key'] as Map<String, dynamic>);
    final word = data['word'] as String;

    correctCount = 0;
    for (final entry in _controllers.entries) {
      final caseName = entry.key;
      final userAnswer = entry.value.text.trim().toLowerCase();
      final correctAnswer = answerKey[caseName]!.toLowerCase();
      if (userAnswer == correctAnswer) {
        correctCount++;
      }
    }

    setState(() {
      answered = true;
    });

    final result = ExerciseResult(
      isCorrect: correctCount == totalBlanks,
      explanation: 'You got $correctCount/$totalBlanks correct.',
      correctAnswer: answerKey.entries.map((e) => '${e.key}: ${e.value}').join(', '),
    );

    Future.delayed(const Duration(milliseconds: 2000),
        () {
      if (mounted) widget.onAnswered(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final word = data['word'] as String;
    final gender = data['gender'] as String?;
    final cases = (data['cases'] as List<dynamic>).cast<String>();
    final answerKey = answered
        ? Map<String, String>.from(data['answer_key'] as Map<String, dynamic>)
        : null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Decline: $word',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (gender != null)
            Text(
              'Gender: $gender',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),

          // Table
          Table(
            border: TableBorder.all(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Case',
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Form',
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                ],
              ),
              ...cases.map((caseName) {
                final controller = _controllers[caseName]!;
                final correct = answerKey?[caseName];
                final userAnswer = controller.text.trim().toLowerCase();
                final isCorrect =
                    correct != null && userAnswer == correct.toLowerCase();

                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(caseName),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        controller: controller,
                        enabled: !answered,
                        decoration: InputDecoration(
                          isDense: true,
                          border: const OutlineInputBorder(),
                          suffixIcon: answered
                              ? Icon(
                                  isCorrect ? Icons.check : Icons.close,
                                  color: isCorrect ? Colors.green : Colors.red,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          if (!answered)
            FilledButton(
              onPressed: _checkAnswers,
              child: const Text('Check All'),
            ),

          if (answered) ...[
            const SizedBox(height: 16),
            Card(
              color: correctCount == totalBlanks
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '$correctCount / $totalBlanks correct',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: correctCount == totalBlanks
                        ? Colors.green
                        : Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}