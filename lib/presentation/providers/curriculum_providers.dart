import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/enums.dart';
import 'database_providers.dart';

/// Provider for all units in a phase (A1 or A2).
final unitsProvider =
    FutureProvider.family<List<Unit>, Phase>((ref, phase) {
  final repo = ref.read(curriculumRepositoryProvider);
  return repo.getUnits(phase);
});

/// Provider for all units (A1 + A2 combined).
final allUnitsProvider = FutureProvider<List<Unit>>((ref) async {
  final repo = ref.read(curriculumRepositoryProvider);
  final a1 = await repo.getUnits(Phase.a1);
  final a2 = await repo.getUnits(Phase.a2);
  return [...a1, ...a2];
});

/// Provider for lessons in a specific unit.
final unitLessonsProvider =
    FutureProvider.family<List<Lesson>, int>((ref, unitId) {
  final repo = ref.read(curriculumRepositoryProvider);
  return repo.getLessons(unitId);
});

/// Provider for a single unit.
final unitProvider =
    FutureProvider.family<Unit, int>((ref, unitId) {
  final repo = ref.read(curriculumRepositoryProvider);
  return repo.getUnit(unitId);
});

/// Provider for a single lesson.
final lessonProvider =
    FutureProvider.family<Lesson, int>((ref, lessonId) {
  final repo = ref.read(curriculumRepositoryProvider);
  return repo.getLesson(lessonId);
});

/// Provider for the number of lessons per unit.
/// Used by the curriculum screen to show lesson counts.
final unitLessonCountProvider =
    FutureProvider.family<int, int>((ref, unitId) async {
  final lessons = await ref.read(unitLessonsProvider(unitId).future);
  return lessons.length;
});

/// Provider for completed lesson IDs.
/// Invalidate this after a lesson completes — dependents
/// ([unlockedUnitIdsProvider], [nextLessonProvider]) refresh automatically.
final completedLessonIdsProvider = FutureProvider<Set<int>>((ref) async {
  final progressRepo = ref.read(progressRepositoryProvider);
  return progressRepo.getCompletedLessonIds();
});

/// Provider for unlocked unit IDs based on progress.
/// A unit is unlocked if:
/// - It's the first unit (always unlocked)
/// - The previous unit is unlocked and ALL of its lessons are completed
final unlockedUnitIdsProvider = FutureProvider<Set<int>>((ref) async {
  final allUnits = await ref.watch(allUnitsProvider.future);
  final completedLessonIds =
      await ref.watch(completedLessonIdsProvider.future);

  final unlocked = <int>{};
  for (var i = 0; i < allUnits.length; i++) {
    if (i == 0) {
      unlocked.add(allUnits[i].id);
      continue;
    }

    final prevUnit = allUnits[i - 1];
    // Once the chain breaks, everything after stays locked.
    if (!unlocked.contains(prevUnit.id)) break;

    final prevLessons =
        await ref.watch(unitLessonsProvider(prevUnit.id).future);
    final prevComplete = prevLessons.isNotEmpty &&
        prevLessons.every((l) => completedLessonIds.contains(l.id));
    if (prevComplete) {
      unlocked.add(allUnits[i].id);
    }
  }

  return unlocked;
});

/// The next lesson the learner should continue with, plus its unit title.
class NextLessonInfo {
  final Lesson lesson;
  final String unitTitle;

  const NextLessonInfo({required this.lesson, required this.unitTitle});
}

/// Provider for the next uncompleted lesson in the first unlocked unit
/// that still has work left. Null when everything unlocked is completed.
final nextLessonProvider = FutureProvider<NextLessonInfo?>((ref) async {
  final allUnits = await ref.watch(allUnitsProvider.future);
  final unlockedIds = await ref.watch(unlockedUnitIdsProvider.future);
  final completedLessonIds =
      await ref.watch(completedLessonIdsProvider.future);

  for (final unit in allUnits) {
    if (!unlockedIds.contains(unit.id)) continue;
    final lessons = await ref.watch(unitLessonsProvider(unit.id).future);
    for (final lesson in lessons) {
      if (!completedLessonIds.contains(lesson.id)) {
        return NextLessonInfo(lesson: lesson, unitTitle: unit.title);
      }
    }
  }
  return null;
});