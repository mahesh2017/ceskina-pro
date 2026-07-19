import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/exam_result.dart' as entity;
import '../../domain/repositories/exam_repository.dart';
import '../database/database.dart' as db;

/// Concrete implementation of [ExamRepository] using Drift.
///
/// Exam content is currently bundled in code ([buildSampleExam]);
/// results are persisted to the `exam_results` table.
class DriftExamRepository implements ExamRepository {
  final db.AppDatabase _db;

  DriftExamRepository(this._db);

  @override
  Future<MockExam> getMockExam(ExamLevel level) async {
    return buildSampleExam(level);
  }

  @override
  Future<entity.ExamResult> saveResult(entity.ExamResult result) async {
    final id = await _db.into(_db.examResults).insert(
          db.ExamResultsCompanion.insert(
            level: result.level.name,
            takenAt: Value(result.takenAt),
            readingScore: Value(result.readingScore),
            listeningScore: Value(result.listeningScore),
            writingScore: Value(result.writingScore),
            speakingScore: Value(result.speakingScore),
            totalScore: Value(result.totalScore),
            passed: Value(result.passed),
            details: Value(
                result.details != null ? jsonEncode(result.details) : null,),
          ),
        );

    return entity.ExamResult(
      id: id,
      level: result.level,
      takenAt: result.takenAt,
      readingScore: result.readingScore,
      listeningScore: result.listeningScore,
      writingScore: result.writingScore,
      speakingScore: result.speakingScore,
      totalScore: result.totalScore,
      passed: result.passed,
      details: result.details,
    );
  }

  @override
  Future<List<entity.ExamResult>> getResults(ExamLevel level) async {
    final rows = await (_db.select(_db.examResults)
          ..where((r) => r.level.equals(level.name))
          ..orderBy([(r) => OrderingTerm.desc(r.takenAt)]))
        .get();

    return rows
        .map((r) => entity.ExamResult(
              id: r.id,
              level: r.level == 'a2' ? ExamLevel.a2 : ExamLevel.a1,
              takenAt: r.takenAt,
              readingScore: r.readingScore,
              listeningScore: r.listeningScore,
              writingScore: r.writingScore,
              speakingScore: r.speakingScore,
              totalScore: r.totalScore,
              passed: r.passed,
              details: r.details != null
                  ? jsonDecode(r.details!) as Map<String, dynamic>
                  : null,
            ),)
        .toList();
  }
}

/// Build a sample CCE-format mock exam.
///
/// Listening questions carry `audio_text` (spoken via TTS, never shown);
/// reading questions carry an optional `passage`.
MockExam buildSampleExam(ExamLevel level) {
  final isA1 = level == ExamLevel.a1;

  final readingQuestions = [
    {
      'passage': isA1
          ? 'Ahoj, jmenuji se Petra. Bydlím v Praze. Ráda čtu knihy a poslouchám hudbu. Každé ráno piju kávu a jím rohlík.'
          : 'Dobrý den, jmenuji se Tomáš a pracuji v bance v centru Prahy. Každý den vstávám v šest hodin a jedu metrem do práce. V práci jsem od osmi do čtyř hodin odpoledne.',
      'prompt': isA1
          ? 'What does Petra do every morning?'
          : 'How does Tomáš get to work?',
      'options': isA1
          ? [
              'Drinks coffee and eats bread',
              'Goes to work by car',
              'Reads books in the park',
              'Listens to music',
            ]
          : [
              'By metro',
              'By car',
              'By bus',
              'On foot',
            ],
      'correct_answer': 0,
    },
    {
      'prompt': 'Where does the person live/work?',
      'options': ['Brno', 'Praha', 'Ostrava', 'Plzeň'],
      'correct_answer': 1,
    },
  ];

  final listeningQuestions = [
    {
      'audio_text': 'Dobré ráno, jak se máte?',
      'prompt': 'What does the speaker say?',
      'options': [
        'Good morning, how are you?',
        'Good evening, see you later',
        'Good night, sleep well',
        'Goodbye, take care',
      ],
      'correct_answer': 0,
    },
    {
      'audio_text': 'Mám hlad.',
      'prompt': 'What does the speaker want?',
      'options': ['A drink', 'Food', 'Sleep', 'Help'],
      'correct_answer': 1,
    },
  ];

  final writingQuestion = {
    'prompt': isA1
        ? 'Write about yourself: your name, where you live, and what you like to do. (30+ words)'
        : 'Write about your typical day: when you wake up, what you do at work/school, and your evening routine. (50+ words)',
    'min_words': isA1 ? 30 : 50,
  };

  final speakingQuestion = {
    'prompt': 'Read the following Czech text aloud:',
    'target_text': isA1
        ? 'Ahoj, jmenuji se Student. Bydlím v Praze a učím se česky.'
        : 'Dobrý den, pracuji v kanceláři a každý den dojíždím metrem. Ve volném čase rád čtu a cestuji.',
  };

  return MockExam(
    level: level,
    totalTimeMinutes: isA1 ? 30 : 45,
    sections: [
      MockExamSection(
        type: ExamSectionType.reading,
        timeLimitMinutes: 8,
        questions: readingQuestions,
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.listening,
        timeLimitMinutes: 8,
        questions: listeningQuestions,
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.writing,
        timeLimitMinutes: 10,
        questions: [writingQuestion],
        maxScore: 100,
      ),
      MockExamSection(
        type: ExamSectionType.speaking,
        timeLimitMinutes: 5,
        questions: [speakingQuestion],
        maxScore: 100,
      ),
    ],
  );
}
