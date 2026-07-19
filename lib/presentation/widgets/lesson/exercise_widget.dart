import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/score_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/engines/pronunciation_scorer.dart';
import '../../providers/stt_providers.dart';
import '../../providers/tts_providers.dart';

/// Normalize a typed answer for comparison: lowercase, strip punctuation,
/// collapse whitespace. Diacritics are kept — they're meaningful in Czech.
String _normalizeAnswer(String s) => TextNormalizer.normalize(s);

/// Translucent feedback tints that work on light and dark surfaces.
final Color _correctTint = Colors.green.withValues(alpha: 0.12);
final Color _wrongTint = Colors.red.withValues(alpha: 0.12);

/// How closely a typed answer matched: exact, accents-only difference,
/// or wrong.
enum AnswerMatch { exact, nearMiss, none }

/// Compare a user's typed answer against the accepted answers, allowing a
/// diacritics-only "near miss".
AnswerMatch matchAnswer(List<String> accepted, String user) {
  final u = _normalizeAnswer(user);
  if (u.isEmpty) return AnswerMatch.none;
  if (accepted.any((a) => _normalizeAnswer(a) == u)) {
    return AnswerMatch.exact;
  }
  if (accepted.any((a) => TextNormalizer.matchesIgnoringDiacritics(a, user))) {
    return AnswerMatch.nearMiss;
  }
  return AnswerMatch.none;
}

