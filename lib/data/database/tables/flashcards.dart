import 'package:drift/drift.dart';
import 'units.dart';
import 'lessons.dart';

/// Flashcards table — vocabulary words for SRS.
class Flashcards extends Table {
  IntColumn get id => integer()();
  TextColumn get wordCz => text()();
  TextColumn get wordEn => text()();
  TextColumn get ipa => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get caseInfo => text().nullable()();
  TextColumn get audioHash => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get exampleCz => text().nullable()();
  TextColumn get exampleEn => text().nullable()();
  IntColumn get unitId => integer().nullable().references(Units, #id)();

  /// The lesson that introduces this word. When set, the word is only
  /// scheduled for review once that lesson is completed (finer-grained than
  /// [unitId] gating). Null falls back to unit-level gating.
  IntColumn get lessonId => integer().nullable().references(Lessons, #id)();

  @override
  Set<Column> get primaryKey => {id};
}