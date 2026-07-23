import '../entities/learning_evidence.dart';

enum FeedbackStep {
  signal,
  selfRepair,
  cue,
  explanation,
  immediateVariant,
  spacedAnalogue,
  novelTask,
}

class LearningLoopState {
  final LearningPhase phase;
  final FeedbackStep? feedbackStep;
  final int unsuccessfulAttempts;
  final DateTime? delayedTransferDue;

  const LearningLoopState({
    required this.phase,
    this.feedbackStep,
    this.unsuccessfulAttempts = 0,
    this.delayedTransferDue,
  });
}

/// Executable form of model → notice → retrieve → use → repair → vary →
/// delayed transfer, including a graduated feedback ladder.
class LearningLoopEngine {
  const LearningLoopEngine();

  LearningLoopState begin() =>
      const LearningLoopState(phase: LearningPhase.model);

  LearningLoopState advance(
    LearningLoopState state, {
    required bool correct,
    required bool independent,
    required DateTime now,
  }) {
    if (!correct) {
      final failures = state.unsuccessfulAttempts + 1;
      return LearningLoopState(
        phase: LearningPhase.repair,
        unsuccessfulAttempts: failures,
        feedbackStep: switch (failures) {
          1 => FeedbackStep.signal,
          2 => FeedbackStep.selfRepair,
          3 => FeedbackStep.cue,
          _ => FeedbackStep.explanation,
        },
      );
    }

    return switch (state.phase) {
      LearningPhase.model => const LearningLoopState(
        phase: LearningPhase.notice,
      ),
      LearningPhase.notice => const LearningLoopState(
        phase: LearningPhase.retrieve,
      ),
      LearningPhase.retrieve => LearningLoopState(
        phase: independent ? LearningPhase.use : LearningPhase.repair,
        feedbackStep: independent ? null : FeedbackStep.immediateVariant,
      ),
      LearningPhase.repair => const LearningLoopState(
        phase: LearningPhase.vary,
        feedbackStep: FeedbackStep.immediateVariant,
      ),
      LearningPhase.use || LearningPhase.vary => LearningLoopState(
        phase: LearningPhase.delayedTransfer,
        feedbackStep: FeedbackStep.spacedAnalogue,
        delayedTransferDue: now.add(const Duration(days: 7)),
      ),
      LearningPhase.delayedTransfer => const LearningLoopState(
        phase: LearningPhase.delayedTransfer,
        feedbackStep: FeedbackStep.novelTask,
      ),
    };
  }
}