/// A horizontal bar of Czech diacritic letters that inserts into the
/// currently-targeted text field at the cursor. Essential when typing on a
/// non-Czech keyboard, where several exercises are otherwise unanswerable.
class CzechCharBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const CzechCharBar({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  void _insert(String ch) {
    final sel = controller.selection;
    final text = controller.text;
    if (sel.isValid && sel.start >= 0) {
      final newText = text.replaceRange(sel.start, sel.end, ch);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + ch.length),
      );
    } else {
      controller.text = text + ch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TextNormalizer.czechDiacriticChars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final ch = TextNormalizer.czechDiacriticChars[i];
          return OutlinedButton(
            onPressed: enabled ? () => _insert(ch) : null,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(36, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(ch, style: const TextStyle(fontSize: 16)),
          );
        },
      ),
    );
  }
}

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
    final correctIdx = (data['correct_index'] as num).toInt();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    data['question_cz'] as String,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                TtsButton(text: data['question_cz'] as String, size: 20),
              ],
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
              cardColor = _correctTint;
              borderColor = Colors.green;
              icon = Icons.check_circle;
            } else if (answered && isSelected && !isCorrect) {
              cardColor = _wrongTint;
              borderColor = Colors.red;
              icon = Icons.cancel;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      borderColor != null
                          ? BorderSide(color: borderColor, width: 2)
                          : BorderSide.none,
                ),
                child: ListTile(
                  leading:
                      icon != null
                          ? Icon(
                            icon,
                            color: isCorrect ? Colors.green : Colors.red,
                          )
                          : Text(
                            String.fromCharCode(65 + i),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                  title: Text(options[i]),
                  onTap:
                      answered
                          ? null
                          : () {
                            setState(() {
                              selectedIdx = i;
                              answered = true;
                            });
                            // Report immediately — the lesson player shows a
                            // feedback banner alongside the highlighted options
                            // and the learner advances at their own pace.
                            widget.onAnswered(
                              ExerciseResult(
                                isCorrect: i == correctIdx,
                                explanation: data['explanation'] as String?,
                                correctAnswer: options[correctIdx],
                              ),
                            );
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
    final accepted = (data['accepted_answers'] as List<dynamic>).cast<String>();
    final match = matchAnswer(accepted, _controller.text);
    // A diacritics-only miss still counts (no heart loss) but nudges the
    // learner about accents.
    final correct = match != AnswerMatch.none;

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final grammarNote = data['grammar_note'] as String?;
    final explanation =
        match == AnswerMatch.nearMiss
            ? 'Almost! Watch your accent marks — the correct spelling is "${accepted.first}".'
            : grammarNote;

    widget.onAnswered(
      ExerciseResult(
        isCorrect: correct,
        explanation: explanation,
        correctAnswer: accepted.first,
      ),
    );
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
              labelText:
                  direction == 'en_to_cz' ? 'Type in Czech' : 'Type in English',
              suffixIcon:
                  isCorrect == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : isCorrect == false
                      ? const Icon(Icons.cancel, color: Colors.red)
                      : null,
            ),
            onSubmitted: answered ? null : (_) => _checkAnswer(),
          ),

          // Czech character helper — only when typing Czech.
          if (direction == 'en_to_cz' && !answered) ...[
            const SizedBox(height: 8),
            CzechCharBar(controller: _controller, enabled: !answered),
          ],
          const SizedBox(height: 16),

          // Submit button
          if (!answered)
            FilledButton(onPressed: _checkAnswer, child: const Text('Check')),

          // The lesson player's feedback banner shows the correct answer.
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
    final accepted = (data['accepted_answers'] as List<dynamic>).cast<String>();

    // Collect per-blank answers in order; multi-blank joins with |
    // to match the accepted_answers format.
    final blankIndices = _controllers.keys.toList()..sort();
    final userParts =
        blankIndices
            .map((idx) => _normalizeAnswer(_controllers[idx]!.text))
            .toList();

    final correct = accepted.any((a) {
      final parts = a.split('|').map(_normalizeAnswer).toList();
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
        correctAnswer: _displayAnswer(data),
      ),
    );
  }

  /// First accepted answer, with | separators made readable.
  String _displayAnswer(Map<String, dynamic> data) {
    final first = (data['accepted_answers'] as List<dynamic>).first as String;
    return first.replaceAll('|', ', ');
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

  /// The Czech words to arrange. Content packs older than the format
  /// cleanup appended English words after a '—' separator; tolerate both.
  List<String> _czechWords() {
    final allWords =
        (widget.exercise.data['words'] as List<dynamic>).cast<String>();
    final sepIdx = allWords.indexOf('—');
    return sepIdx >= 0 ? allWords.sublist(0, sepIdx) : allWords;
  }

  @override
  void initState() {
    super.initState();
    available = List.of(_czechWords())..shuffle();
  }

  void _checkAnswer() {
    final data = widget.exercise.data;
    final correctOrder = (data['correct_order'] as List<dynamic>).cast<int>();
    final czechWords = _czechWords();

    // Compare by position, not by indexOf (which breaks on duplicate words).
    final correct =
        selected.length == correctOrder.length &&
        _checkOrder(selected, czechWords, correctOrder);

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final correctSentence = correctOrder.map((i) => czechWords[i]).join(' ');
    widget.onAnswered(
      ExerciseResult(
        isCorrect: correct,
        explanation: data['explanation'] as String?,
        correctAnswer: correctSentence,
      ),
    );
  }

  /// Check that the selected words match the correct order indices.
  /// Handles duplicate words correctly by comparing the word at each
  /// correct_order index to the user's selection at that position.
  bool _checkOrder(
    List<String> selected,
    List<String> czechWords,
    List<int> correctOrder,
  ) {
    if (selected.length != correctOrder.length) return false;
    for (var i = 0; i < correctOrder.length; i++) {
      final expectedWord = czechWords[correctOrder[i]];
      if (selected[i] != expectedWord) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final translationEn = widget.exercise.data['translation_en'] as String?;

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
          if (translationEn != null) ...[
            const SizedBox(height: 8),
            Text(
              '"$translationEn"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
              children:
                  selected.asMap().entries.map((entry) {
                    return _WordChip(
                      word: entry.value,
                      onTap:
                          answered
                              ? null
                              : () {
                                setState(() {
                                  available.add(selected.removeAt(entry.key));
                                });
                              },
                      color:
                          answered
                              ? (isCorrect == true ? _correctTint : _wrongTint)
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
            children:
                available.asMap().entries.map((entry) {
                  return _WordChip(
                    word: entry.value,
                    onTap:
                        answered
                            ? null
                            : () {
                              setState(() {
                                selected.add(available.removeAt(entry.key));
                              });
                            },
                  );
                }).toList(),
          ),
          // No Spacer here: this widget renders inside a scroll view, where
          // flex children have unbounded height and would throw.
          const SizedBox(height: 24),
          if (!answered && selected.isNotEmpty)
            FilledButton(onPressed: _checkAnswer, child: const Text('Check')),
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
      backgroundColor:
          color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

// Dictation — listen and type
class _DictationView extends ConsumerStatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _DictationView({required this.exercise, required this.onAnswered});

  @override
  ConsumerState<_DictationView> createState() => _DictationViewState();
}

class _DictationViewState extends ConsumerState<_DictationView> {
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
    final expected = data['expected_text'] as String;
    final match = matchAnswer([expected], _controller.text);
    final correct = match != AnswerMatch.none;

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    final explanation =
        match == AnswerMatch.nearMiss
            ? 'Almost! Watch your accent marks — you wrote it correctly apart from the diacritics.'
            : data['note'] as String?;

    widget.onAnswered(
      ExerciseResult(
        isCorrect: correct,
        explanation: explanation,
        correctAnswer: expected,
      ),
    );
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

          // Audio play button — speaks the Czech text via TTS
          TtsButton(text: data['expected_text'] as String, size: 48),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(czechTtsProvider)
                      .speak(data['expected_text'] as String);
                },
                icon: const Icon(Icons.replay),
                label: const Text('Play again'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(czechTtsProvider)
                      .speakSlow(data['expected_text'] as String);
                },
                icon: const Icon(Icons.slow_motion_video),
                label: const Text('Slower'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Input field
          TextField(
            controller: _controller,
            enabled: !answered,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Type what you heard',
              suffixIcon:
                  isCorrect == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : isCorrect == false
                      ? const Icon(Icons.cancel, color: Colors.red)
                      : null,
            ),
            onSubmitted: answered ? null : (_) => _checkAnswer(),
          ),
          if (!answered) ...[
            const SizedBox(height: 8),
            CzechCharBar(controller: _controller, enabled: !answered),
          ],
          const SizedBox(height: 16),

          if (!answered)
            FilledButton(onPressed: _checkAnswer, child: const Text('Check')),
        ],
      ),
    );
  }
}

// Pronunciation — record and get feedback
class _PronunciationView extends ConsumerStatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _PronunciationView({required this.exercise, required this.onAnswered});

  @override
  ConsumerState<_PronunciationView> createState() => _PronunciationViewState();
}

