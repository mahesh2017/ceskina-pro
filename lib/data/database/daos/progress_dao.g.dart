// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $LessonProgressTable get lessonProgress => attachedDatabase.lessonProgress;
  $EarnedBadgesTable get earnedBadges => attachedDatabase.earnedBadges;
  $UserProgressTable get userProgress => attachedDatabase.userProgress;
  ProgressDaoManager get managers => ProgressDaoManager(this);
}

class ProgressDaoManager {
  final _$ProgressDaoMixin _db;
  ProgressDaoManager(this._db);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(
        _db.attachedDatabase,
        _db.lessonProgress,
      );
  $$EarnedBadgesTableTableManager get earnedBadges =>
      $$EarnedBadgesTableTableManager(_db.attachedDatabase, _db.earnedBadges);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db.attachedDatabase, _db.userProgress);
}
