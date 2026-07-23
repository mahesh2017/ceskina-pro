import 'package:drift/drift.dart';

/// Append-only Phase 2 evidence. Supports remain separate from correctness.
class LearningEvidenceEvents extends Table {
  TextColumn get evidenceId => text()();
  IntColumn get lessonId => integer()();
  IntColumn get exerciseId => integer().nullable()();
  TextColumn get skill => text()();
  TextColumn get phase => text()();
  BoolColumn get correct => boolean()();
  BoolColumn get novelTask => boolean()();
  TextColumn get supportsJson => text().withDefault(const Constant('[]'))();
  TextColumn get conceptKeysJson => text().withDefault(const Constant('[]'))();
  IntColumn get responseLatencyMs => integer()();
  DateTimeColumn get observedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {evidenceId};
}