class _PronunciationViewState extends ConsumerState<_PronunciationView> {
  bool isRecording = false;
  bool hasRecorded = false;
  bool isProcessing = false;
  double? score;
  String? feedback;

  Future<void> _toggleRecording() async {
    if (isProcessing) return;

    if (isRecording) {
      // Stop — the listenFor() will return when speech ends
      setState(() => isRecording = false);
      return;
    }

    setState(() {
      isRecording = true;
      hasRecorded = false;
      score = null;
      feedback = null;
    });

    try {
      final stt = ref.read(sttServiceProvider) as NativeSttService;
      final transcription = await stt.listenFor(
        timeout: const Duration(seconds: 8),
      );

      final targetText = widget.exercise.data['target_text'] as String;

      setState(() {
        isRecording = false;
        isProcessing = true;
      });

      // Score the pronunciation
      final scorer = PronunciationScorer();
      final result = scorer.score(
        expectedText: targetText,
        actualTranscription: transcription,
      );

      setState(() {
        isProcessing = false;
        hasRecorded = true;
        score = result.overallScore;
        feedback = result.feedback;
      });
    } catch (e) {
      setState(() {
        isRecording = false;
        isProcessing = false;
        hasRecorded = true;
        score = 0.0;
        feedback = 'Speech recognition failed. Check mic permissions.';
      });
    }
  }

