import '../../domain/entities/flashcard.dart' as entity;
import '../../domain/entities/srs_card.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
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

    final vocabSrsCards =
        dueSrsCards
            .where((s) => s.cardType == 'vocabulary' && s.flashcardId != null)
            .toList();

    if (vocabSrsCards.isEmpty) return [];

    final flashcards = await _db.vocabularyDao.getFlashcardsByIds([
      for (final s in vocabSrsCards) s.flashcardId!,
    ]);
    final flashcardMap = {for (var f in flashcards) f.id: f};

    return [
      for (final srs in vocabSrsCards)
        if (flashcardMap.containsKey(srs.flashcardId))
          ReviewCard(
            flashcard: _toEntityFlashcard(flashcardMap[srs.flashcardId]!),
            srs: _toSrsCard(srs),
          ),
    ];
  }

  @override
  Future<SrsCard> updateCard(
    SrsCard card,
    Rating rating,
    DateTime reviewedAt, {
    required String reviewId,
    required bool introducedNewCard,
  }) async {
    final cardId = int.tryParse(card.id);
    if (cardId == null) {
      throw ArgumentError.value(card.id, 'card.id', 'must be a local row ID');
    }

    await _db.vocabularyDao.commitSrsReview(
      reviewId: reviewId,
      card: db.SrsCardsCompanion(
        id: Value(cardId),
        stability: Value(card.stability),
        difficulty: Value(card.difficulty),
        due: Value(card.due),
        reps: Value(card.reps),
        state: Value(card.state.name),
        lastReviewed: Value(reviewedAt),
      ),
      rating: rating.name,
      reviewedAt: reviewedAt,
      introducedNewCard: introducedNewCard,
    );
    return card;
  }

  @override
  Future<int> introducedCardCountForDay(DateTime day) {
    return _db.vocabularyDao.introducedCardCountForDay(day);
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
  Future<List<entity.Flashcard>> getCardsForLesson(int lessonId) async {
    final rows = await _db.vocabularyDao.getFlashcardsByLesson(lessonId);
    return rows.map(_toEntityFlashcard).toList();
  }

  @override
  Future<int> getDueCount({DateTime? asOf}) async {
    final now = asOf ?? DateTime.now();
    return _db.vocabularyDao.getDueCount(now);
  }

  @override
  Future<bool> addManualCard({
    required String cz,
    required String en,
    String? ipa,
  }) async {
    final existing = await _db.vocabularyDao.findByWordCz(cz);
    if (existing != null) return false;

    final id = await _db.vocabularyDao.nextFlashcardId();
    await _db.vocabularyDao.insertFlashcards([
      db.FlashcardsCompanion.insert(
        id: Value(id),
        wordCz: cz,
        wordEn: en,
        ipa: Value(ipa),
        // Stable cross-device identity for this user-created card.
        contentUid: Value(const Uuid().v4()),
      ),
    ]);
    // Sync the definition so other devices can materialize the word before its
    // dependent SRS scheduling row arrives.
    await _db.vocabularyDao.enqueueCustomCard(id);
    await _db.vocabularyDao.upsertSrsCard(
      db.SrsCardsCompanion.insert(
        cardType: 'vocabulary',
        flashcardId: Value(id),
        stability: const Value(0.0),
        difficulty: const Value(0.0),
        due: Value(DateTime.now()),
        reps: const Value(0),
        state: const Value('newCard'),
      ),
    );
    return true;
  }

  SrsCard _toSrsCard(db.SrsCard row) {
    return SrsCard(
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
      lemma: row.lemma,
      senseKey: row.senseKey,
      partOfSpeech: row.partOfSpeech,
      morphologyJson: row.morphologyJson,
      registerLabel: row.registerLabel,
      pronunciationSource: row.pronunciationSource,
      unitId: row.unitId,
      lessonId: row.lessonId,
    );
  }
}
