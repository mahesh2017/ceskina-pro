import '../entities/exam_result.dart';
import '../entities/enums.dart';

/// Mock exam definition.
class MockExam {
  final ExamLevel level;
  final List<MockExamSection> sections;
  final int totalTimeMinutes;

  const MockExam({
    required this.level,
    required this.sections,
    required this.totalTimeMinutes,
  });
}

/// A section of a mock exam.
class MockExamSection {
  final ExamSectionType type;
  final int timeLimitMinutes;
  final List<Map<String, dynamic>> questions;
  final int maxScore;

  const MockExamSection({
    required this.type,
    required this.timeLimitMinutes,
    required this.questions,
    required this.maxScore,
  });
}

/// Abstract interface for exam data access.
abstract class ExamRepository {
  Future<MockExam> getMockExam(ExamLevel level);
  Future<ExamResult> saveResult(ExamResult result);
  Future<List<ExamResult>> getResults(ExamLevel level);
}