import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/lesson.dart';
import 'curriculum_providers.dart';
import 'database_providers.dart';
import 'gamification_providers.dart';
import 'review_providers.dart';
import 'settings_providers.dart';

final _log = Logger('LessonSession');

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
  final String? lastGrammarRuleId;
  final bool lastWasCorrect;
  final bool showFeedback;

  /// Exercises answered wrong during the main pass, re-asked at the end.
  final List<Exercise> mistakeQueue;

  /// True once the missed exercises have been appended for a review pass.
  final bool mistakesAppended;

  /// Number of exercises in the original lesson (before mistake re-asks),
  /// so the UI can tell when the learner is in the review-mistakes phase.
  final int originalCount;

  /// New vocabulary this lesson introduces, shown in the teach phase
  /// before exercises begin.
  final List<Flashcard> teachCards;

  /// True while the learner is browsing the new words, before practicing.
  final bool isTeaching;

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
    this.lastGrammarRuleId,
    this.lastWasCorrect = false,
    this.showFeedback = false,
    this.mistakeQueue = const [],
    this.mistakesAppended = false,
    this.originalCount = 0,
    this.teachCards = const [],
    this.isTeaching = false,
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
    String? lastGrammarRuleId,
    bool? lastWasCorrect,
    bool? showFeedback,
    List<Exercise>? mistakeQueue,
    bool? mistakesAppended,
    int? originalCount,
    List<Flashcard>? teachCards,
    bool? isTeaching,
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
      lastGrammarRuleId: lastGrammarRuleId ?? this.lastGrammarRuleId,
      lastWasCorrect: lastWasCorrect ?? this.lastWasCorrect,
      showFeedback: showFeedback ?? this.showFeedback,
      mistakeQueue: mistakeQueue ?? this.mistakeQueue,
      mistakesAppended: mistakesAppended ?? this.mistakesAppended,
      originalCount: originalCount ?? this.originalCount,
      teachCards: teachCards ?? this.teachCards,
      isTeaching: isTeaching ?? this.isTeaching,
    );
  }

  /// True when the learner is re-answering the questions they missed.
  bool get inMistakeReview =>
      mistakesAppended && currentIndex >= originalCount;

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
  /// Hearts come from the global gamification state (regen applied first),
  /// so losses persist across lessons and refill over time.
  Future<void> loadLesson(int lessonId) async {
    state = const LessonSessionState();
    final gamification = ref.read(gamificationProvider.notifier);
    await gamification.refreshHearts();
    final hearts = ref.read(gamificationProvider).hearts;

    final heartsEnabled = ref.read(settingsProvider).heartsEnabled;

    final repo = ref.read(curriculumRepositoryProvider);
    final lesson = await repo.getLesson(lessonId);
    final exercises = await repo.getExercises(lessonId);

    // Teach before testing: load the vocabulary this lesson introduces so
    // the player can present it before the first exercise.
    List<Flashcard> teachCards = const [];
    try {
      teachCards = await ref
          .read(vocabularyRepositoryProvider)
          .getCardsForLesson(lessonId);
    } catch (_) {
      // No vocab mapping — go straight to exercises.
    }

    state = LessonSessionState(
      lesson: lesson,
      exercises: exercises,
      hearts: hearts,
      isGameOver: heartsEnabled && hearts <= 0,
      originalCount: exercises.length,
      teachCards: teachCards,
      isTeaching: teachCards.isNotEmpty,
    );
  }

  /// Leave the teach phase and start the exercises.
  void startExercises() {
    state = state.copyWith(isTeaching: false);
  }

  /// Called when the current exercise is answered.
  Future<void> onExerciseAnswered({
    required bool isCorrect,
    String? explanation,
    String? correctAnswer,
    int xpEarned = 10,
  }) async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    var newHearts = state.hearts;
    final heartsEnabled = ref.read(settingsProvider).heartsEnabled;
    if (!isCorrect && heartsEnabled) {
      // Deduct from the global hearts pool so the loss persists.
      newHearts =
          await ref.read(gamificationProvider.notifier).onWrongAnswer();
    }

    // During the main pass, remember wrong exercises so we can re-ask
    // them once at the end (only if there are hearts left to continue).
    var mistakeQueue = state.mistakeQueue;
    if (!isCorrect && !state.mistakesAppended) {
      mistakeQueue = [...state.mistakeQueue, exercise];
    }

    // Show feedback card
    state = state.copyWith(
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      wrongCount: state.wrongCount + (isCorrect ? 0 : 1),
      hearts: newHearts,
      totalXp: state.totalXp + (isCorrect ? xpEarned : 0),
      lastExplanation: explanation,
      lastCorrectAnswer: correctAnswer,
      lastGrammarRuleId: exercise.grammarRuleId,
      lastWasCorrect: isCorrect,
      showFeedback: true,
      mistakeQueue: mistakeQueue,
    );
  }

  /// Advance to the next exercise or complete the lesson.
  void nextExercise() {
    // Check game over FIRST — even if this is the last question
    final heartsEnabled = ref.read(settingsProvider).heartsEnabled;
    if (heartsEnabled && state.hearts <= 0) {
      state = state.copyWith(isGameOver: true);
      return;
    }

    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.exercises.length) {
      // End of the current list. If the learner missed anything on the
      // main pass, re-ask those once before finishing.
      if (!state.mistakesAppended && state.mistakeQueue.isNotEmpty) {
        state = state.copyWith(
          exercises: [...state.exercises, ...state.mistakeQueue],
          currentIndex: nextIndex,
          showFeedback: false,
          lastExplanation: null,
          lastCorrectAnswer: null,
          mistakesAppended: true,
        );
        return;
      }
      // Lesson complete
      _onLessonComplete();
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
  /// Requires at least one heart — hearts persist across attempts.
  Future<void> retry() async {
    final gamification = ref.read(gamificationProvider.notifier);
    await gamification.refreshHearts();
    final hearts = ref.read(gamificationProvider).hearts;

    // Restore the original exercise list (drop any appended mistake re-asks).
    final baseExercises = state.originalCount > 0 &&
            state.originalCount <= state.exercises.length
        ? state.exercises.sublist(0, state.originalCount)
        : state.exercises;

    state = LessonSessionState(
      lesson: state.lesson,
      exercises: baseExercises,
      hearts: hearts,
      isGameOver:
          ref.read(settingsProvider).heartsEnabled && hearts <= 0,
      originalCount: baseExercises.length,
    );
  }

  /// Handle lesson completion — save progress + award XP.
  void _onLessonComplete() {
    final lesson = state.lesson;
    if (lesson != null) {
      // Save progress to database (fire-and-forget with error logging)
      final progressRepo = ref.read(progressRepositoryProvider);
      final accuracy = state.accuracy;
      progressRepo.recordCompletion(
        lesson.unitId,
        lesson.id,
        accuracy,
      ).then((_) {
        // Refresh completion-derived state (unit unlocks, next lesson)
        // now that the new completion is stored, then re-check badges
        // against the updated snapshot.
        ref.invalidate(completedLessonIdsProvider);
        // Completing a lesson can unlock its words for review.
        ref.invalidate(dueCardCountProvider);
        return ref
            .read(gamificationProvider.notifier)
            .onLessonCompleted(accuracy: accuracy);
      }).catchError((Object e, StackTrace s) {
        // Lesson still shows as complete in the UI; progress will be
        // re-recorded next time the lesson is finished.
        _log.warning('Failed to record lesson completion', e, s);
        return ref
            .read(gamificationProvider.notifier)
            .onLessonCompleted(accuracy: accuracy);
      });
    }

    state = state.copyWith(isComplete: true);
  }
}

/// Provider for the lesson session.
final lessonSessionProvider =
    NotifierProvider<LessonSessionNotifier, LessonSessionState>(
  LessonSessionNotifier.new,
);