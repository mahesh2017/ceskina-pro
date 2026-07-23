import 'exercise_outcome.dart';

enum ExerciseEvidencePhase {
  initial('initial'),
  immediateRepair('immediate_repair'),
  delayedTransfer('delayed_transfer');

  const ExerciseEvidencePhase(this.storageValue);
  final String storageValue;
}

class ExerciseAttemptEvidence {
  final String presentationId;
  final int exerciseId;
  final ExerciseEvidencePhase phase;
  final ExerciseOutcome outcome;
  final DateTime answeredAt;

  const ExerciseAttemptEvidence({
    required this.presentationId,
    required this.exerciseId,
    required this.phase,
    required this.outcome,
    required this.answeredAt,
  });
}
