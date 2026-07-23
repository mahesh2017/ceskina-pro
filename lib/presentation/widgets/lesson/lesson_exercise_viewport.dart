import 'package:flutter/material.dart';

import '../../../domain/entities/enums.dart';
import '../../../domain/entities/exercise.dart';
import 'exercise_widget.dart';

/// Composes an exercise inside the lesson player's available viewport.
///
/// Most exercises are intrinsically sized and rely on the lesson player for
/// scrolling. A smaller set owns an internal scrollable or an expanding input
/// area; those exercises must receive bounded height or their root [Expanded]
/// widgets fail under a [SingleChildScrollView].
class LessonExerciseViewport extends StatelessWidget {
  const LessonExerciseViewport({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  final Exercise exercise;
  final OnExerciseAnswered onAnswered;

  /// Exercise views that manage their own vertical space and scrolling.
  static bool usesBoundedHeight(ExerciseType type) => switch (type) {
    ExerciseType.matching ||
    ExerciseType.errorCorrection ||
    ExerciseType.readingComprehension ||
    ExerciseType.listeningComprehension ||
    ExerciseType.writingTask => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final exerciseWidget = ExerciseWidget(
      key: ValueKey(exercise.id),
      exercise: exercise,
      onAnswered: onAnswered,
    );

    if (usesBoundedHeight(exercise.type)) {
      return SizedBox.expand(child: exerciseWidget);
    }

    return SingleChildScrollView(child: exerciseWidget);
  }
}
