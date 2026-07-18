import '../entities/enums.dart';

/// Tracks curriculum progress and determines CEFR level.
class CurriculumProgressTracker {
  /// A unit counts as "mastered" at this average lesson score.
  static const masteryThreshold = 0.6;

  /// Determine if a lesson is unlocked (previous lesson completed).
  bool isLessonUnlocked({
    required int lessonOrder,
    required Set<int> completedLessonIds,
    required Map<int, int> lessonIdByOrder,
  }) {
    if (lessonOrder == 0) return true;
    final prevId = lessonIdByOrder[lessonOrder - 1];
    if (prevId == null) return true;
    return completedLessonIds.contains(prevId);
  }

  /// Calculate unit completion percentage.
  double unitCompletion({
    required int unitId,
    required Map<int, Set<int>> completedLessonsByUnit,
    required int totalLessonsInUnit,
  }) {
    if (totalLessonsInUnit == 0) return 0.0;
    final completed = completedLessonsByUnit[unitId]?.length ?? 0;
    return completed / totalLessonsInUnit;
  }

  /// Completion rate for one phase: the fraction of that phase's units
  /// (ALL of them, not just attempted ones) mastered at [masteryThreshold].
  double phaseCompletion({
    required Map<int, double> unitScores,
    required Set<int> phaseUnitIds,
  }) {
    if (phaseUnitIds.isEmpty) return 0.0;
    final mastered = phaseUnitIds
        .where((id) => (unitScores[id] ?? 0.0) >= masteryThreshold)
        .length;
    return mastered / phaseUnitIds.length;
  }

  /// Determine CEFR level estimate from phase completion + passed exams.
  CEFRLevel estimateLevel({
    required double a1Completion,
    required double a2Completion,
    required Set<String> examsPassed,
  }) {
    if (a2Completion > 0.8 && examsPassed.contains('a2')) {
      return CEFRLevel.a2;
    }
    if (a1Completion > 0.8 && examsPassed.contains('a1')) {
      return CEFRLevel.a1;
    }
    return CEFRLevel.preA1;
  }
}
