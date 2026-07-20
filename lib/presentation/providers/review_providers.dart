import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/engines/srs_scheduler.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import 'curriculum_providers.dart';
import 'database_providers.dart';
import 'gamification_providers.dart';

/// Max brand-new cards introduced per calendar day. Prevents the whole
/// deck (200+ words) from becoming "due" at once on first launch.
const kDailyNewCardLimit = 15;

/// Max cards shown in a single review session (new + due-for-review).
const kMaxSessionCards = 30;

const _kNewCardsToday = 'srs_new_cards_today';
const _kNewCardsDate = 'srs_new_cards_date';

/// The set of unit ids the learner has reached, used as the fallback gate
/// for words not mapped to a specific lesson.
Future<Set<int>> _unlockedUnits(Ref ref) async {
  try {
    return await ref.read(unlockedUnitIdsProvider.future);
  } catch (_) {
    return const {};
  }
}

/// The set of lesson ids the learner has completed, used as the primary gate
/// for words that declare which lesson teaches them.
Future<Set<int>> _completedLessons(Ref ref) async {
  try {
    return await ref.read(completedLessonIdsProvider.future);
  } catch (_) {
    return const {};
  }
}

/// New cards already introduced today (resets at midnight).
int _introducedToday(SharedPreferences prefs) {
  final now = DateTime.now();
  final today = '${now.year}-${now.month}-${now.day}';
  if (prefs.getString(_kNewCardsDate) != today) return 0;
  return prefs.getInt(_kNewCardsToday) ?? 0;
}

Future<void> _recordIntroduced(SharedPreferences prefs, int count) async {
  final now = DateTime.now();
  final today = '${now.year}-${now.month}-${now.day}';
  await prefs.setString(_kNewCardsDate, today);
  await prefs.setInt(_kNewCardsToday, count);
}

/// Which side of the card is shown first.
enum CardDirection {
  /// Czech word shown, recall the English meaning (recognition).
  czToEn,

  /// English shown, recall the Czech word (production — what the CCE
  /// exam actually demands).
  enToCz,

  /// Audio only — listen and recall the meaning.
  audio,
}

/// A card scheduled into a session together with its presentation
/// direction for this session.
class SessionCard {
  final ReviewCard review;
  final CardDirection direction;

  const SessionCard(this.review, this.direction);

  Flashcard get flashcard => review.flashcard;
  SrsCard get srs => review.srs;
}

/// Direction for a card this session: new cards are always recognition;
/// once a card has a few successful reps, mix in production and listening
/// fronts deterministically so the variety is stable within a session.
CardDirection directionFor(ReviewCard c) {
  if (c.srs.reps < 2) return CardDirection.czToEn;
  return switch ((c.flashcard.id + c.srs.reps) % 3) {
    0 => CardDirection.enToCz,
    1 => CardDirection.audio,
    _ => CardDirection.czToEn,
  };
}

/// The cards selected for one review session and how many of them are brand
/// new. Keeps the home due-count badge and the review screen in agreement.
class SessionPlan {
  final List<SessionCard> cards;
  final int newCount;
  const SessionPlan(this.cards, this.newCount);
}

/// Whether a brand-new card may be introduced yet. A word tied to a specific
/// lesson waits until that lesson is completed; words with only a unit fall
/// back to unit-unlock gating; words with neither are always eligible.
bool _introducible(
  ReviewCard c,
  Set<int> completedLessons,
  Set<int> unlockedUnits,
) {
  final lessonId = c.flashcard.lessonId;
  if (lessonId != null) return completedLessons.contains(lessonId);
  final unitId = c.flashcard.unitId;
  if (unitId != null) return unlockedUnits.contains(unitId);
  return true;
}

/// Pure composition of a review session: due reviews first (most at risk of
/// being forgotten), then new cards gated by curriculum progress, the daily
/// new budget, and the overall session cap.
SessionPlan planReviewSession({
  required List<ReviewCard> allDue,
  required Set<int> unlockedUnits,
  required int introducedToday,
  Set<int> completedLessons = const {},
}) {
  final newCards = <ReviewCard>[];
  final reviewCards = <ReviewCard>[];
  for (final c in allDue) {
    final isNew = c.srs.state == CardState.newCard || c.srs.reps == 0;
    if (isNew) {
      if (_introducible(c, completedLessons, unlockedUnits)) newCards.add(c);
    } else {
      reviewCards.add(c);
    }
  }

  final newBudget =
      (kDailyNewCardLimit - introducedToday).clamp(0, kDailyNewCardLimit);

  final session = <ReviewCard>[...reviewCards.take(kMaxSessionCards)];
  final remainingSlots =
      (kMaxSessionCards - session.length).clamp(0, kMaxSessionCards);
  final newToShow =
      newCards.take(remainingSlots.clamp(0, newBudget)).toList();
  session.addAll(newToShow);

  return SessionPlan(
    [for (final c in session) SessionCard(c, directionFor(c))],
    newToShow.length,
  );
}

