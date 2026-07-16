import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/units.dart';
import '../tables/lessons.dart';
import '../tables/exercises.dart';
import '../tables/grammar_rules.dart';

part 'curriculum_dao.g.dart';

/// Data access object for curriculum-related queries.
@DriftAccessor(tables: [Units, Lessons, Exercises, GrammarRules])
class CurriculumDao extends DatabaseAccessor<AppDatabase>
    with _$CurriculumDaoMixin {
  CurriculumDao(super.db);

  // ── Units ──

  Future<List<Unit>> getUnitsByPhase(String phase) {
    return (select(units)
          ..where((u) => u.phase.equals(phase))
          ..orderBy([(u) => OrderingTerm.asc(u.orderIndex)]))
        .get();
  }

  Future<Unit?> getUnit(int unitId) {
    return (select(units)..where((u) => u.id.equals(unitId))).getSingleOrNull();
  }

  Future<int> insertUnit(UnitsCompanion unit) => into(units).insert(unit);
  Future<void> insertUnits(List<UnitsCompanion> unitList) =>
      batch((b) => b.insertAll(units, unitList));

  // ── Lessons ──

  Future<List<Lesson>> getLessonsByUnit(int unitId) {
    return (select(lessons)
          ..where((l) => l.unitId.equals(unitId))
          ..orderBy([(l) => OrderingTerm.asc(l.orderInUnit)]))
        .get();
  }

  Future<Lesson?> getLesson(int lessonId) {
    return (select(lessons)..where((l) => l.id.equals(lessonId)))
        .getSingleOrNull();
  }

  Future<void> insertLessons(List<LessonsCompanion> lessonList) =>
      batch((b) => b.insertAll(lessons, lessonList));

  // ── Exercises ──

  Future<List<Exercise>> getExercisesByLesson(int lessonId) {
    return (select(exercises)
          ..where((e) => e.lessonId.equals(lessonId)))
        .get();
  }

  Future<void> insertExercises(List<ExercisesCompanion> exerciseList) =>
      batch((b) => b.insertAll(exercises, exerciseList));

  // ── Grammar Rules ──

  Future<List<GrammarRule>> getGrammarRulesByUnit(int unitId) {
    return (select(grammarRules)
          ..where((g) => g.unitId.equals(unitId)))
        .get();
  }

  Future<void> insertGrammarRules(List<GrammarRulesCompanion> ruleList) =>
      batch((b) => b.insertAll(grammarRules, ruleList));

  // ── Seed check ──

  Future<bool> isSeeded() async {
    final result = await customSelect('SELECT COUNT(*) AS c FROM units').getSingle();
    return result.read<int>('c') > 0;
  }
}