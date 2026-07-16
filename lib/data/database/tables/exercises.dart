import 'package:drift/drift.dart';
import 'lessons.dart';

/// Exercises table — individual exercises within a lesson.
class Exercises extends Table {
  IntColumn get id => integer()();
  IntColumn get lessonId => integer().references(Lessons, #id)();
  TextColumn get type => text()(); // ExerciseType enum name
  TextColumn get prompt => text()();
  TextColumn get data => text()(); // JSON payload, type-specific
  TextColumn get answerKey => text().nullable()();
  TextColumn get grammarRuleId => text().nullable()();
  IntColumn get xpReward => integer().withDefault(const Constant(10))();

  @override
  Set<Column> get primaryKey => {id};
}