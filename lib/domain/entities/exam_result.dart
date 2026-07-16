import 'enums.dart';

/// Result of a mock exam.
class ExamResult {
  final int id;
  final ExamLevel level;
  final DateTime takenAt;
  final int readingScore; // 0-100
  final int listeningScore; // 0-100
  final int writingScore; // 0-100
  final int speakingScore; // 0-100
  final int totalScore; // 0-100
  final bool passed;
  final Map<String, dynamic>? details;

  const ExamResult({
    required this.id,
    required this.level,
    required this.takenAt,
    required this.readingScore,
    required this.listeningScore,
    required this.writingScore,
    required this.speakingScore,
    required this.totalScore,
    required this.passed,
    this.details,
  });

  int get sectionAverage =>
      ((readingScore + listeningScore + writingScore + speakingScore) / 4).round();
}