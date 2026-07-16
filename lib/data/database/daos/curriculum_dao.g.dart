// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_dao.dart';

// ignore_for_file: type=lint
mixin _$CurriculumDaoMixin on DatabaseAccessor<AppDatabase> {
  $UnitsTable get units => attachedDatabase.units;
  $LessonsTable get lessons => attachedDatabase.lessons;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $GrammarRulesTable get grammarRules => attachedDatabase.grammarRules;
  CurriculumDaoManager get managers => CurriculumDaoManager(this);
}

class CurriculumDaoManager {
  final _$CurriculumDaoMixin _db;
  CurriculumDaoManager(this._db);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db.attachedDatabase, _db.units);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db.attachedDatabase, _db.lessons);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$GrammarRulesTableTableManager get grammarRules =>
      $$GrammarRulesTableTableManager(_db.attachedDatabase, _db.grammarRules);
}
