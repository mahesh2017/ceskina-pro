import 'dart:convert';
import '../../domain/entities/gamification_state.dart';
import '../../domain/repositories/progress_repository.dart';
import '../database/database.dart' as db;

/// Concrete implementation of [ProgressRepository] using Drift.
class DriftProgressRepository implements ProgressRepository {
  final db.AppDatabase _db;

  DriftProgressRepository(this._db);

  @override
  Stream<ProgressSnapshot> watchProgress() {
    return _db.progressDao.watchCompletedLessons().map((lessons) {
      final unitScores = <int, double>{};
      for (final lesson in lessons) {
        unitScores[lesson.unitId] =
            (unitScores[lesson.unitId] ?? 0) + lesson.bestScore;
      }
      // Normalize by lesson count per unit
      final unitLessonCounts = <int, int>{};
      for (final lesson in lessons) {
        unitLessonCounts[lesson.unitId] =
            (unitLessonCounts[lesson.unitId] ?? 0) + 1;
      }
      final normalized = unitScores.map((unitId, totalScore) {
        final count = unitLessonCounts[unitId] ?? 1;
        return MapEntry(unitId, totalScore / count);
      });

      return ProgressSnapshot(
        unitScores: normalized,
        earnedBadges: {},
      );
    });
  }

  @override
  Future<void> recordCompletion(int unitId, int lessonId, double score) {
    return _db.progressDao.recordLessonCompletion(
      unitId: unitId,
      lessonId: lessonId,
      score: score,
    );
  }

  @override
  Future<Set<int>> getCompletedLessonIds() async {
    final completed = await _db.progressDao.getCompletedLessons();
    return completed.map((l) => l.lessonId).toSet();
  }

  @override
  Future<ProgressSnapshot> getSnapshot() async {
    final completed = await _db.progressDao.getCompletedLessons();
    final badgeIds = await _db.progressDao.getEarnedBadgeIds();

    // Sum per-unit scores and normalize by lesson count
    final unitScores = <int, double>{};
    final unitLessonCounts = <int, int>{};
    for (final lesson in completed) {
      unitScores[lesson.unitId] =
          (unitScores[lesson.unitId] ?? 0) + lesson.bestScore;
      unitLessonCounts[lesson.unitId] =
          (unitLessonCounts[lesson.unitId] ?? 0) + 1;
    }
    final normalized = unitScores.map((unitId, totalScore) {
      final count = unitLessonCounts[unitId] ?? 1;
      return MapEntry(unitId, totalScore / count);
    });

    // Get streak from KV store
    final streakStr = await _db.progressDao.getProgressValue('streak');
    final longestStreakStr =
        await _db.progressDao.getProgressValue('longest_streak');
    final examsPassedStr =
        await _db.progressDao.getProgressValue('exams_passed');

    return ProgressSnapshot(
      unitScores: normalized,
      longestStreak: int.tryParse(streakStr ?? '0') ?? 0,
      examsPassed: examsPassedStr != null
          ? (jsonDecode(examsPassedStr) as List<dynamic>).cast<String>().toSet()
          : {},
      earnedBadges: badgeIds.toSet(),
    );
  }

  @override
  Future<void> recordExamPassed(String level) async {
    final snapshot = await getSnapshot();
    final exams = Set<String>.from(snapshot.examsPassed);
    exams.add(level);
    await _db.progressDao.setProgressValue(
      'exams_passed',
      jsonEncode(exams.toList()),
    );
  }

  @override
  Future<void> updateStreak(int currentStreak, int longestStreak) async {
    await _db.progressDao.setProgressValue('streak', currentStreak.toString());
    await _db.progressDao
        .setProgressValue('longest_streak', longestStreak.toString());
  }
}