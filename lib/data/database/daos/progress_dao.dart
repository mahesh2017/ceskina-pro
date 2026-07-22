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
  }) => attachedDatabase.transaction(() async {
    final existing =
        await (select(lessonProgress)
          ..where((l) => l.lessonId.equals(lessonId))).getSingleOrNull();

    final now = DateTime.now();
    final bestScore =
        existing == null
            ? score
            : (score > existing.bestScore ? score : existing.bestScore);
    final attempts = existing == null ? 1 : existing.attempts + 1;

    if (existing == null) {
      await into(lessonProgress).insert(
        LessonProgressCompanion.insert(
          lessonId: Value(lessonId),
          unitId: unitId,
          isCompleted: const Value(true),
          bestScore: Value(bestScore),
          attempts: Value(attempts),
          lastAttempted: Value(now),
        ),
      );
    } else {
      await (update(lessonProgress)
        ..where((l) => l.lessonId.equals(lessonId))).write(
        LessonProgressCompanion(
          isCompleted: const Value(true),
          bestScore: Value(bestScore),
          attempts: Value(attempts),
          lastAttempted: Value(now),
        ),
      );
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
  });

  Future<List<LessonProgressData>> getCompletedLessons() {
    return (select(lessonProgress)
      ..where((l) => l.isCompleted.equals(true))).get();
  }

  Future<List<LessonProgressData>> getLessonsByUnit(int unitId) {
    return (select(lessonProgress)
      ..where((l) => l.unitId.equals(unitId))).get();
  }

  Stream<List<LessonProgressData>> watchCompletedLessons() {
    return (select(lessonProgress)
      ..where((l) => l.isCompleted.equals(true))).watch();
  }

  // ── Earned Badges ──

  Future<List<String>> getEarnedBadgeIds() async {
    final rows = await select(earnedBadges).get();
    return rows.map((b) => b.badgeId).toList();
  }

  Future<void> earnBadge(String badgeId) =>
      attachedDatabase.transaction(() async {
        final now = DateTime.now();
        await into(earnedBadges).insertOnConflictUpdate(
          EarnedBadgesCompanion.insert(badgeId: badgeId, earnedAt: Value(now)),
        );
        await attachedDatabase.syncDao.enqueue(
          entity: 'earned_badges',
          entityKey: badgeId,
          payload: {
            'badge_id': badgeId,
            'earned_at': now.toUtc().toIso8601String(),
          },
        );
      });

  // ── User Progress KV ──

  // ── Merge from backend (pull) ──
  //
  // These apply remote state WITHOUT re-enqueueing to the outbox, and use
  // monotonic/domain-aware merges rather than blind overwrite, so pulling can
  // never lose local progress regardless of ordering.

  Future<void> mergeLessonProgress({
    required int lessonId,
    required int unitId,
    required bool isCompleted,
    required double bestScore,
    required int attempts,
    DateTime? lastAttempted,
  }) async {
    final existing =
        await (select(lessonProgress)
          ..where((l) => l.lessonId.equals(lessonId))).getSingleOrNull();
    if (existing == null) {
      await into(lessonProgress).insert(
        LessonProgressCompanion.insert(
          lessonId: Value(lessonId),
          unitId: unitId,
          isCompleted: Value(isCompleted),
          bestScore: Value(bestScore),
          attempts: Value(attempts),
          lastAttempted: Value(lastAttempted),
        ),
      );
      return;
    }
    await (update(lessonProgress)
      ..where((l) => l.lessonId.equals(lessonId))).write(
      LessonProgressCompanion(
        isCompleted: Value(existing.isCompleted || isCompleted),
        bestScore: Value(
          bestScore > existing.bestScore ? bestScore : existing.bestScore,
        ),
        attempts: Value(
          attempts > existing.attempts ? attempts : existing.attempts,
        ),
        lastAttempted: Value(_latest(existing.lastAttempted, lastAttempted)),
      ),
    );
  }

  Future<void> mergeBadge(String badgeId, DateTime earnedAt) async {
    final existing =
        await (select(earnedBadges)
          ..where((b) => b.badgeId.equals(badgeId))).getSingleOrNull();
    if (existing != null) return; // union: a badge is never un-earned
    await into(earnedBadges).insert(
      EarnedBadgesCompanion.insert(badgeId: badgeId, earnedAt: Value(earnedAt)),
    );
  }

  /// Merge a KV value from the backend. Known monotonic keys are combined;
  /// anything else takes the remote value (it's newer than our pull cursor).
  Future<void> mergeUserProgress(String key, String remoteValue) async {
    final local = await getProgressValue(key);
    String merged;
    if (local == null) {
      merged = remoteValue;
    } else if (key == 'longest_streak' || key == 'streak') {
      final a = int.tryParse(local) ?? 0;
      final b = int.tryParse(remoteValue) ?? 0;
      merged = (a > b ? a : b).toString();
    } else if (key == 'exams_passed') {
      merged = jsonEncode(_unionJsonList(local, remoteValue));
    } else {
      merged = remoteValue;
    }
    // Direct write, bypassing the outbox hook.
    await into(userProgress).insertOnConflictUpdate(
      UserProgressCompanion.insert(key: key, value: merged),
    );
  }

  DateTime? _latest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  List<String> _unionJsonList(String a, String b) {
    final set = <String>{};
    for (final s in [a, b]) {
      try {
        set.addAll((jsonDecode(s) as List<dynamic>).map((e) => e.toString()));
      } catch (_) {
        /* ignore malformed */
      }
    }
    return set.toList();
  }

  Future<String?> getProgressValue(String key) async {
    final row =
        await (select(userProgress)
          ..where((u) => u.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setProgressValue(
    String key,
    String value,
  ) => attachedDatabase.transaction(() async {
    await into(userProgress).insertOnConflictUpdate(
      UserProgressCompanion.insert(key: key, value: value),
    );
    await attachedDatabase.syncDao.enqueue(
      entity: 'user_progress',
      entityKey: key,
      // Server column is jsonb; value is stored as an app-defined string, so
      // wrap it to preserve it verbatim regardless of whether it's JSON.
      payload: {'key': key, 'value': _asJsonValue(value)},
    );
  });

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
