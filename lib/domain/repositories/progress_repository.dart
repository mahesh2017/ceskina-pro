import '../entities/gamification_state.dart';

/// Abstract interface for progress + gamification state persistence.
abstract class ProgressRepository {
  Stream<ProgressSnapshot> watchProgress();
  Future<void> recordCompletion(int unitId, int lessonId, double score);
  Future<ProgressSnapshot> getSnapshot();
  Future<void> recordExamPassed(String level);
  Future<void> updateStreak(int currentStreak, int longestStreak);
}