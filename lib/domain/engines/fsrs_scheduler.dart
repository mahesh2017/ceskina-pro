import '../entities/fsrs_card.dart';

/// Result of scheduling a card review.
class SchedulingResult {
  final FSRSCard card;
  final DateTime nextReviewDate;

  const SchedulingResult({required this.card, required this.nextReviewDate});
}

/// FSRS-based spaced repetition scheduler.
///
/// Wraps the dart-fsrs package. Until the package is published,
/// this uses a simplified SM-2 fallback implementation.
class FSRSScheduler {
  // SM-2 parameters (fallback until dart-fsrs is available)
  static const double _initialEaseFactor = 2.5;
  static const double _minEaseFactor = 1.3;

  /// Calculate the next review date and update card state.
  SchedulingResult schedule(FSRSCard card, Rating rating, DateTime now) {
    // Simplified SM-2 implementation
    // TODO: Replace with dart-fsrs when package is available on pub.dev
    var newReps = card.reps + 1;
    // Use the card's existing difficulty (ease factor) instead of always resetting to 2.5
    var newEase = card.difficulty > 0 ? card.difficulty : _initialEaseFactor;
    var interval = 1;

    if (rating == Rating.again) {
      newReps = 0;
      interval = 1;
      newEase = (newEase - 0.2).clamp(_minEaseFactor, 3.0);
    } else if (card.reps == 0) {
      interval = switch (rating) {
        Rating.hard => 1,
        Rating.good => 1,
        Rating.easy => 4,
        Rating.again => 1,
      };
    } else if (card.reps == 1) {
      interval = switch (rating) {
        Rating.hard => 3,
        Rating.good => 6,
        Rating.easy => 8,
        Rating.again => 1,
      };
    } else {
      final easeAdjustment = switch (rating) {
        Rating.again => -0.2,
        Rating.hard => -0.15,
        Rating.good => 0.0,
        Rating.easy => 0.15,
      };
      // Accumulate ease from the card's stored value, not from the constant
      newEase = (newEase + easeAdjustment).clamp(_minEaseFactor, 3.0);
      interval = (card.stability * newEase).round();
      interval = interval.clamp(1, 365);
    }

    final newDifficulty = newEase;
    final newDue = now.add(Duration(days: interval));
    final newState = switch (rating) {
      Rating.again => CardState.relearning,
      Rating.hard => CardState.review,
      Rating.good => CardState.review,
      Rating.easy => CardState.review,
    };

    final updatedCard = card.copyWith(
      stability: interval.toDouble(),
      difficulty: newDifficulty,
      due: newDue,
      reps: newReps,
      state: newState,
      lastReview: now,
    );

    return SchedulingResult(card: updatedCard, nextReviewDate: newDue);
  }

  /// Get all cards due for review on or before [asOf].
  List<FSRSCard> getDueCards(List<FSRSCard> allCards, DateTime asOf) {
    return allCards.where((c) => c.due.isBefore(asOf) || c.due.isAtSameMomentAs(asOf)).toList();
  }
}