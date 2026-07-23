import 'package:drift/drift.dart';

class DelayedTransferAssignments extends Table {
  TextColumn get assignmentId => text()();
  TextColumn get sourceAttemptId => text()();
  IntColumn get lessonId => integer()();
  IntColumn get sourceExerciseId => integer()();
  DateTimeColumn get dueAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get completedEvidenceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {assignmentId};
}
