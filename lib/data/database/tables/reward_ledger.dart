import 'package:drift/drift.dart';

/// Append-only, idempotent activity rewards.
class RewardLedger extends Table {
  TextColumn get rewardId => text()();
  TextColumn get sourceId => text()();
  TextColumn get rewardType => text()();
  IntColumn get xp => integer()();
  DateTimeColumn get awardedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {rewardId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sourceId, rewardType},
  ];
}
