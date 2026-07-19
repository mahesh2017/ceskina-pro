// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_dao.dart';

// ignore_for_file: type=lint
mixin _$VocabularyDaoMixin on DatabaseAccessor<AppDatabase> {
  $UnitsTable get units => attachedDatabase.units;
  $LessonsTable get lessons => attachedDatabase.lessons;
  $FlashcardsTable get flashcards => attachedDatabase.flashcards;
  $SrsCardsTable get srsCards => attachedDatabase.srsCards;
  VocabularyDaoManager get managers => VocabularyDaoManager(this);
}

class VocabularyDaoManager {
  final _$VocabularyDaoMixin _db;
  VocabularyDaoManager(this._db);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db.attachedDatabase, _db.units);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db.attachedDatabase, _db.lessons);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db.attachedDatabase, _db.flashcards);
  $$SrsCardsTableTableManager get srsCards =>
      $$SrsCardsTableTableManager(_db.attachedDatabase, _db.srsCards);
}
