import '../entities/flashcard.dart';
import '../entities/fsrs_card.dart';

/// Abstract interface for vocabulary + SRS data access.
abstract class VocabularyRepository {
  Future<List<Flashcard>> getDueCards({DateTime? asOf});
  Future<void> updateCard(FSRSCard card, Rating rating, DateTime reviewedAt);
  Future<List<Flashcard>> searchCards(String query);
  Future<List<Flashcard>> getCardsForUnit(int unitId);
  Future<int> getDueCount({DateTime? asOf});
}