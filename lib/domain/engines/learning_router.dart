import '../entities/learning_evidence.dart';

class LearningCandidate {
  final int lessonId;
  final int order;
  final bool completed;
  final Set<LearningSkill> skills;
  final Set<String> conceptKeys;

  const LearningCandidate({
    required this.lessonId,
    required this.order,
    required this.completed,
    required this.skills,
    this.conceptKeys = const {},
  });
}

class LearningRoute {
  final int lessonId;
  final double priority;
  final String reason;

  const LearningRoute({
    required this.lessonId,
    required this.priority,
    required this.reason,
  });
}

/// Chooses next work from observable need. XP and streaks are intentionally
/// absent. Delayed novel-task failures outrank same-session performance.
class LearningRouter {
  const LearningRouter();

  LearningRoute? select({
    required List<LearningCandidate> candidates,
    required Set<int> accessibleLessonIds,
    required List<LearningEvidence> evidence,
  }) {
    LearningRoute? best;
    for (final candidate in candidates) {
      if (!accessibleLessonIds.contains(candidate.lessonId)) continue;
      final relevant =
          evidence
              .where(
                (item) =>
                    item.lessonId == candidate.lessonId ||
                    item.conceptKeys.any(candidate.conceptKeys.contains),
              )
              .toList();
      final delayed = relevant.where((item) => item.isDelayedTransfer).toList();
      final independent = relevant.where((item) => item.independent).toList();
      final supportCount = relevant.where((item) => !item.independent).length;
      final failures = independent.where((item) => !item.correct).length;
      final delayedFailures = delayed.where((item) => !item.correct).length;

      var priority = candidate.completed ? 0.0 : 12.0;
      priority += delayedFailures * 100;
      priority += failures * 12;
      priority += supportCount * 5;
      if (relevant.isEmpty) priority += 6;
      priority -= candidate.order / 1000;

      final reason =
          delayedFailures > 0
              ? 'Delayed transfer needs repair'
              : failures > 0
              ? 'Independent practice needs reinforcement'
              : supportCount > 0
              ? 'Reduce support dependence'
              : candidate.completed
              ? 'Maintain retained performance'
              : 'Continue with new accessible work';
      if (best == null || priority > best.priority) {
        best = LearningRoute(
          lessonId: candidate.lessonId,
          priority: priority,
          reason: reason,
        );
      }
    }
    return best;
  }
}
