import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/gamification_state.dart';
import '../../domain/engines/gamification_engine.dart';
import 'database_providers.dart';

/// Keys for SharedPreferences storage.
const _kHearts = 'gamification_hearts';
const _kMaxHearts = 'gamification_max_hearts';
const _kCurrentStreak = 'gamification_current_streak';
const _kLongestStreak = 'gamification_longest_streak';
const _kTotalXp = 'gamification_total_xp';
const _kDailyXp = 'gamification_daily_xp';
const _kDailyGoalXp = 'gamification_daily_goal_xp';
const _kGems = 'gamification_gems';
const _kEarnedBadges = 'gamification_earned_badges';
const _kLastHeartRefill = 'gamification_last_heart_refill';
const _kStreakFreezeAvailable = 'gamification_streak_freeze';
const _kLastOpenDate = 'gamification_last_open_date';
const _kDailyXpResetDate = 'gamification_daily_xp_reset_date';

/// How often a missing heart regenerates.
const heartRegenInterval = Duration(minutes: 30);

/// Gamification state provider with full SharedPreferences persistence.
final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
  GamificationNotifier.new,
);

class GamificationNotifier extends Notifier<GamificationState> {
  final _engine = GamificationEngine();
  SharedPreferences? _prefs;
  late Future<void> _ready;

  @override
  GamificationState build() {
    _ready = _initAsync();
    return const GamificationState();
  }

