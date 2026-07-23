import 'dart:convert';

import 'package:ceskina_pro/data/database/database.dart';
import 'package:ceskina_pro/data/repositories/drift_vocabulary_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 0D: user-created ("manual") cards must sync by a stable UUID, never
/// the local autoincrement id. Two devices each allocate manual ids from
/// MAX(id)+1 (>= 900001), so the numeric id collides across devices while the
/// words differ — poisoning each other's SRS state on sync. The stable
/// content_uid removes that collision.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<String?> srsContentKey() async {
    final row = await (db.select(db.syncQueue)
          ..where((q) => q.entity.equals('srs_cards')))
        .getSingleOrNull();
    if (row == null) return null;
    return (jsonDecode(row.payload) as Map<String, dynamic>)['content_key']
        as String?;
  }

  Future<void> enqueueSrsFor(int flashcardId) async {
    final srs = await (db.select(db.srsCards)
          ..where((s) => s.flashcardId.equals(flashcardId)))
        .getSingle();
    // updateSrsCard is the outbox-enqueuing path (as a review would trigger).
    await db.vocabularyDao.updateSrsCard(
      SrsCardsCompanion(id: Value(srs.id), reps: const Value(1)),
    );
  }

  test('manual card syncs by its UUID content_uid, not the local id', () async {
    final repo = DriftVocabularyRepository(db);
    expect(await repo.addManualCard(cz: 'strom', en: 'tree'), isTrue);

    final card = await db.select(db.flashcards).getSingle();
    expect(card.contentUid, isNotNull);
    expect(card.id, greaterThanOrEqualTo(900001)); // local, collision-prone id

    await enqueueSrsFor(card.id);

    // The sync key is the stable UUID, NOT the local numeric id.
    expect(await srsContentKey(), card.contentUid);
    expect(await srsContentKey(), isNot(card.id.toString()));
  });

  test('managed (seeded) card still syncs by its deterministic id', () async {
    await db.into(db.flashcards).insert(
          FlashcardsCompanion.insert(id: const Value(42), wordCz: 'kniha', wordEn: 'book'),
        );
    await db.vocabularyDao.upsertSrsCard(
      SrsCardsCompanion.insert(
        cardType: 'vocabulary',
        flashcardId: const Value(42),
        reps: const Value(0),
        due: Value(DateTime.utc(2026, 7, 23)),
      ),
    );
    await enqueueSrsFor(42);

    expect(await srsContentKey(), '42');
  });
}
