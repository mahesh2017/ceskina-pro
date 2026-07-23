enum LearningSkill {
  reading,
  listening,
  writing,
  speaking,
  vocabulary,
  grammar,
  interaction,
}

enum LearningPhase {
  model,
  notice,
  retrieve,
  use,
  repair,
  vary,
  delayedTransfer,
}

enum SupportKind { hint, transcript, translation, replay, modelAnswer }

/// One immutable observation. Correctness and support dependence remain
/// separate so a scaffolded answer cannot masquerade as independent recall.
class LearningEvidence {
  final String evidenceId;
  final int lessonId;
  final int? exerciseId;
  final LearningSkill skill;
  final LearningPhase phase;
  final bool correct;
  final bool novelTask;
  final Set<SupportKind> supports;
  final Set<String> conceptKeys;
  final Duration responseLatency;
  final DateTime observedAt;

  const LearningEvidence({
    required this.evidenceId,
    required this.lessonId,
    this.exerciseId,
    required this.skill,
    required this.phase,
    required this.correct,
    required this.novelTask,
    this.supports = const {},
    this.conceptKeys = const {},
    required this.responseLatency,
    required this.observedAt,
  });

  bool get independent => supports.isEmpty;
  bool get isDelayedTransfer =>
      phase == LearningPhase.delayedTransfer && novelTask;
}
