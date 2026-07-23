import 'package:drift/drift.dart';

/// Immutable evidence for one committed SRS rating.
class ReviewAttempts extends Table {
  TextColumn get reviewId => text()();
  IntColumn get srsCardId => integer()();
  TextColumn get rating => text()();
  DateTimeColumn get reviewedAt => dateTime()();
  BoolColumn get introducedNewCard =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {reviewId};
}