  /// Initialize asynchronously — loads from SharedPreferences and checks
  /// streak, daily-XP rollover, and heart regeneration.
  Future<void> _initAsync() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadState();
    await _checkStreakOnOpen();
    await _rolloverDailyXpIfNeeded();
    await _checkHeartRegen();
  }

  /// All public mutators await this so a lesson/review finishing right
  /// after startup can't persist default state over the stored values.
  Future<void> _ensureReady() => _ready;

  /// Load persisted state from SharedPreferences.
  Future<void> _loadState() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final hearts = prefs.getInt(_kHearts) ?? 5;
    final maxHearts = prefs.getInt(_kMaxHearts) ?? 5;
    final currentStreak = prefs.getInt(_kCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_kLongestStreak) ?? 0;
    final totalXp = prefs.getInt(_kTotalXp) ?? 0;
    final dailyXp = prefs.getInt(_kDailyXp) ?? 0;
    final dailyGoalXp = prefs.getInt(_kDailyGoalXp) ?? 50;
    final gems = prefs.getInt(_kGems) ?? 0;
    final streakFreeze = prefs.getBool(_kStreakFreezeAvailable) ?? true;

    // Load earned badges
    final badgesJson = prefs.getString(_kEarnedBadges);
    final earnedBadges = <String>{};
    if (badgesJson != null) {
      final list = jsonDecode(badgesJson) as List<dynamic>;
      earnedBadges.addAll(list.cast<String>());
    }

    // Load last heart refill time
    final lastRefillStr = prefs.getString(_kLastHeartRefill);
    DateTime? lastHeartRefill;
    if (lastRefillStr != null) {
      lastHeartRefill = DateTime.tryParse(lastRefillStr);
    }

    state = GamificationState(
      hearts: hearts,
      maxHearts: maxHearts,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalXp: totalXp,
      dailyXp: dailyXp,
      dailyGoalXp: dailyGoalXp,
      gems: gems,
      earnedBadges: earnedBadges,
      lastHeartRefill: lastHeartRefill, // null is fine — no refill yet
      streakFreezeAvailable: streakFreeze,
    );
  }

  /// Check streak on app open — compare last activity date with today.
  /// Only breaks stale streaks; does NOT write today's date.
  /// The actual streak increment happens in _maybeIncrementStreak on first XP earn.
  Future<void> _checkStreakOnOpen() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivityStr = prefs.getString(_kLastOpenDate);

    if (lastActivityStr == null) {
      // First ever open — no streak to check, no date to write yet.
      // Streak will start at 1 on first XP earn.
      return;
    }

    final lastActivity = DateTime.tryParse(lastActivityStr);
    if (lastActivity == null) return;

    final lastActivityDay =
        DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
    final diffDays = _calendarDaysBetween(lastActivityDay, today);

    if (diffDays == 0) {
      // Same day — no streak change needed
      return;
    }

    if (diffDays == 1) {
      // Consecutive day — streak continues; increment will happen on XP earn.
      // Do NOT write today's date here — _maybeIncrementStreak will do that.
      return;
    }

    // Gap > 1 day — streak broken
    if (state.streakFreezeAvailable && diffDays == 2) {
      // Streak freeze saves a 1-day gap
      state = state.copyWith(streakFreezeAvailable: false);
      await prefs.setBool(_kStreakFreezeAvailable, false);
      // Don't write today's date — let _maybeIncrementStreak handle it on XP earn
      return;
    }

    // Streak broken — reset to 0
    state = state.copyWith(currentStreak: 0);
    await prefs.setInt(_kCurrentStreak, 0);
    // Don't write today's date — let _maybeIncrementStreak handle it
  }

  /// Reset daily XP when the calendar day has rolled over.
  Future<void> _rolloverDailyXpIfNeeded() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastResetStr = prefs.getString(_kDailyXpResetDate);
    final lastReset =
        lastResetStr != null ? DateTime.tryParse(lastResetStr) : null;

    if (lastReset != null) {
      final lastResetDay =
          DateTime(lastReset.year, lastReset.month, lastReset.day);
      if (lastResetDay == today) return; // Already reset today
    }

    state = state.copyWith(dailyXp: 0);
    await prefs.setString(_kDailyXpResetDate, today.toIso8601String());
    await prefs.setInt(_kDailyXp, 0);
  }

  /// Check if hearts should regenerate based on time elapsed.
  Future<void> _checkHeartRegen() async {
    if (state.hearts >= state.maxHearts) return;
    if (state.lastHeartRefill == null) return; // no refill timestamp yet

    final now = DateTime.now();
    final lastRefill = state.lastHeartRefill!;

    final elapsed = now.difference(lastRefill);
    final heartsToRegen = elapsed.inMinutes ~/ heartRegenInterval.inMinutes;

    if (heartsToRegen > 0) {
      final newHearts = (state.hearts + heartsToRegen).clamp(0, state.maxHearts);
      state = state.copyWith(
        hearts: newHearts,
        lastHeartRefill: now,
      );
      await _persist();
    }
  }

  /// Persist all state to SharedPreferences.
  Future<void> _persist() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();

    await prefs.setInt(_kHearts, state.hearts);
    await prefs.setInt(_kMaxHearts, state.maxHearts);
    await prefs.setInt(_kCurrentStreak, state.currentStreak);
    await prefs.setInt(_kLongestStreak, state.longestStreak);
    await prefs.setInt(_kTotalXp, state.totalXp);
    await prefs.setInt(_kDailyXp, state.dailyXp);
    await prefs.setInt(_kDailyGoalXp, state.dailyGoalXp);
    await prefs.setInt(_kGems, state.gems);
    await prefs.setBool(_kStreakFreezeAvailable, state.streakFreezeAvailable);
    await prefs.setString(
      _kEarnedBadges,
      jsonEncode(state.earnedBadges.toList()),
    );
    if (state.lastHeartRefill != null) {
      await prefs.setString(
        _kLastHeartRefill,
        state.lastHeartRefill!.toIso8601String(),
      );
    }
  }

  // ── Public API ──

  /// Called when a lesson is completed.
  Future<void> onLessonCompleted({required double accuracy}) async {
    await _ensureReady();
    await _rolloverDailyXpIfNeeded();

    final xp = _engine.calculateXp(
      actionType: XpActionType.lessonCompleted,
      accuracy: accuracy,
    );

    // Check if this is the first XP earned today → increment streak
    await _maybeIncrementStreak();

    state = state.copyWith(
      totalXp: state.totalXp + xp,
      dailyXp: state.dailyXp + xp,
    );

    await _persist();
    await checkProgressBadges();
  }

  /// Called when a mock exam is finished.
  Future<void> onMockExamCompleted() async {
    await _ensureReady();
    await _rolloverDailyXpIfNeeded();

    final xp = _engine.calculateXp(actionType: XpActionType.mockExamCompleted);

    await _maybeIncrementStreak();

    state = state.copyWith(
      totalXp: state.totalXp + xp,
      dailyXp: state.dailyXp + xp,
    );

    await _persist();
    await checkProgressBadges();
  }

  /// Called when the user gets a wrong answer in a lesson.
  /// Starts the regen clock the moment the first heart is lost.
  Future<int> onWrongAnswer() async {
    await _ensureReady();
    await _checkHeartRegen();

    final result = _engine.processWrongAnswer(state);
    state = state.copyWith(
      hearts: result.hearts,
      lastHeartRefill: state.lastHeartRefill ?? DateTime.now(),
    );
    await _persist();
    return result.hearts;
  }

  /// Set the daily XP goal.
  Future<void> setDailyGoal(int xp) async {
    await _ensureReady();
    state = state.copyWith(dailyGoalXp: xp);
    await _persist();
  }

  /// Called when a review session is completed.
  Future<void> onReviewSessionCompleted(int reviewCount) async {
    if (reviewCount <= 0) return;
    await _ensureReady();
    await _rolloverDailyXpIfNeeded();

    final xp = _engine.calculateXp(
      actionType: XpActionType.reviewSessionCompleted,
      reviewCount: reviewCount,
    );

    await _maybeIncrementStreak();

    state = state.copyWith(
      totalXp: state.totalXp + xp,
      dailyXp: state.dailyXp + xp,
    );

    await _persist();
    await checkProgressBadges();
  }

  /// Called when a pronunciation drill is completed.
  Future<void> onPronunciationDrill({required double accuracy}) async {
    await _ensureReady();
    await _rolloverDailyXpIfNeeded();

    final xp = _engine.calculateXp(
      actionType: XpActionType.pronunciationDrill,
      accuracy: accuracy,
    );

    await _maybeIncrementStreak();

    state = state.copyWith(
      totalXp: state.totalXp + xp,
      dailyXp: state.dailyXp + xp,
    );

    await _persist();
  }

  /// Manually refill one heart.
  Future<void> refillHeart() async {
    await _ensureReady();
    if (state.hearts < state.maxHearts) {
      state = state.copyWith(
        hearts: state.hearts + 1,
        lastHeartRefill: DateTime.now(),
      );
      await _persist();
    }
  }

  /// Refill hearts to full (e.g., using gems).
  Future<void> refillAllHearts() async {
    await _ensureReady();
    if (state.hearts < state.maxHearts) {
      state = state.copyWith(
        hearts: state.maxHearts,
        lastHeartRefill: DateTime.now(),
      );
      await _persist();
    }
  }

  /// Re-check timed heart regeneration (e.g., when a screen opens).
  Future<void> refreshHearts() async {
    await _ensureReady();
    await _checkHeartRegen();
  }

  /// Award a badge if not already earned.
  Future<void> awardBadge(String badgeId, int xpReward) async {
    await _ensureReady();
    if (state.earnedBadges.contains(badgeId)) return;

    state = state.copyWith(
      earnedBadges: {...state.earnedBadges, badgeId},
      totalXp: state.totalXp + xpReward,
      dailyXp: state.dailyXp + xpReward,
    );
    await _persist();

    // Mirror into the database so progress snapshots see it too.
    try {
      await ref.read(databaseProvider).progressDao.earnBadge(badgeId);
    } catch (_) {
      // Prefs remain the source of truth for badge display.
    }
  }

  /// Evaluate all badge criteria against current progress and award
  /// anything newly earned. Called after lessons, reviews, and exams.
  Future<void> checkProgressBadges() async {
    await _ensureReady();
    try {
      final progressRepo = ref.read(progressRepositoryProvider);
      final dbSnapshot = await progressRepo.getSnapshot();

      // Merge DB-derived progress with prefs-tracked streak and badges.
      final snapshot = ProgressSnapshot(
        unitScores: dbSnapshot.unitScores,
        longestStreak: state.longestStreak,
        examsPassed: dbSnapshot.examsPassed,
        earnedBadges: state.earnedBadges,
        customValues: dbSnapshot.customValues,
      );

      for (final badge in _engine.checkBadges(snapshot)) {
        await awardBadge(badge.id, badge.xpReward);
      }
    } catch (_) {
      // Badge evaluation must never break the learning flow.
    }
  }

  /// Force reload from storage (e.g., after importing settings).
  Future<void> reload() async {
    await _ensureReady();
    await _loadState();
  }

  // ── Private helpers ──

  /// Whole calendar days between two dates, immune to DST hour-length
  /// changes (consecutive local midnights can be 23h or 25h apart, which
  /// would make `difference().inDays` truncate a real day-gap to 0).
  static int _calendarDaysBetween(DateTime a, DateTime b) {
    final ua = DateTime.utc(a.year, a.month, a.day);
    final ub = DateTime.utc(b.year, b.month, b.day);
    return ub.difference(ua).inDays;
  }

  /// Increment streak if this is the first XP earned today.
  Future<bool> _maybeIncrementStreak() async {
    final prefs = _prefs;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastOpenStr = prefs?.getString(_kLastOpenDate);
    if (lastOpenStr != null) {
      final lastOpen = DateTime.tryParse(lastOpenStr);
      if (lastOpen != null) {
        final lastOpenDay =
            DateTime(lastOpen.year, lastOpen.month, lastOpen.day);
        if (lastOpenDay == today) {
          // Already earned XP today — don't increment streak
          return false;
        }
      }
    }

    // First XP today — increment streak
    final newStreak = state.currentStreak + 1;
    final newLongest =
        newStreak > state.longestStreak ? newStreak : state.longestStreak;

    state = state.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      streakFreezeAvailable: true, // Earn back freeze on new day
    );

    await prefs?.setString(_kLastOpenDate, today.toIso8601String());
    await prefs?.setBool(_kStreakFreezeAvailable, true);

    // Mirror the streak into the database KV store so progress
    // snapshots (badge checks, stats) see the same numbers.
    try {
      await ref
          .read(progressRepositoryProvider)
          .updateStreak(newStreak, newLongest);
    } catch (_) {
      // Prefs remain the source of truth.
    }
    return true;
  }
}
