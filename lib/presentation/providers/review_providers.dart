import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/fsrs_card.dart';
import '../../domain/engines/fsrs_scheduler.dart';
import 'database_providers.dart';
import 'gamification_providers.dart';

/// State of an SRS review session.
class ReviewSessionState {
  final List<Flashcard> dueCards;
  final int currentIndex;
  final bool isFlipped;
  final int reviewedCount;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final int totalXp;
  final bool isComplete;
  final bool isLoading;

  const ReviewSessionState({
    this.dueCards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.reviewedCount = 0,
    this.againCount = 0,
    this.hardCount = 0,
    this.goodCount = 0,
    this.easyCount = 0,
    this.totalXp = 0,
    this.isComplete = false,
    this.isLoading = true,
  });

  ReviewSessionState copyWith({
    List<Flashcard>? dueCards,
    int? currentIndex,
    bool? isFlipped,
    int? reviewedCount,
    int? againCount,
    int? hardCount,
    int? goodCount,
    int? easyCount,
    int? totalXp,
    bool? isComplete,
    bool? isLoading,
  }) {
    return ReviewSessionState(
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      againCount: againCount ?? this.againCount,
      hardCount: hardCount ?? this.hardCount,
      goodCount: goodCount ?? this.goodCount,
      easyCount: easyCount ?? this.easyCount,
      totalXp: totalXp ?? this.totalXp,
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Flashcard? get currentCard =>
      currentIndex < dueCards.length ? dueCards[currentIndex] : null;

  int get totalCards => dueCards.length;
  int get remainingCards => dueCards.length - currentIndex;

  double get progress =>
      totalCards == 0 ? 0.0 : currentIndex / totalCards;

  double get accuracy {
    final total = reviewedCount;
    if (total == 0) return 0.0;
    return (goodCount + easyCount) / total;
  }
}

/// Provider that manages an SRS review session.
class ReviewSessionNotifier extends Notifier<ReviewSessionState> {
  final _scheduler = FSRSScheduler();

  @override
  ReviewSessionState build() => const ReviewSessionState();

  /// Load due cards from the database.
  Future<void> loadDueCards() async {
    state = const ReviewSessionState(isLoading: true);
    final repo = ref.read(vocabularyRepositoryProvider);
    final dueCards = await repo.getDueCards();
    state = ReviewSessionState(
      dueCards: dueCards,
      isLoading: false,
      isComplete: dueCards.isEmpty,
    );
  }

  /// Flip the current card to reveal the answer.
  void flipCard() {
    state = state.copyWith(isFlipped: true);
  }

  /// Rate the current card and advance to the next.
  void rateCard(Rating rating) {
    final card = state.currentCard;
    if (card == null) return;

    final now = DateTime.now();

    // Build FSRS card from the flashcard's current SRS state.
    // The SRS card id is the flashcard id — the seeder creates them 1:1.
    final fsrsCard = FSRSCard(
      id: card.id.toString(),
      cardType: CardType.vocabulary,
      due: now,
    );

    // Schedule and keep the updated card
    final result = _scheduler.schedule(fsrsCard, rating, now);
    final updatedCard = result.card;

    // Persist the scheduled card (not the default)
    final repo = ref.read(vocabularyRepositoryProvider);
    repo.updateCard(updatedCard, rating, now);

    // Update counts
    final newAgain = state.againCount + (rating == Rating.again ? 1 : 0);
    final newHard = state.hardCount + (rating == Rating.hard ? 1 : 0);
    final newGood = state.goodCount + (rating == Rating.good ? 1 : 0);
    final newEasy = state.easyCount + (rating == Rating.easy ? 1 : 0);
    final newXp = state.totalXp + _xpForRating(rating);

    final nextIndex = state.currentIndex + 1;
    final isComplete = nextIndex >= state.dueCards.length;

    state = state.copyWith(
      currentIndex: nextIndex,
      isFlipped: false,
      reviewedCount: state.reviewedCount + 1,
      againCount: newAgain,
      hardCount: newHard,
      goodCount: newGood,
      easyCount: newEasy,
      totalXp: newXp,
      isComplete: isComplete,
    );

    // Award XP via gamification
    if (state.reviewedCount % 5 == 0) {
      final gamification = ref.read(gamificationProvider.notifier);
      gamification.onReviewSessionCompleted(5);
    }
  }

  int _xpForRating(Rating rating) {
    return switch (rating) {
      Rating.again => 0,
      Rating.hard => 1,
      Rating.good => 2,
      Rating.easy => 3,
    };
  }

  /// Restart the review session.
  Future<void> restart() async {
    await loadDueCards();
  }
}

/// Provider for the SRS review session.
final reviewSessionProvider =
    NotifierProvider<ReviewSessionNotifier, ReviewSessionState>(
  ReviewSessionNotifier.new,
);

/// Provider for the due card count (for the home screen badge).
final dueCardCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(vocabularyRepositoryProvider);
  return repo.getDueCount();
});