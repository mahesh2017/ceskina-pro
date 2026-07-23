import 'package:drift/drift.dart';

class ExerciseAttempts extends Table {
  TextColumn get presentationId => text()();
  TextColumn get lessonAttemptId => text()();
  IntColumn get exerciseId => integer()();
  TextColumn get phase => text()();
  TextColumn get outcome => text()();
  DateTimeColumn get answeredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {presentationId};
}
