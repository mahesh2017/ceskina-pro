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

  Future<List<Flashcard>> getFlashcardsByLesson(int lessonId) {
    return (select(flashcards)..where((f) => f.lessonId.equals(lessonId)))
        .get();
  }

  Future<List<Flashcard>> getFlashcardsByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(flashcards)..where((f) => f.id.isIn(ids))).get();
  }

  Future<List<Flashcard>> searchFlashcards(String query) {
    return (select(flashcards)
          ..where((f) =>
              f.wordCz.like('%$query%') | f.wordEn.like('%$query%'),))
        .get();
  }

  /// Upsert (update-in-place on conflict) so vocabulary edits in app
  /// updates propagate without breaking the FK from srs_cards.
  Future<void> insertFlashcards(List<FlashcardsCompanion> cardList) =>
      batch((b) => b.insertAllOnConflictUpdate(flashcards, cardList));

  /// Next free flashcard id — user-added cards (e.g. from chat) get ids
  /// above the seeded content so they never collide with content updates.
  Future<int> nextFlashcardId() async {
    final r = await customSelect(
      'SELECT COALESCE(MAX(id), 0) AS m FROM flashcards',
    ).getSingle();
    // Keep manual cards well clear of the seeded id range.
    final maxId = r.read<int>('m');
    return (maxId < 900000 ? 900000 : maxId) + 1;
  }

  Future<Flashcard?> findByWordCz(String wordCz) async {
    final rows = await (select(flashcards)
          ..where((f) => f.wordCz.lower().equals(wordCz.toLowerCase())))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Flashcards that don't have an SRS card yet (new content).
  Future<List<int>> flashcardIdsWithoutSrsCards() async {
    final rows = await customSelect(
      'SELECT f.id AS id FROM flashcards f '
      'LEFT JOIN srs_cards s ON s.flashcard_id = f.id '
      'WHERE s.id IS NULL',
    ).get();
    return rows.map((r) => r.read<int>('id')).toList();
  }

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

  Future<int> srsCardCount() async {
    final result = await customSelect('SELECT COUNT(*) AS c FROM srs_cards')
        .getSingle();
    return result.read<int>('c');
  }

  Future<void> updateSrsCard(SrsCardsCompanion card) async {
    final id = card.id.value;
    await (update(srsCards)..where((s) => s.id.equals(id))).write(card);
    await _enqueueSrsCard(id);
  }

  /// Append the current SRS state of card [id] to the sync outbox, keyed by
  /// content (flashcard id or grammar pattern key) so it stays stable across
  /// devices — never the local autoincrement id.
  Future<void> _enqueueSrsCard(int id) async {
    final row =
        await (select(srsCards)..where((s) => s.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    final contentKey = row.cardType == 'grammar'
        ? row.grammarPatternKey
        : row.flashcardId?.toString();
    if (contentKey == null) return; // malformed card; nothing stable to key on
    await attachedDatabase.syncDao.enqueue(
      entity: 'srs_cards',
      entityKey: '${row.cardType}:$contentKey',
      payload: {
        'card_type': row.cardType,
        'content_key': contentKey,
        'stability': row.stability,
        'difficulty': row.difficulty,
        'due': row.due.toUtc().toIso8601String(),
        'reps': row.reps,
        'state': row.state,
        'last_reviewed': row.lastReviewed?.toUtc().toIso8601String(),
      },
    );
  }

  // ── Seed helpers ──

  Future<bool> isVocabularySeeded() async {
    final result = await customSelect('SELECT COUNT(*) AS c FROM flashcards').getSingle();
    return result.read<int>('c') > 0;
  }
}