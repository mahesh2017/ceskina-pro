import '../../domain/entities/flashcard.dart' as entity;
import '../../domain/entities/fsrs_card.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import 'package:drift/drift.dart';
import '../database/database.dart' as db;

/// Concrete implementation of [VocabularyRepository] using Drift.
class DriftVocabularyRepository implements VocabularyRepository {
  final db.AppDatabase _db;

  DriftVocabularyRepository(this._db);

  @override
  Future<List<ReviewCard>> getDueCards({DateTime? asOf}) async {
    final now = asOf ?? DateTime.now();
    final dueSrsCards = await _db.vocabularyDao.getDueCards(now);
    if (dueSrsCards.isEmpty) return [];

    final vocabSrsCards = dueSrsCards
        .where((s) => s.cardType == 'vocabulary' && s.flashcardId != null)
        .toList();

    if (vocabSrsCards.isEmpty) return [];

    final allFlashcards = await _db.vocabularyDao.getAllFlashcards();
    final flashcardMap = {for (var f in allFlashcards) f.id: f};

    return [
      for (final srs in vocabSrsCards)
        if (flashcardMap.containsKey(srs.flashcardId))
          ReviewCard(
            flashcard: _toEntityFlashcard(flashcardMap[srs.flashcardId]!),
            fsrs: _toFsrsCard(srs),
          ),
    ];
  }

  @override
  Future<void> updateCard(FSRSCard card, Rating rating, DateTime reviewedAt) async {
    final cardId = int.tryParse(card.id);
    if (cardId == null) return;

    await _db.vocabularyDao.updateSrsCard(db.SrsCardsCompanion(
      id: Value(cardId),
      stability: Value(card.stability),
      difficulty: Value(card.difficulty),
      due: Value(card.due),
      reps: Value(card.reps),
      state: Value(card.state.name),
      lastReviewed: Value(reviewedAt),
    ));
  }

  @override
  Future<List<entity.Flashcard>> searchCards(String query) async {
    final rows = await _db.vocabularyDao.searchFlashcards(query);
    return rows.map(_toEntityFlashcard).toList();
  }

  @override
  Future<List<entity.Flashcard>> getCardsForUnit(int unitId) async {
    final rows = await _db.vocabularyDao.getFlashcardsByUnit(unitId);
    return rows.map(_toEntityFlashcard).toList();
  }

  @override
  Future<int> getDueCount({DateTime? asOf}) async {
    final now = asOf ?? DateTime.now();
    return _db.vocabularyDao.getDueCount(now);
  }

  FSRSCard _toFsrsCard(db.SrsCard row) {
    return FSRSCard(
      id: row.id.toString(),
      cardType:
          row.cardType == 'grammar' ? CardType.grammar : CardType.vocabulary,
      stability: row.stability,
      difficulty: row.difficulty,
      due: row.due,
      reps: row.reps,
      state: CardState.values.asNameMap()[row.state] ?? CardState.newCard,
      lastReview: row.lastReviewed,
    );
  }

  entity.Flashcard _toEntityFlashcard(db.Flashcard row) {
    return entity.Flashcard(
      id: row.id,
      wordCz: row.wordCz,
      wordEn: row.wordEn,
      ipa: row.ipa,
      gender: row.gender,
      caseInfo: row.caseInfo,
      audioHash: row.audioHash,
      imagePath: row.imagePath,
      exampleCz: row.exampleCz,
      exampleEn: row.exampleEn,
      unitId: row.unitId,
    );
  }
}