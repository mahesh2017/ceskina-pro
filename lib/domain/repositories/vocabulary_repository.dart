import '../entities/flashcard.dart';
import '../entities/fsrs_card.dart';

/// A card due for review: the flashcard content plus its stored SRS
/// scheduling state. The [fsrs] card's id is the srs_cards row id, so
/// rating updates target the exact row the state was loaded from.
class ReviewCard {
  final Flashcard flashcard;
  final FSRSCard fsrs;

  const ReviewCard({required this.flashcard, required this.fsrs});
}

/// Abstract interface for vocabulary + SRS data access.
abstract class VocabularyRepository {
  Future<List<ReviewCard>> getDueCards({DateTime? asOf});
  Future<void> updateCard(FSRSCard card, Rating rating, DateTime reviewedAt);
  Future<List<Flashcard>> searchCards(String query);
  Future<List<Flashcard>> getCardsForUnit(int unitId);

  /// Vocabulary introduced by a specific lesson (for the teach phase).
  Future<List<Flashcard>> getCardsForLesson(int lessonId);
  Future<int> getDueCount({DateTime? asOf});

  /// Add a learner-created flashcard (e.g. vocabulary surfaced by the AI
  /// tutor) and give it a fresh SRS card. Returns false if a card with the
  /// same Czech word already exists.
  Future<bool> addManualCard({
    required String cz,
    required String en,
    String? ipa,
  });
}
