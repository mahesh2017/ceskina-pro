import 'package:drift/drift.dart';

/// Locally retained verified releases. At most the active and immediately
/// previous release are kept for offline rollback.
class ContentReleaseInstallations extends Table {
  TextColumn get releaseId => text()();
  IntColumn get version => integer()();
  TextColumn get contentChecksum => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrevious => boolean().withDefault(const Constant(false))();
  DateTimeColumn get installedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {releaseId};
}
