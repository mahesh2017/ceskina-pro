/// SRS card state (FSRS).
enum CardState { newCard, learning, review, relearning }

/// Type of SRS card.
enum CardType { vocabulary, grammar }

/// FSRS card state for spaced repetition scheduling.
class FSRSCard {
  final String id;
  final CardType cardType;
  final double stability; // memory strength in days
  final double difficulty; // 1.0 - 10.0
  final DateTime due;
  final int reps;
  final CardState state;
  final DateTime? lastReview;

  const FSRSCard({
    required this.id,
    required this.cardType,
    this.stability = 0.0,
    this.difficulty = 0.0,
    required this.due,
    this.reps = 0,
    this.state = CardState.newCard,
    this.lastReview,
  });

  FSRSCard copyWith({
    double? stability,
    double? difficulty,
    DateTime? due,
    int? reps,
    CardState? state,
    DateTime? lastReview,
  }) {
    return FSRSCard(
      id: id,
      cardType: cardType,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      reps: reps ?? this.reps,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
    );
  }
}

/// Rating given by the learner after reviewing a card.
enum Rating { again, hard, good, easy }