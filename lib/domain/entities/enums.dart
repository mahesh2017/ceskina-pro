/// CEFR proficiency level.
enum CEFRLevel {
  preA1('Pre-A1'),
  a1('A1'),
  a2('A2');

  const CEFRLevel(this.label);
  final String label;
}

/// Curriculum phase.
enum Phase { a1, a2 }

/// Exercise types supported by the app.
enum ExerciseType {
  multipleChoice,
  fillBlank,
  translation,
  wordOrder,
  dictation,
  pronunciation,
  declensionTable,
  aspectRecognition,
  prepositionCase,
  listening,
  dialogue,
}

/// Lesson types.
enum LessonType { introduction, practice, application, review }

/// Exam level.
enum ExamLevel { a1, a2 }

/// Exam section types.
enum ExamSectionType { reading, listening, writing, speaking }