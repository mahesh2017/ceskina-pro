import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/flashcards.dart';
import '../tables/srs_cards.dart';

part 'vocabulary_dao.g.dart';

/// Data access object for vocabulary + SRS card queries.
@DriftAccessor(tables: [Flashcards, SrsCards])
class VocabularyDao extends DatabaseAccessor<AppDatabase>
    with _$VocabularyDaoMixin {
  VocabularyDao(super.db);

  // ── Flashcards ──

  Future<List<Flashcard>> getAllFlashcards() => select(flashcards).get();

  Future<List<Flashcard>> getFlashcardsByUnit(int unitId) {
    return (select(flashcards)..where((f) => f.unitId.equals(unitId))).get();
  }

  Future<List<Flashcard>> searchFlashcards(String query) {
    return (select(flashcards)
          ..where((f) =>
              f.wordCz.like('%$query%') | f.wordEn.like('%$query%')))
        .get();
  }

  Future<void> insertFlashcards(List<FlashcardsCompanion> cardList) =>
      batch((b) => b.insertAll(flashcards, cardList));

  // ── SRS Cards ──

  Future<List<SrsCard>> getDueCards(DateTime asOf) {
    return (select(srsCards)
          ..where((s) => s.due.isSmallerOrEqualValue(asOf))
          ..orderBy([(s) => OrderingTerm.asc(s.due)]))
        .get();
  }

  Future<int> getDueCount(DateTime asOf) async {
    final result = await customSelect(
      'SELECT COUNT(*) AS c FROM srs_cards WHERE due <= ?',
      variables: [Variable.withDateTime(asOf)],
    ).getSingle();
    return result.read<int>('c');
  }

  Future<void> upsertSrsCard(SrsCardsCompanion card) =>
      into(srsCards).insertOnConflictUpdate(card);

  Future<void> updateSrsCard(SrsCardsCompanion card) =>
      (update(srsCards)..where((s) => s.id.equals(card.id.value)))
          .write(card);

  // ── Seed helpers ──

  Future<bool> isVocabularySeeded() async {
    final result = await customSelect('SELECT COUNT(*) AS c FROM flashcards').getSingle();
    return result.read<int>('c') > 0;
  }
}