  void _submitResult() {
    final data = widget.exercise.data;
    final minScore = (data['min_score'] as num?)?.toDouble() ?? 0.65;
    final passed = (score ?? 0) >= minScore;

    widget.onAnswered(
      ExerciseResult(
        isCorrect: passed,
        explanation:
            data['note'] as String? ??
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                      labelStyle: const TextStyle(fontSize: 12),
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
                color:
                    isRecording
                        ? Colors.red.shade400
                        : Theme.of(context).colorScheme.primary,
              ),
              child:
                  isProcessing
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

          // Escape hatch: on-device Czech recognition can be unavailable or
          // unreliable, and pronunciation should never hard-block progress.
          // Skipping passes the exercise without a heart penalty.
          if (!isProcessing)
            TextButton(
              onPressed:
                  () => widget.onAnswered(
                    ExerciseResult(
                      isCorrect: true,
                      explanation:
                          'Skipped — keep practising this one aloud with the '
                          '🔊 button.',
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
            _ScoreDisplay(score: score!),
            if (feedback != null) ...[
              const SizedBox(height: 8),
              Text(
                feedback!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
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

class _ScoreDisplay extends StatelessWidget {
  final double score;

  const _ScoreDisplay({required this.score});

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
            .map((idx) => _normalizeAnswer(_controllers[idx]!.text))
            .toList();

    // Multi-blank accepted answers use | separators.
    final correct = acceptedRaw.cast<String>().any((a) {
      final parts = a.split('|').map(_normalizeAnswer).toList();
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

// Declension table — Czech-specific exercise
class _DeclensionTableView extends StatefulWidget {
  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  const _DeclensionTableView({
    required this.exercise,
    required this.onAnswered,
  });

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
    final answerKey = Map<String, String>.from(
      data['answer_key'] as Map<String, dynamic>,
    );

    correctCount = 0;
    for (final entry in _controllers.entries) {
      final caseName = entry.key;
      final userAnswer = _normalizeAnswer(entry.value.text);
      final correctAnswer = _normalizeAnswer(answerKey[caseName] ?? '');
      if (userAnswer == correctAnswer) {
        correctCount++;
      }
    }

    setState(() {
      answered = true;
    });

    widget.onAnswered(
      ExerciseResult(
        isCorrect: correctCount == totalBlanks,
        explanation: 'You got $correctCount/$totalBlanks correct.',
        correctAnswer: answerKey.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', '),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.exercise.data;
    final word = data['word'] as String;
    final gender = data['gender'] as String?;
    final cases = (data['cases'] as List<dynamic>).cast<String>();
    final answerKey =
        answered
            ? Map<String, String>.from(
              data['answer_key'] as Map<String, dynamic>,
            )
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
                    child: Text(
                      'Case',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Form',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              ...cases.map((caseName) {
                final controller = _controllers[caseName]!;
                final correct = answerKey?[caseName];
                final userAnswer = _normalizeAnswer(controller.text);
                final isCorrect =
                    correct != null && userAnswer == _normalizeAnswer(correct);

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
                          suffixIcon:
                              answered
                                  ? Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
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
        ],
      ),
    );
  }
}

/// Small reusable TTS button that speaks Czech text when tapped.
class TtsButton extends ConsumerWidget {
  final String text;
  final double size;
  final Color? color;

  const TtsButton({super.key, required this.text, this.size = 24, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        ref.read(czechTtsProvider).speak(text);
      },
      icon: Icon(Icons.volume_up, size: size),
      color: color ?? Theme.of(context).colorScheme.primary,
      tooltip: 'Listen',
    );
  }
}
