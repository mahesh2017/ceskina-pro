import 'package:ceskina_pro/domain/engines/learning_router.dart';
import 'package:ceskina_pro/domain/entities/learning_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delayed novel-task failure outranks linear next lesson', () {
    const router = LearningRouter();
    final route = router.select(
      candidates: const [
        LearningCandidate(
          lessonId: 1,
          order: 1,
          completed: true,
          skills: {LearningSkill.interaction},
          conceptKeys: {'register'},
        ),
        LearningCandidate(
          lessonId: 2,
          order: 2,
          completed: false,
          skills: {LearningSkill.reading},
        ),
      ],
      accessibleLessonIds: const {1, 2},
      evidence: [
        LearningEvidence(
          evidenceId: 'transfer-fail',
          lessonId: 1,
          skill: LearningSkill.interaction,
          phase: LearningPhase.delayedTransfer,
          correct: false,
          novelTask: true,
          conceptKeys: const {'register'},
          responseLatency: const Duration(seconds: 30),
          observedAt: DateTime.utc(2026, 7, 30),
        ),
      ],
    );
    expect(route?.lessonId, 1);
    expect(route?.reason, 'Delayed transfer needs repair');
  });

  test('engagement rewards cannot influence routing contract', () {
    const router = LearningRouter();
    final route = router.select(
      candidates: const [
        LearningCandidate(
          lessonId: 7,
          order: 7,
          completed: false,
          skills: {LearningSkill.listening},
        ),
      ],
      accessibleLessonIds: const {7},
      evidence: const [],
    );
    expect(route?.lessonId, 7);
  });
}
