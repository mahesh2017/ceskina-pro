import 'dart:convert';

import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/gamification_state.dart';

part 'gamification_dao.g.dart';

/// Data access object for gamification state.
///
/// Single-row table keyed by 'primary'. The state is migrated from
/// SharedPreferences to Drift for transactional integrity and future
/// cross-device sync via the existing sync outbox.
@DriftAccessor(tables: [GamificationStateTable])
class GamificationDao extends DatabaseAccessor<AppDatabase>
    with _$GamificationDaoMixin {
  GamificationDao(super.db);

  static const _primaryKey = 'primary';

  /// Load the gamification state row, or null if it doesn't exist yet.
  Future<GamificationStateTableData?> load() async {
    final result =
        await (select(gamificationStateTable)
          ..where((t) => t.key.equals(_primaryKey))).getSingleOrNull();
    return result;
  }

  /// Persist a local change atomically with its sync-outbox mutation.
  Future<void> save({
    required int hearts,
    required int maxHearts,
    required int currentStreak,
    required int longestStreak,
    required int totalXp,
    required int dailyXp,
    required int dailyGoalXp,
    required int gems,
    required String earnedBadgesJson,
    DateTime? lastHeartRefill,
    required bool streakFreezeAvailable,
    String? lastOpenDate,
    String? dailyXpResetDate,
  }) => attachedDatabase.transaction(() async {
    final updatedAt = DateTime.now();
    await _write(
      hearts: hearts,
      maxHearts: maxHearts,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalXp: totalXp,
      dailyXp: dailyXp,
      dailyGoalXp: dailyGoalXp,
      gems: gems,
      earnedBadgesJson: earnedBadgesJson,
      lastHeartRefill: lastHeartRefill,
      streakFreezeAvailable: streakFreezeAvailable,
      lastOpenDate: lastOpenDate,
      dailyXpResetDate: dailyXpResetDate,
      updatedAt: updatedAt,
    );
    await attachedDatabase.syncDao.enqueue(
      entity: 'gamification_state',
      entityKey: _primaryKey,
      payload: {
        'key': _primaryKey,
        'hearts': hearts,
        'max_hearts': maxHearts,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_xp': totalXp,
        'daily_xp': dailyXp,
        'daily_goal_xp': dailyGoalXp,
        'gems': gems,
        'earned_badges': jsonDecode(earnedBadgesJson),
        'last_heart_refill': lastHeartRefill?.toUtc().toIso8601String(),
        'streak_freeze_available': streakFreezeAvailable,
        'last_open_date': lastOpenDate,
        'daily_xp_reset_date': dailyXpResetDate,
      },
    );
  });

  /// Apply the server-authoritative LWW row without re-enqueueing it.
  Future<void> mergeRemote({
    required int hearts,
    required int maxHearts,
    required int currentStreak,
    required int longestStreak,
    required int totalXp,
    required int dailyXp,
    required int dailyGoalXp,
    required int gems,
    required String earnedBadgesJson,
    DateTime? lastHeartRefill,
    required bool streakFreezeAvailable,
    String? lastOpenDate,
    String? dailyXpResetDate,
    required DateTime updatedAt,
  }) => _write(
    hearts: hearts,
    maxHearts: maxHearts,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalXp: totalXp,
    dailyXp: dailyXp,
    dailyGoalXp: dailyGoalXp,
    gems: gems,
    earnedBadgesJson: earnedBadgesJson,
    lastHeartRefill: lastHeartRefill,
    streakFreezeAvailable: streakFreezeAvailable,
    lastOpenDate: lastOpenDate,
    dailyXpResetDate: dailyXpResetDate,
    updatedAt: updatedAt,
  );

  Future<void> _write({
    required int hearts,
    required int maxHearts,
    required int currentStreak,
    required int longestStreak,
    required int totalXp,
    required int dailyXp,
    required int dailyGoalXp,
    required int gems,
    required String earnedBadgesJson,
    DateTime? lastHeartRefill,
    required bool streakFreezeAvailable,
    String? lastOpenDate,
    String? dailyXpResetDate,
    required DateTime updatedAt,
  }) async {
    await into(gamificationStateTable).insertOnConflictUpdate(
      GamificationStateTableCompanion.insert(
        key: _primaryKey,
        hearts: Value(hearts),
        maxHearts: Value(maxHearts),
        currentStreak: Value(currentStreak),
        longestStreak: Value(longestStreak),
        totalXp: Value(totalXp),
        dailyXp: Value(dailyXp),
        dailyGoalXp: Value(dailyGoalXp),
        gems: Value(gems),
        earnedBadges: Value(earnedBadgesJson),
        lastHeartRefill: Value(lastHeartRefill),
        streakFreezeAvailable: Value(streakFreezeAvailable),
        lastOpenDate: Value(lastOpenDate),
        dailyXpResetDate: Value(dailyXpResetDate),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  /// Watch the gamification state as a stream (for reactive providers).
  Stream<GamificationStateTableData?> watchState() {
    return (select(gamificationStateTable)
      ..where((t) => t.key.equals(_primaryKey))).watchSingleOrNull();
  }
}
