import 'package:flutter/material.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/enums.dart';
import 'exercises/exercise_shared.dart';
import 'exercises/multiple_choice_view.dart';
import 'exercises/translation_view.dart';
import 'exercises/fill_blank_view.dart';
import 'exercises/word_order_view.dart';
import 'exercises/dictation_view.dart';
import 'exercises/pronunciation_view.dart';
import 'exercises/dialogue_view.dart';
import 'exercises/declension_table_view.dart';

// Re-export shared helpers and types so existing imports of this file
// (e.g. `show TtsButton`) keep resolving without changes.
export 'exercises/exercise_shared.dart'
    show
        normalizeAnswer,
        correctTint,
        wrongTint,
        AnswerMatch,
        matchAnswer,
        CzechCharBar,
        ExerciseResult,
        OnExerciseAnswered,
        TtsButton;

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
      ExerciseType.multipleChoice => MultipleChoiceView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.translation => TranslationView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.fillBlank => FillBlankView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.wordOrder => WordOrderView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.dictation => DictationView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.pronunciation => PronunciationView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.dialogue => DialogueView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.declensionTable => DeclensionTableView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.aspectRecognition => MultipleChoiceView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.prepositionCase => MultipleChoiceView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
      ExerciseType.listening => DictationView(
        exercise: exercise,
        onAnswered: onAnswered,
      ),
    };
  }
}