/// State of an SRS review session.
class ReviewSessionState {
  final List<SessionCard> dueCards;
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

  /// True when finishing this session restored a heart.
  final bool heartEarned;

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
    this.heartEarned = false,
  });

  ReviewSessionState copyWith({
    List<SessionCard>? dueCards,
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
    bool? heartEarned,
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
      heartEarned: heartEarned ?? this.heartEarned,
    );
  }

  SessionCard? get currentCard =>
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
  final _scheduler = SrsScheduler();

  @override
  ReviewSessionState build() => const ReviewSessionState();

  /// Load due cards from the database, gating new cards by curriculum
  /// progress and capping brand-new cards per day and total session size so
  /// a fresh learner isn't flooded with the whole deck.
  Future<void> loadDueCards() async {
    state = const ReviewSessionState(isLoading: true);
    final repo = ref.read(vocabularyRepositoryProvider);
    final allDue = await repo.getDueCards();
    final unlockedUnits = await _unlockedUnits(ref);
    final completedLessons = await _completedLessons(ref);

    final prefs = await SharedPreferences.getInstance();
    final introducedToday = _introducedToday(prefs);

    final plan = planReviewSession(
      allDue: allDue,
      unlockedUnits: unlockedUnits,
      completedLessons: completedLessons,
      introducedToday: introducedToday,
    );

    // Record how many new cards we introduced so tomorrow starts fresh.
    if (plan.newCount > 0) {
      await _recordIntroduced(prefs, introducedToday + plan.newCount);
    }

    state = ReviewSessionState(
      dueCards: plan.cards,
      isLoading: false,
      isComplete: plan.cards.isEmpty,
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

    // Schedule from the card's stored SRS state so intervals and ease
    // accumulate across reviews, then persist the scheduled result.
    final result = _scheduler.schedule(card.srs, rating, now);

    final repo = ref.read(vocabularyRepositoryProvider);
    repo.updateCard(result.card, rating, now).whenComplete(() {
      // Refresh the home-screen due count once the new due date is stored.
      ref.invalidate(dueCardCountProvider);
    });

    // Update counts
    final newAgain = state.againCount + (rating == Rating.again ? 1 : 0);
    final newHard = state.hardCount + (rating == Rating.hard ? 1 : 0);
    final newGood = state.goodCount + (rating == Rating.good ? 1 : 0);
    final newEasy = state.easyCount + (rating == Rating.easy ? 1 : 0);
    final newXp = state.totalXp + _xpForRating(rating);

    // Relapse: a card rated "Again" comes back later in the SAME session
    // (Anki-style learning queue) so the learner actually re-encounters it
    // before the session ends, not a day later.
    final newDue =
        rating == Rating.again ? [...state.dueCards, card] : state.dueCards;

    final nextIndex = state.currentIndex + 1;
    final isComplete = nextIndex >= newDue.length;

    state = state.copyWith(
      dueCards: newDue,
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

    // Award XP via gamification: a block of 5 as the session progresses,
    // plus whatever remainder is left when the session completes.
    final gamification = ref.read(gamificationProvider.notifier);
    if (state.reviewedCount % 5 == 0) {
      gamification.onReviewSessionCompleted(5);
    } else if (isComplete) {
      gamification.onReviewSessionCompleted(state.reviewedCount % 5);
    }

    // Reviewing is the productive way back from an empty hearts pool:
    // finishing a real session (5+ cards) restores one heart.
    if (isComplete && state.reviewedCount >= 5) {
      final g = ref.read(gamificationProvider);
      if (g.hearts < g.maxHearts) {
        gamification.refillHeart();
        state = state.copyWith(heartEarned: true);
      }
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

/// Provider for the due card count (for the home screen badge). Reflects the
/// cards the next session would actually show — gated by unlocked units and
/// the daily/session caps — so the badge and the review screen agree.
final dueCardCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(vocabularyRepositoryProvider);
  final allDue = await repo.getDueCards();
  final unlockedUnits = await _unlockedUnits(ref);
  final completedLessons = await _completedLessons(ref);
  final prefs = await SharedPreferences.getInstance();
  final plan = planReviewSession(
    allDue: allDue,
    unlockedUnits: unlockedUnits,
    completedLessons: completedLessons,
    introducedToday: _introducedToday(prefs),
  );
  return plan.cards.length;
});