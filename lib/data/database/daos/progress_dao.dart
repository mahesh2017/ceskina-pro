import 'dart:convert';
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

    final now = DateTime.now();
    final bestScore =
        existing == null ? score : (score > existing.bestScore ? score : existing.bestScore);
    final attempts = existing == null ? 1 : existing.attempts + 1;

    if (existing == null) {
      await into(lessonProgress).insert(LessonProgressCompanion.insert(
        lessonId: Value(lessonId),
        unitId: unitId,
        isCompleted: const Value(true),
        bestScore: Value(bestScore),
        attempts: Value(attempts),
        lastAttempted: Value(now),
      ),);
    } else {
      await (update(lessonProgress)
            ..where((l) => l.lessonId.equals(lessonId)))
          .write(LessonProgressCompanion(
        isCompleted: const Value(true),
        bestScore: Value(bestScore),
        attempts: Value(attempts),
        lastAttempted: Value(now),
      ),);
    }

    await attachedDatabase.syncDao.enqueue(
      entity: 'lesson_progress',
      entityKey: lessonId.toString(),
      payload: {
        'lesson_id': lessonId,
        'unit_id': unitId,
        'is_completed': true,
        'best_score': bestScore,
        'attempts': attempts,
        'last_attempted': now.toUtc().toIso8601String(),
      },
    );
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

  Future<void> earnBadge(String badgeId) async {
    final now = DateTime.now();
    await into(earnedBadges).insertOnConflictUpdate(
        EarnedBadgesCompanion.insert(
            badgeId: badgeId, earnedAt: Value(now)),);
    await attachedDatabase.syncDao.enqueue(
      entity: 'earned_badges',
      entityKey: badgeId,
      payload: {
        'badge_id': badgeId,
        'earned_at': now.toUtc().toIso8601String(),
      },
    );
  }

  // ── User Progress KV ──

  Future<String?> getProgressValue(String key) async {
    final row = await (select(userProgress)
          ..where((u) => u.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setProgressValue(String key, String value) async {
    await into(userProgress).insertOnConflictUpdate(
        UserProgressCompanion.insert(key: key, value: value),);
    await attachedDatabase.syncDao.enqueue(
      entity: 'user_progress',
      entityKey: key,
      // Server column is jsonb; value is stored as an app-defined string, so
      // wrap it to preserve it verbatim regardless of whether it's JSON.
      payload: {'key': key, 'value': _asJsonValue(value)},
    );
  }

  /// Best-effort: if [value] already parses as JSON keep its structure,
  /// otherwise store it as a JSON string.
  Object? _asJsonValue(String value) {
    try {
      return jsonDecode(value);
    } catch (_) {
      return value;
    }
  }
}