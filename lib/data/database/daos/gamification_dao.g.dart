// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_dao.dart';

// ignore_for_file: type=lint
mixin _$GamificationDaoMixin on DatabaseAccessor<AppDatabase> {
  $GamificationStateTableTable get gamificationStateTable =>
      attachedDatabase.gamificationStateTable;
  GamificationDaoManager get managers => GamificationDaoManager(this);
}

class GamificationDaoManager {
  final _$GamificationDaoMixin _db;
  GamificationDaoManager(this._db);
  $$GamificationStateTableTableTableManager get gamificationStateTable =>
      $$GamificationStateTableTableTableManager(
        _db.attachedDatabase,
        _db.gamificationStateTable,
      );
}
