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