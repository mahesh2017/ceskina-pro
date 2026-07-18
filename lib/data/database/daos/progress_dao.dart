import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/lesson_progress.dart';
import '../tables/earned_badges.dart';
import '../tables/user_progress.dart';

part 'progress_dao.g.dart';

/// Data access object for progress, badges, and lesson completion.
@DriftAccessor(tables: [LessonProgress, EarnedBadges, UserProgress])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  // ── Lesson Progress ──

  Future<void> recordLessonCompletion({
    required int lessonId,
    required int unitId,
    required double score,
  }) async {
    final existing = await (select(lessonProgress)
          ..where((l) => l.lessonId.equals(lessonId)))
        .getSingleOrNull();

    if (existing == null) {
      await into(lessonProgress).insert(LessonProgressCompanion.insert(
        lessonId: Value(lessonId),
        unitId: unitId,
        isCompleted: const Value(true),
        bestScore: Value(score),
        attempts: const Value(1),
        lastAttempted: Value(DateTime.now()),
      ),);
    } else {
      await (update(lessonProgress)
            ..where((l) => l.lessonId.equals(lessonId)))
          .write(LessonProgressCompanion(
        isCompleted: const Value(true),
        bestScore: Value(score > existing.bestScore ? score : existing.bestScore),
        attempts: Value(existing.attempts + 1),
        lastAttempted: Value(DateTime.now()),
      ),);
    }
  }

  Future<List<LessonProgressData>> getCompletedLessons() {
    return (select(lessonProgress)
          ..where((l) => l.isCompleted.equals(true)))
        .get();
  }

  Future<List<LessonProgressData>> getLessonsByUnit(int unitId) {
    return (select(lessonProgress)
          ..where((l) => l.unitId.equals(unitId)))
        .get();
  }

  Stream<List<LessonProgressData>> watchCompletedLessons() {
    return (select(lessonProgress)
          ..where((l) => l.isCompleted.equals(true)))
        .watch();
  }

  // ── Earned Badges ──

  Future<List<String>> getEarnedBadgeIds() async {
    final rows = await select(earnedBadges).get();
    return rows.map((b) => b.badgeId).toList();
  }

  Future<void> earnBadge(String badgeId) =>
      into(earnedBadges).insertOnConflictUpdate(
            EarnedBadgesCompanion.insert(badgeId: badgeId),);

  // ── User Progress KV ──

  Future<String?> getProgressValue(String key) async {
    final row = await (select(userProgress)
          ..where((u) => u.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setProgressValue(String key, String value) =>
      into(userProgress).insertOnConflictUpdate(
            UserProgressCompanion.insert(key: key, value: value),);
}