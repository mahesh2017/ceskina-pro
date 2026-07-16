import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/lesson.dart';
import 'database_providers.dart';
import 'gamification_providers.dart';

/// State of a lesson session.
class LessonSessionState {
  final Lesson? lesson;
  final List<Exercise> exercises;
  final int currentIndex;
  final int correctCount;
  final int wrongCount;
  final int hearts;
  final int totalXp;
  final bool isComplete;
  final bool isGameOver;
  final String? lastExplanation;
  final String? lastCorrectAnswer;
  final bool lastWasCorrect;
  final bool showFeedback;

  const LessonSessionState({
    this.lesson,
    this.exercises = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.hearts = 5,
    this.totalXp = 0,
    this.isComplete = false,
    this.isGameOver = false,
    this.lastExplanation,
    this.lastCorrectAnswer,
    this.lastWasCorrect = false,
    this.showFeedback = false,
  });

  LessonSessionState copyWith({
    Lesson? lesson,
    List<Exercise>? exercises,
    int? currentIndex,
    int? correctCount,
    int? wrongCount,
    int? hearts,
    int? totalXp,
    bool? isComplete,
    bool? isGameOver,
    String? lastExplanation,
    String? lastCorrectAnswer,
    bool? lastWasCorrect,
    bool? showFeedback,
  }) {
    return LessonSessionState(
      lesson: lesson ?? this.lesson,
      exercises: exercises ?? this.exercises,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      hearts: hearts ?? this.hearts,
      totalXp: totalXp ?? this.totalXp,
      isComplete: isComplete ?? this.isComplete,
      isGameOver: isGameOver ?? this.isGameOver,
      lastExplanation: lastExplanation ?? this.lastExplanation,
      lastCorrectAnswer: lastCorrectAnswer ?? this.lastCorrectAnswer,
      lastWasCorrect: lastWasCorrect ?? this.lastWasCorrect,
      showFeedback: showFeedback ?? this.showFeedback,
    );
  }

  Exercise? get currentExercise =>
      currentIndex < exercises.length ? exercises[currentIndex] : null;

  double get progress =>
      exercises.isEmpty ? 0.0 : (currentIndex) / exercises.length;

  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 0.0;
    return correctCount / total;
  }

  int get totalExercises => exercises.length;
}

/// Provider that manages a lesson session.
class LessonSessionNotifier extends Notifier<LessonSessionState> {
  @override
  LessonSessionState build() => const LessonSessionState();

  /// Load a lesson and its exercises from the database.
  Future<void> loadLesson(int lessonId) async {
    state = const LessonSessionState();
    final repo = ref.read(curriculumRepositoryProvider);
    final lesson = await repo.getLesson(lessonId);
    final exercises = await repo.getExercises(lessonId);
    state = LessonSessionState(
      lesson: lesson,
      exercises: exercises,
      hearts: 5,
    );
  }

  /// Called when the current exercise is answered.
  void onExerciseAnswered({
    required bool isCorrect,
    String? explanation,
    String? correctAnswer,
    int xpEarned = 10,
  }) {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    final newCorrect = state.correctCount + (isCorrect ? 1 : 0);
    final newWrong = state.wrongCount + (isCorrect ? 0 : 1);
    final newHearts = state.hearts - (isCorrect ? 0 : 1);
    final newXp = state.totalXp + (isCorrect ? xpEarned : 0);

    // Show feedback card
    state = state.copyWith(
      correctCount: newCorrect,
      wrongCount: newWrong,
      hearts: newHearts,
      totalXp: newXp,
      lastExplanation: explanation,
      lastCorrectAnswer: correctAnswer,
      lastWasCorrect: isCorrect,
      showFeedback: true,
    );
  }

  /// Advance to the next exercise or complete the lesson.
  void nextExercise() {
    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.exercises.length) {
      // Lesson complete
      _onLessonComplete();
      return;
    }

    // Check game over
    if (state.hearts <= 0) {
      state = state.copyWith(isGameOver: true);
      return;
    }

    state = state.copyWith(
      currentIndex: nextIndex,
      showFeedback: false,
      lastExplanation: null,
      lastCorrectAnswer: null,
    );
  }

  /// Retry the lesson from the beginning.
  void retry() {
    state = LessonSessionState(
      lesson: state.lesson,
      exercises: state.exercises,
      hearts: 5,
    );
  }

  /// Handle lesson completion — save progress + award XP.
  void _onLessonComplete() {
    final lesson = state.lesson;
    if (lesson != null) {
      // Save progress to database
      final progressRepo = ref.read(progressRepositoryProvider);
      progressRepo.recordCompletion(
        lesson.unitId,
        lesson.id,
        state.accuracy,
      );

      // Award XP via gamification
      final gamification = ref.read(gamificationProvider.notifier);
      gamification.onLessonCompleted(accuracy: state.accuracy);
    }

    state = state.copyWith(isComplete: true);
  }
}

/// Provider for the lesson session.
final lessonSessionProvider =
    NotifierProvider<LessonSessionNotifier, LessonSessionState>(
  LessonSessionNotifier.new,
);