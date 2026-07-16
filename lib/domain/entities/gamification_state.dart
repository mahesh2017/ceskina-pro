/// Gamification state.
class GamificationState {
  final int hearts;
  final int maxHearts;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int dailyXp;
  final int dailyGoalXp;
  final int gems;
  final Set<String> earnedBadges;
  final DateTime lastHeartRefill;
  final bool streakFreezeAvailable;

  const GamificationState({
    this.hearts = 5,
    this.maxHearts = 5,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalXp = 0,
    this.dailyXp = 0,
    this.dailyGoalXp = 50,
    this.gems = 0,
    this.earnedBadges = const {},
    this.lastHeartRefill = const _NullDateTime(),
    this.streakFreezeAvailable = true,
  });

  GamificationState copyWith({
    int? hearts,
    int? maxHearts,
    int? currentStreak,
    int? longestStreak,
    int? totalXp,
    int? dailyXp,
    int? dailyGoalXp,
    int? gems,
    Set<String>? earnedBadges,
    DateTime? lastHeartRefill,
    bool? streakFreezeAvailable,
  }) {
    return GamificationState(
      hearts: hearts ?? this.hearts,
      maxHearts: maxHearts ?? this.maxHearts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXp: totalXp ?? this.totalXp,
      dailyXp: dailyXp ?? this.dailyXp,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      gems: gems ?? this.gems,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      lastHeartRefill: lastHeartRefill ?? this.lastHeartRefill,
      streakFreezeAvailable: streakFreezeAvailable ?? this.streakFreezeAvailable,
    );
  }

  bool get isGameOver => hearts <= 0;
  bool get dailyGoalMet => dailyXp >= dailyGoalXp;
}

class _NullDateTime implements DateTime {
  const _NullDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Badge definition.
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final BadgeCriteria criteria;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.criteria,
  });

  static const List<Badge> all = [
    Badge(
      id: 'case_nominative',
      name: 'First Case',
      description: 'Complete Unit 3 with 80%+',
      icon: '🏆',
      xpReward: 10,
      criteria: BadgeCriteria(unitId: 3, minAccuracy: 0.8),
    ),
    Badge(
      id: 'case_accusative',
      name: 'Object Master',
      description: 'Complete Unit 6 with 80%+',
      icon: '🎯',
      xpReward: 15,
      criteria: BadgeCriteria(unitId: 6, minAccuracy: 0.8),
    ),
    Badge(
      id: 'verb_byt',
      name: 'To Be Master',
      description: 'Perfect conjugation of být',
      icon: '⭐',
      xpReward: 10,
      criteria: BadgeCriteria(customKey: 'byt_conjugation', minValue: 1.0),
    ),
    Badge(
      id: 'streak_7',
      name: 'Week Warrior',
      description: '7-day streak',
      icon: '🔥',
      xpReward: 20,
      criteria: BadgeCriteria(minStreak: 7),
    ),
    Badge(
      id: 'streak_30',
      name: 'Monthly Master',
      description: '30-day streak',
      icon: '🔥',
      xpReward: 50,
      criteria: BadgeCriteria(minStreak: 30),
    ),
    Badge(
      id: 'mock_a1_pass',
      name: 'A1 Certified',
      description: 'Pass CCE-A1 mock exam',
      icon: '🎓',
      xpReward: 50,
      criteria: BadgeCriteria(examPassed: 'a1'),
    ),
    Badge(
      id: 'mock_a2_pass',
      name: 'A2 Certified',
      description: 'Pass CCE-A2 mock exam',
      icon: '🎓',
      xpReward: 100,
      criteria: BadgeCriteria(examPassed: 'a2'),
    ),
  ];
}

/// Criteria for unlocking a badge.
class BadgeCriteria {
  final int? unitId;
  final double? minAccuracy;
  final int? minStreak;
  final String? examPassed;
  final String? customKey;
  final double? minValue;

  const BadgeCriteria({
    this.unitId,
    this.minAccuracy,
    this.minStreak,
    this.examPassed,
    this.customKey,
    this.minValue,
  });

  bool isMet(ProgressSnapshot progress) {
    if (unitId != null && minAccuracy != null) {
      final unitScore = progress.unitScores[unitId];
      if (unitScore == null || unitScore < minAccuracy!) return false;
    }
    if (minStreak != null) {
      if (progress.longestStreak < minStreak!) return false;
    }
    if (examPassed != null) {
      if (!progress.examsPassed.contains(examPassed)) return false;
    }
    return true;
  }
}

/// A snapshot of learner progress for badge evaluation.
class ProgressSnapshot {
  final Map<int, double> unitScores;
  final int longestStreak;
  final Set<String> examsPassed;
  final Set<String> earnedBadges;
  final double a1CompletionRate;
  final double a2CompletionRate;

  const ProgressSnapshot({
    this.unitScores = const {},
    this.longestStreak = 0,
    this.examsPassed = const {},
    this.earnedBadges = const {},
    this.a1CompletionRate = 0.0,
    this.a2CompletionRate = 0.0,
  });
}

/// League tiers.
enum League {
  bronze('Bronze', 0),
  silver('Silver', 100),
  gold('Gold', 300),
  platinum('Platinum', 600),
  diamond('Diamond', 1000);

  const League(this.label, this.xpThreshold);
  final String label;
  final int xpThreshold;
}