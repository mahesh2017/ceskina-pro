import 'package:drift/drift.dart';
import 'units.dart';

/// Grammar rules table — reference grammar rules linked to units.
class GrammarRules extends Table {
  TextColumn get id => text()(); // e.g. 'GR-001'
  TextColumn get ruleName => text()();
  TextColumn get pattern => text()();
  TextColumn get explanation => text()();
  TextColumn get caseAffected => text().nullable()();
  TextColumn get examples => text().withDefault(const Constant('[]'))(); // JSON
  IntColumn get unitId => integer().nullable().references(Units, #id)();

  @override
  Set<Column> get primaryKey => {id};
}