import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/gamification_providers.dart';
import '../../widgets/lesson/exercise_widget.dart';
import '../../widgets/common/grammar_tip_card.dart';
import '../../widgets/common/stat_row.dart';

/// Lesson player — loads exercises from DB, cycles through them one by one.
/// Shows progress bar, hearts, and feedback after each answer.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  final int lessonId;

  const LessonPlayerScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonPlayerScreen> createState() =>
      _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Load lesson data on first build
    Future.microtask(() async {
      await ref
          .read(lessonSessionProvider.notifier)
          .loadLesson(widget.lessonId);
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(lessonSessionProvider);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Game over screen
    if (session.isGameOver) {
      return _GameOverScreen(
        onRetry: () {
          ref.read(lessonSessionProvider.notifier).retry();
        },
        onExit: () => context.pop(),
      );
    }

    // Lesson complete screen
    if (session.isComplete) {
      return _LessonCompleteScreen(
        session: session,
        onExit: () => context.go('/curriculum'),
        onRetry: () {
          ref.read(lessonSessionProvider.notifier).retry();
        },
      );
    }

    // Active exercise
    final exercise = session.currentExercise;
    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No exercises found for this lesson.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirm(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: session.progress,
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Hearts
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite,
                    color: session.hearts > 0
                        ? Colors.red
                        : Colors.grey.shade400,
                    size: 20,),
                const SizedBox(width: 2),
                Text(
                  '${session.hearts}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Exercise counter
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.inMistakeReview
                        ? 'Reviewing missed questions'
                        : 'Question ${session.currentIndex + 1} of ${session.totalExercises}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: session.inMistakeReview
                              ? Colors.orange.shade700
                              : Colors.grey,
                          fontWeight: session.inMistakeReview
                              ? FontWeight.bold
                              : null,
                        ),
                  ),
                  if (session.totalXp > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            color: Colors.amber.shade600, size: 16,),
                        const SizedBox(width: 2),
                        Text(
                          '+${session.totalXp} XP',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // The exercise stays visible while the feedback banner is shown,
            // so the learner can study their answer at their own pace —
            // no timed auto-advance.
            Expanded(
              child: SingleChildScrollView(
                child: ExerciseWidget(
                  // Key by position so widget state (selected answers) resets
                  // for each exercise, including mistake re-asks of the same
                  // exercise id.
                  key: ValueKey(session.currentIndex),
                  exercise: exercise,
                  onAnswered: (result) {
                    ref
                        .read(lessonSessionProvider.notifier)
                        .onExerciseAnswered(
                          isCorrect: result.isCorrect,
                          explanation: result.explanation,
                          correctAnswer: result.correctAnswer,
                          xpEarned: exercise.xpReward,
                        );
                  },
                ),
              ),
            ),

            // Feedback banner — appears under the answered exercise.
            if (session.showFeedback) _buildFeedbackBanner(context, session),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(
      BuildContext context, LessonSessionState session,) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cap the banner height so long explanations scroll instead
              // of pushing the exercise off screen.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                ),
                child: SingleChildScrollView(
                  child: GrammarTipCard(
                    isCorrect: session.lastWasCorrect,
                    explanation: session.lastExplanation,
                    correctAnswer: session.lastCorrectAnswer,
                    grammarRuleId: session.lastGrammarRuleId,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ref.read(lessonSessionProvider.notifier).nextExercise();
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  session.currentIndex + 1 < session.totalExercises
                      ? 'Continue'
                      : (session.mistakeQueue.isNotEmpty &&
                              !session.mistakesAppended)
                          ? 'Review Mistakes'
                          : 'Finish Lesson',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave lesson?'),
        content: const Text(
            'Your progress in this lesson will be lost. Are you sure?',),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

/// Screen shown when the user runs out of hearts.
class _GameOverScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _GameOverScreen({required this.onRetry, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.heart_broken,
                  size: 80, color: Colors.red.shade300,),
              const SizedBox(height: 24),
              Text(
                'Out of hearts!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Hearts refill over time — one every 30 minutes.\n'
                'Or review vocabulary now: finishing a review session\n'
                'of 5+ cards earns a heart back.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/review'),
                icon: const Icon(Icons.style),
                label: const Text('Review to Earn a Heart'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onExit,
                child: const Text('Back to Curriculum'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen shown when the lesson is completed successfully.
class _LessonCompleteScreen extends ConsumerWidget {
  final LessonSessionState session;
  final VoidCallback onExit;
  final VoidCallback onRetry;

  const _LessonCompleteScreen({
    required this.session,
    required this.onExit,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accuracy = (session.accuracy * 100).round();
    final isPerfect = session.correctCount == session.totalExercises;
    final gamification = ref.watch(gamificationProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy / star icon
              Icon(
                isPerfect ? Icons.emoji_events : Icons.check_circle,
                size: 80,
                color: isPerfect ? Colors.amber : Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                isPerfect ? 'Perfektní! Perfect!' : 'Výborně! Well done!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      StatRow(
                        icon: Icons.check,
                        label: 'Correct',
                        value: '${session.correctCount}/${session.totalExercises}',
                        color: Colors.green,
                      ),
                      const Divider(),
                      StatRow(
                        icon: Icons.percent,
                        label: 'Accuracy',
                        value: '$accuracy%',
                        color: accuracy >= 80
                            ? Colors.green
                            : accuracy >= 60
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const Divider(),
                      StatRow(
                        icon: Icons.star,
                        label: 'XP Earned',
                        value: '+${session.totalXp}',
                        color: Colors.amber,
                      ),
                      const Divider(),
                      StatRow(
                        icon: Icons.favorite,
                        label: 'Hearts Remaining',
                        value:
                            '${session.hearts}/${gamification.maxHearts}',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: onExit,
                icon: const Icon(Icons.school),
                label: const Text('Continue Learning'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('Practice Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

