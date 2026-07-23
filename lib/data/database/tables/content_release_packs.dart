import 'package:drift/drift.dart';

import 'content_release_installations.dart';

/// Exact verified JSON payload retained for an installed release.
class ContentReleasePacks extends Table {
  TextColumn get releaseId =>
      text().references(ContentReleaseInstallations, #releaseId)();
  TextColumn get packKey => text()();
  IntColumn get packVersion => integer()();
  TextColumn get checksum => text()();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {releaseId, packKey};
}
