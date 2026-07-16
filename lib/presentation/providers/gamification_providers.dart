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

/// Gamification state provider with full SharedPreferences persistence.
final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
  GamificationNotifier.new,
);

class GamificationNotifier extends Notifier<GamificationState> {
  final _engine = GamificationEngine();
  SharedPreferences? _prefs;

  @override
  GamificationState build() {
    // Load synchronously from cached prefs if available
    _initAsync();
    return const GamificationState();
  }

  /// Initialize asynchronously — loads from SharedPreferences and checks streak.
  void _initAsync() {
    Future(() async {
      _prefs = await SharedPreferences.getInstance();
      await _loadState();
      await _checkStreakOnOpen();
      _checkHeartRegen();
    });
  }

  /// Load persisted state from SharedPreferences.
  Future<void> _loadState() async {
    if (_prefs == null) return;

    final hearts = _prefs!.getInt(_kHearts) ?? 5;
    final maxHearts = _prefs!.getInt(_kMaxHearts) ?? 5;
    final currentStreak = _prefs!.getInt(_kCurrentStreak) ?? 0;
    final longestStreak = _prefs!.getInt(_kLongestStreak) ?? 0;
    final totalXp = _prefs!.getInt(_kTotalXp) ?? 0;
    final dailyXp = _prefs!.getInt(_kDailyXp) ?? 0;
    final dailyGoalXp = _prefs!.getInt(_kDailyGoalXp) ?? 50;
    final gems = _prefs!.getInt(_kGems) ?? 0;
    final streakFreeze = _prefs!.getBool(_kStreakFreezeAvailable) ?? true;

    // Load earned badges
    final badgesJson = _prefs!.getString(_kEarnedBadges);
    final earnedBadges = <String>{};
    if (badgesJson != null) {
      final list = jsonDecode(badgesJson) as List<dynamic>;
      earnedBadges.addAll(list.cast<String>());
    }

    // Load last heart refill time
    final lastRefillStr = _prefs!.getString(_kLastHeartRefill);
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
    if (_prefs == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivityStr = _prefs!.getString(_kLastOpenDate);

    if (lastActivityStr == null) {
      // First ever open — no streak to check, no date to write yet.
      // Streak will start at 1 on first XP earn.
      return;
    }

    final lastActivity = DateTime.tryParse(lastActivityStr);
    if (lastActivity == null) return;

    final lastActivityDay =
        DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
    final diffDays = today.difference(lastActivityDay).inDays;

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
      await _prefs!.setBool(_kStreakFreezeAvailable, false);
      // Don't write today's date — let _maybeIncrementStreak handle it on XP earn
      return;
    }

    // Streak broken — reset to 0
    state = state.copyWith(currentStreak: 0);
    await _prefs!.setInt(_kCurrentStreak, 0);
    // Don't write today's date — let _maybeIncrementStreak handle it
  }

  /// Check if hearts should regenerate based on time elapsed.
  void _checkHeartRegen() {
    if (state.hearts >= state.maxHearts) return;
    if (state.lastHeartRefill == null) return; // no refill timestamp yet

    final now = DateTime.now();
    final lastRefill = state.lastHeartRefill!;
    const regenInterval = Duration(minutes: 30);

    final elapsed = now.difference(lastRefill);
    final heartsToRegen = elapsed.inMinutes ~/ regenInterval.inMinutes;

    if (heartsToRegen > 0) {
      final newHearts = (state.hearts + heartsToRegen).clamp(0, state.maxHearts);
      state = state.copyWith(
        hearts: newHearts,
        lastHeartRefill: now,
      );
      _persist();
    }
  }

