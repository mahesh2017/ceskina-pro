import 'package:drift/drift.dart';

/// Units table — curriculum units (21 total, A1 + A2).
class Units extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get phase => text()(); // 'a1' or 'a2'
  IntColumn get orderIndex => integer()();
  TextColumn get grammarTags => text().withDefault(const Constant(''))();
  BoolColumn get isExamPrep => boolean().withDefault(const Constant(false))();
  IntColumn get lessonCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}