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
  TextColumn get lemma => text().nullable()();
  TextColumn get senseKey => text().nullable()();
  TextColumn get partOfSpeech => text().nullable()();
  TextColumn get morphologyJson => text().nullable()();
  TextColumn get registerLabel => text().nullable()();
  TextColumn get pronunciationSource => text().nullable()();

  /// Stable, device-independent identity for user-created ("manual") cards.
  /// Managed/seeded cards leave this null and are keyed cross-device by their
  /// deterministic seeded id. Manual cards get a UUID at creation so two
  /// devices adding different words can never collide on the same sync
  /// `content_key` (the local autoincrement id is not stable across devices).
  TextColumn get contentUid => text().nullable()();

  IntColumn get unitId => integer().nullable().references(Units, #id)();

  /// The lesson that introduces this word. When set, the word is only
  /// scheduled for review once that lesson is completed (finer-grained than
  /// [unitId] gating). Null falls back to unit-level gating.
  IntColumn get lessonId => integer().nullable().references(Lessons, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
