import 'package:drift/drift.dart';
import 'units.dart';

/// Lessons table — lessons within a unit (3-6 per unit).
class Lessons extends Table {
  IntColumn get id => integer()();
  IntColumn get unitId => integer().references(Units, #id)();
  IntColumn get orderInUnit => integer()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(10))();
  TextColumn get lessonType => text().withDefault(const Constant('introduction'))();
  BoolColumn get isReview => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}