import '../entities/enums.dart';
import '../repositories/exam_repository.dart';

/// Per-section and overall scores for a graded mock exam (all 0-100).
class ExamScores {
  final int reading;
  final int listening;
  final int writing;
  final int speaking;
  final int total;
  final bool passed;

  const ExamScores({
    required this.reading,
    required this.listening,
    required this.writing,
    required this.speaking,
    required this.total,
    required this.passed,
  });
}

/// Pure grading logic for mock CCE exams — no I/O, fully testable.
///
/// Multiple-choice sections (reading, listening) are graded against each
/// question's `correct_answer`. Writing and speaking scores are produced
/// elsewhere (AI evaluation / pronunciation scoring) and passed in.
class ExamGrader {
  /// Minimum overall score to pass, matching the CCE's 60% threshold.
  static const passThreshold = 60;

  /// Grade an exam.
  ///
  /// [answers] is keyed by section index, then question index within that
  /// section — sections must never share answer slots.
  ExamScores grade({
    required MockExam exam,
    required Map<int, Map<int, dynamic>> answers,
    int? writingScore,
    int? speakingScore,
  }) {
    var reading = 0;
    var listening = 0;

    for (var s = 0; s < exam.sections.length; s++) {
      final section = exam.sections[s];
      switch (section.type) {
        case ExamSectionType.reading:
          reading = _gradeChoiceSection(section, answers[s] ?? const {});
        case ExamSectionType.listening:
          listening = _gradeChoiceSection(section, answers[s] ?? const {});
        case ExamSectionType.writing:
        case ExamSectionType.speaking:
          break; // scored externally
      }
    }

    final writing = (writingScore ?? 0).clamp(0, 100);
    final speaking = (speakingScore ?? 0).clamp(0, 100);
    final total = ((reading + listening + writing + speaking) / 4).round();

    return ExamScores(
      reading: reading,
      listening: listening,
      writing: writing,
      speaking: speaking,
      total: total,
      passed: total >= passThreshold,
    );
  }

  int _gradeChoiceSection(
      MockExamSection section, Map<int, dynamic> sectionAnswers,) {
    if (section.questions.isEmpty) return 0;

    var correct = 0;
    for (var q = 0; q < section.questions.length; q++) {
      final correctAnswer = section.questions[q]['correct_answer'];
      // Unanswered questions or questions without a key are wrong —
      // never let null == null count as correct.
      if (correctAnswer == null) continue;
      final userAnswer = sectionAnswers[q];
      if (userAnswer != null && userAnswer == correctAnswer) {
        correct++;
      }
    }

    return ((correct / section.questions.length) * 100).round();
  }
}
