import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/review_providers.dart';
import '../../providers/tts_providers.dart';
import '../../../domain/entities/flashcard.dart';
import '../../../domain/entities/fsrs_card.dart';

/// SRS review screen — flashcard interface with flip + FSRS rating buttons.
class SrsReviewScreen extends ConsumerStatefulWidget {
  const SrsReviewScreen({super.key});

  @override
  ConsumerState<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends ConsumerState<SrsReviewScreen>
    with SingleTickerProviderStateMixin {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(reviewSessionProvider.notifier).loadDueCards();
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(reviewSessionProvider);

    if (!_loaded || session.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // No due cards
    if (session.dueCards.isEmpty && !session.isComplete) {
      return _NoDueCardsScreen(onRefresh: () {
        ref.read(reviewSessionProvider.notifier).loadDueCards();
      });
    }

    // Session complete
    if (session.isComplete) {
      return _ReviewCompleteScreen(
        session: session,
        onRestart: () {
          ref.read(reviewSessionProvider.notifier).restart();
        },
        onExit: () => context.go('/'),
      );
    }

    // Active review
    final card = session.currentCard;
    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: Text('No cards available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
            Text(
              '${session.remainingCards} left',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirm(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress info
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Text(
                'Card ${session.currentIndex + 1} of ${session.totalCards}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Flashcard
            Expanded(
              child: _FlashcardView(
                card: card,
                isFlipped: session.isFlipped,
                onFlip: () {
                  ref.read(reviewSessionProvider.notifier).flipCard();
                },
              ),
            ),

            // Rating buttons (only after flip)
            if (session.isFlipped)
              _RatingButtons(
                onRate: (rating) {
                  ref.read(reviewSessionProvider.notifier).rateCard(rating);
                },
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton.icon(
                  onPressed: () {
                    ref.read(reviewSessionProvider.notifier).flipCard();
                  },
                  icon: const Icon(Icons.flip),
                  label: const Text('Show Answer'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End review?'),
        content: const Text(
            'Your progress will be saved. You can continue later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }
}

/// The flashcard view — front (Czech word) and back (English + IPA + example).
class _FlashcardView extends ConsumerWidget {
  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;

  const _FlashcardView({
    required this.card,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: isFlipped ? null : onFlip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: isFlipped
                ? _buildBack(context, ref)
                : _buildFront(context, ref),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gender badge
        if (card.gender != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _genderColor(card.gender!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              card.gender!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        const SizedBox(height: 24),

        // Czech word
        Text(
          card.wordCz,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),

        // IPA
        if (card.ipa != null) ...[
          const SizedBox(height: 12),
          Text(
            '/${card.ipa}/',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],

        const SizedBox(height: 40),

        // Hint to flip
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tap to reveal',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ],
        ),

        // Audio button — speaks the Czech word via TTS
        const SizedBox(height: 16),
        IconButton(
          onPressed: () {
            ref.read(czechTtsProvider).speak(card.wordCz);
          },
          icon: const Icon(Icons.volume_up, size: 32),
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Czech word (smaller, at top)
        Text(
          card.wordCz,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 8),
        if (card.ipa != null)
          Text(
            '/${card.ipa}/',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
        const Divider(height: 32),

        // English translation
        Text(
          card.wordEn,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
        ),

        // Example sentence
        if (card.exampleCz != null) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  card.exampleCz!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (card.exampleEn != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    card.exampleEn!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          // TTS button for example sentence
          if (card.exampleCz != null) ...[
            const SizedBox(height: 8),
            IconButton(
              onPressed: () {
                ref.read(czechTtsProvider).speak(card.exampleCz!);
              },
              icon: const Icon(Icons.volume_up, size: 20),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ],
    );
  }

  Color _genderColor(String gender) {
    return switch (gender) {
      'masculine animate' => Colors.blue.shade700,
      'masculine inanimate' => Colors.blue.shade400,
      'feminine' => Colors.pink.shade600,
      'neuter' => Colors.teal.shade600,
      _ => Colors.grey,
    };
  }
}

/// Rating buttons — Again / Hard / Good / Easy (FSRS).
class _RatingButtons extends StatelessWidget {
  final void Function(Rating) onRate;

  const _RatingButtons({required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _RatingButton(
              label: 'Again',
              subtitle: '<1m',
              color: Colors.red,
              icon: Icons.refresh,
              onTap: () => onRate(Rating.again),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RatingButton(
              label: 'Hard',
              subtitle: '6m',
              color: Colors.orange,
              icon: Icons.flag,
              onTap: () => onRate(Rating.hard),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RatingButton(
              label: 'Good',
              subtitle: '1d',
              color: Colors.green,
              icon: Icons.check,
              onTap: () => onRate(Rating.good),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RatingButton(
              label: 'Easy',
              subtitle: '4d',
              color: Colors.blue,
              icon: Icons.star,
              onTap: () => onRate(Rating.easy),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(subtitle, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/// Screen shown when there are no due cards.
class _NoDueCardsScreen extends StatelessWidget {
  final VoidCallback onRefresh;

  const _NoDueCardsScreen({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  size: 80, color: Colors.green.shade300),
              const SizedBox(height: 24),
              Text(
                'All caught up!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'No cards due for review right now.\nCome back later for more practice.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Check Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen shown when the review session is complete.
class _ReviewCompleteScreen extends StatelessWidget {
  final ReviewSessionState session;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _ReviewCompleteScreen({
    required this.session,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = (session.accuracy * 100).round();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Review Complete!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Stats card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.style,
                        label: 'Cards Reviewed',
                        value: '${session.reviewedCount}',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Divider(),
                      _StatRow(
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
                      _StatRow(
                        icon: Icons.refresh,
                        label: 'Again',
                        value: '${session.againCount}',
                        color: Colors.red,
                      ),
                      const Divider(),
                      _StatRow(
                        icon: Icons.flag,
                        label: 'Hard',
                        value: '${session.hardCount}',
                        color: Colors.orange,
                      ),
                      const Divider(),
                      _StatRow(
                        icon: Icons.check,
                        label: 'Good',
                        value: '${session.goodCount}',
                        color: Colors.green,
                      ),
                      const Divider(),
                      _StatRow(
                        icon: Icons.star,
                        label: 'Easy',
                        value: '${session.easyCount}',
                        color: Colors.blue,
                      ),
                      const Divider(),
                      _StatRow(
                        icon: Icons.star_border,
                        label: 'XP Earned',
                        value: '+${session.totalXp}',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onExit,
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRestart,
                child: const Text('Review Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}