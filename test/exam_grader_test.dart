import 'package:flutter_test/flutter_test.dart';
import 'package:ceskina_pro/domain/engines/exam_grader.dart';
import 'package:ceskina_pro/domain/entities/enums.dart';
import 'package:ceskina_pro/domain/repositories/exam_repository.dart';

MockExam _twoSectionExam() {
  return const MockExam(
    level: ExamLevel.a1,
    totalTimeMinutes: 30,
    sections: [
      MockExamSection(
        type: ExamSectionType.reading,
        timeLimitMinutes: 8,
        questions: [
          {'prompt': 'r1', 'options': [], 'correct_answer': 0},
          {'prompt': 'r2', 'options': [], 'correct_answer': 1},
        ],
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.listening,
        timeLimitMinutes: 8,
        questions: [
          {'prompt': 'l1', 'options': [], 'correct_answer': 2},
          {'prompt': 'l2', 'options': [], 'correct_answer': 3},
        ],
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.writing,
        timeLimitMinutes: 10,
        questions: [
          {'prompt': 'w1'},
        ],
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.speaking,
        timeLimitMinutes: 5,
        questions: [
          {'prompt': 's1', 'target_text': 'Ahoj'},
        ],
        maxScore: 100,
      ),
    ],
  );
}

void main() {
  group('ExamGrader', () {
    final grader = ExamGrader();

    test('sections are graded independently (regression: shared answer map)',
        () {
      final exam = _twoSectionExam();
      // Reading answered perfectly; listening answered with reading's
      // answers — must NOT be counted as listening being correct.
      final scores = grader.grade(
        exam: exam,
        answers: {
          0: {0: 0, 1: 1}, // reading: both correct
          1: {0: 0, 1: 1}, // listening: both wrong (correct are 2 and 3)
        },
      );

      expect(scores.reading, 100);
      expect(scores.listening, 0);
    });

    test('unanswered questions never count as correct (null == null)', () {
      final exam = _twoSectionExam();
      final scores = grader.grade(exam: exam, answers: {});

      expect(scores.reading, 0);
      expect(scores.listening, 0);
      expect(scores.writing, 0);
      expect(scores.speaking, 0);
      expect(scores.total, 0);
      expect(scores.passed, isFalse);
    });

    test('writing and speaking use externally provided scores', () {
      final exam = _twoSectionExam();
      final scores = grader.grade(
        exam: exam,
        answers: {
          0: {0: 0, 1: 1},
          1: {0: 2, 1: 3},
        },
        writingScore: 80,
        speakingScore: 60,
      );

      expect(scores.writing, 80);
      expect(scores.speaking, 60);
      expect(scores.total, (100 + 100 + 80 + 60) ~/ 4);
      expect(scores.passed, isTrue);
    });

    test('external scores are clamped to 0-100', () {
      final exam = _twoSectionExam();
      final scores = grader.grade(
        exam: exam,
        answers: {},
        writingScore: 250,
        speakingScore: -10,
      );

      expect(scores.writing, 100);
      expect(scores.speaking, 0);
    });

    test('partial credit rounds per section', () {
      final exam = _twoSectionExam();
      final scores = grader.grade(
        exam: exam,
        answers: {
          0: {0: 0}, // 1 of 2 reading correct
        },
      );

      expect(scores.reading, 50);
    });

    test('pass threshold is 60 overall', () {
      final exam = _twoSectionExam();
      final passing = grader.grade(
        exam: exam,
        answers: {
          0: {0: 0, 1: 1},
          1: {0: 2, 1: 3},
        },
        writingScore: 20,
        speakingScore: 20,
      );
      // (100+100+20+20)/4 = 60 — exactly at threshold
      expect(passing.total, 60);
      expect(passing.passed, isTrue);

      final failing = grader.grade(
        exam: exam,
        answers: {
          0: {0: 0, 1: 1},
          1: {0: 2, 1: 3},
        },
        writingScore: 20,
        speakingScore: 16,
      );
      expect(failing.passed, isFalse);
    });
  });
}
