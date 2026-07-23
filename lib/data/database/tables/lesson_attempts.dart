import 'package:drift/drift.dart';

/// Immutable evidence that one lesson attempt reached a terminal commit.
///
/// The caller-generated UUID is the idempotency key. Replaying the same
/// completion after a delayed callback or process retry cannot increment the
/// aggregate lesson-attempt count twice.
class LessonAttempts extends Table {
  TextColumn get attemptId => text()();
  IntColumn get lessonId => integer()();
  IntColumn get unitId => integer()();
  TextColumn get phase => text()();
  RealColumn get score => real()();
  IntColumn get correctCount => integer()();
  IntColumn get incorrectCount => integer()();
  IntColumn get skippedCount => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get committedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {attemptId};
}