  /// Persist all state to SharedPreferences.
  Future<void> _persist() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    await _prefs!.setInt(_kHearts, state.hearts);
    await _prefs!.setInt(_kMaxHearts, state.maxHearts);
    await _prefs!.setInt(_kCurrentStreak, state.currentStreak);
    await _prefs!.setInt(_kLongestStreak, state.longestStreak);
    await _prefs!.setInt(_kTotalXp, state.totalXp);
    await _prefs!.setInt(_kDailyXp, state.dailyXp);
    await _prefs!.setInt(_kDailyGoalXp, state.dailyGoalXp);
    await _prefs!.setInt(_kGems, state.gems);
    await _prefs!.setBool(_kStreakFreezeAvailable, state.streakFreezeAvailable);
    await _prefs!.setString(
      _kEarnedBadges,
      jsonEncode(state.earnedBadges.toList()),
    );
    if (state.lastHeartRefill != null) {
      await _prefs!.setString(
        _kLastHeartRefill,
        state.lastHeartRefill!.toIso8601String(),
      );
    }
  }

  // ── Public API ──

  /// Called when a lesson is completed.
  void onLessonCompleted({required double accuracy}) {
    final xp = _engine.calculateXp(
      actionType: XpActionType.lessonCompleted,
      accuracy: accuracy,
    );

    // Check if this is the first XP earned today → increment streak
    final wasStreakIncremented = _maybeIncrementStreak();

    state = state.copyWith(
      totalXp: state.totalXp + xp,
      dailyXp: state.dailyXp + xp,
    );

    // Check for streak badges
    _checkStreakBadges();

    _persist();
  }

  /// Called when the user gets a wrong answer in a lesson.
  void onWrongAnswer() {
    final result = _engine.processWrongAnswer(state);
    state = state.copyWith(hearts: result.hearts);
    _persist();
  }

  /// Called when a review session is completed.
  void onReviewSessionCompleted(int reviewCount) {
    final xp = _engine.calculateXp(
      actionType: XpActionType.reviewSessionCompleted,
      reviewCount: reviewCount,
    );

    _maybeIncrementStreak();

    state = state.copyWith(
      totalXp: state.totalXp + xp,
      dailyXp: state.dailyXp + xp,
    );

    _checkStreakBadges();
    _persist();
  }

  /// Manually refill one heart.
  void refillHeart() {
    if (state.hearts < state.maxHearts) {
      state = state.copyWith(
        hearts: state.hearts + 1,
        lastHeartRefill: DateTime.now(),
      );
      _persist();
    }
  }

  /// Refill hearts to full (e.g., using gems).
  void refillAllHearts() {
    if (state.hearts < state.maxHearts) {
      state = state.copyWith(
        hearts: state.maxHearts,
        lastHeartRefill: DateTime.now(),
      );
      _persist();
    }
  }

  /// Reset daily XP (called at midnight or on new day detection).
  void resetDailyXp() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if we already reset for today
    _prefs?.getString(_kDailyXpResetDate);
    final lastResetStr = _prefs?.getString(_kDailyXpResetDate);
    final lastReset = lastResetStr != null
        ? DateTime.tryParse(lastResetStr)
        : null;

    if (lastReset != null) {
      final lastResetDay =
          DateTime(lastReset.year, lastReset.month, lastReset.day);
      if (lastResetDay == today) return; // Already reset today
    }

    state = state.copyWith(dailyXp: 0);
    _prefs?.setString(_kDailyXpResetDate, today.toIso8601String());
    _persist();
  }

  /// Award a badge if criteria is met.
  void awardBadge(String badgeId, int xpReward) {
    if (state.earnedBadges.contains(badgeId)) return;

    state = state.copyWith(
      earnedBadges: {...state.earnedBadges, badgeId},
      totalXp: state.totalXp + xpReward,
      dailyXp: state.dailyXp + xpReward,
    );
    _persist();
  }

  /// Force reload from storage (e.g., after importing settings).
  Future<void> reload() async {
    await _loadState();
  }

  // ── Private helpers ──

  /// Increment streak if this is the first XP earned today.
  bool _maybeIncrementStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastOpenStr = _prefs?.getString(_kLastOpenDate);
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

    _prefs?.setString(_kLastOpenDate, today.toIso8601String());
    _prefs?.setBool(_kStreakFreezeAvailable, true);
    return true;
  }

  /// Check and award streak-based badges.
  void _checkStreakBadges() {
    if (state.currentStreak >= 7 && !state.earnedBadges.contains('streak_7')) {
      awardBadge('streak_7', 20);
    }
    if (state.currentStreak >= 30 &&
        !state.earnedBadges.contains('streak_30')) {
      awardBadge('streak_30', 50);
    }
  }
}