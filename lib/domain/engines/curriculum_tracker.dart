import '../entities/gamification_state.dart';
import '../entities/enums.dart';

/// Tracks curriculum progress and determines CEFR level.
class CurriculumProgressTracker {
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

  /// Determine CEFR level estimate based on progress.
  CEFRLevel estimateLevel(ProgressSnapshot snapshot) {
    if (snapshot.a2CompletionRate > 0.8 &&
        snapshot.examsPassed.contains('a2')) {
      return CEFRLevel.a2;
    }
    if (snapshot.a1CompletionRate > 0.8 &&
        snapshot.examsPassed.contains('a1')) {
      return CEFRLevel.a1;
    }
    return CEFRLevel.preA1;
  }

  /// Calculate overall A1 completion rate.
  double calculateA1Completion({
    required Map<int, double> unitScores,
    required int totalA1Units,
  }) {
    if (totalA1Units == 0) return 0.0;
    final completed = unitScores.values.where((s) => s >= 0.6).length;
    return completed / totalA1Units;
  }

  /// Calculate overall A2 completion rate.
  double calculateA2Completion({
    required Map<int, double> unitScores,
    required int totalA2Units,
  }) {
    if (totalA2Units == 0) return 0.0;
    final completed = unitScores.values.where((s) => s >= 0.6).length;
    return completed / totalA2Units;
  }
}