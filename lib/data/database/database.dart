import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'tables/units.dart';
import 'tables/lessons.dart';
import 'tables/exercises.dart';
import 'tables/flashcards.dart';
import 'tables/srs_cards.dart';
import 'tables/conversations.dart';
import 'tables/chat_messages.dart';
import 'tables/grammar_rules.dart';
import 'tables/exam_results.dart';
import 'tables/user_progress.dart';
import 'tables/earned_badges.dart';
import 'tables/lesson_progress.dart';
import 'tables/sync_queue.dart';
import 'tables/gamification_state.dart';
import 'daos/curriculum_dao.dart';
import 'daos/vocabulary_dao.dart';
import 'daos/conversation_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/gamification_dao.dart';

part 'database.g.dart';

/// Main Drift database for Čeština Pro.
@DriftDatabase(
  tables: [
    Units,
    Lessons,
    Exercises,
    Flashcards,
    SrsCards,
    Conversations,
    ChatMessages,
    GrammarRules,
    ExamResults,
    UserProgress,
    EarnedBadges,
    LessonProgress,
    SyncQueue,
    SyncState,
    GamificationStateTable,
  ],
  daos: [CurriculumDao, VocabularyDao, ConversationDao, ProgressDao, SyncDao, GamificationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing — inject an in-memory database.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  /// Portable snapshot of learner-created state. Bundled curriculum rows are
  /// intentionally excluded because they are app content, not user data.
  Future<Map<String, dynamic>> exportLearnerData() async => {
    'format_version': 1,
    'exported_at': DateTime.now().toUtc().toIso8601String(),
    'lesson_progress':
        (await select(lessonProgress).get())
            .map((row) => row.toJson())
            .toList(),
    'earned_badges':
        (await select(earnedBadges).get()).map((row) => row.toJson()).toList(),
    'user_progress':
        (await select(userProgress).get()).map((row) => row.toJson()).toList(),
    'srs_cards':
        (await select(srsCards).get()).map((row) => row.toJson()).toList(),
    'exam_results':
        (await select(examResults).get()).map((row) => row.toJson()).toList(),
    'conversations':
        (await select(conversations).get()).map((row) => row.toJson()).toList(),
    'chat_messages':
        (await select(chatMessages).get()).map((row) => row.toJson()).toList(),
    'custom_flashcards':
        (await (select(flashcards)
              ..where((row) => row.id.isBiggerThanValue(900000))).get())
            .map((row) => row.toJson())
            .toList(),
    'gamification_state':
        (await select(gamificationStateTable).get())
            .map((row) => row.toJson())
            .toList(),
  };

  /// Removes learner-created state before an account switch or after account
  /// deletion. Bundled curriculum/grammar/vocabulary remain available offline.
  Future<void> clearLearnerData() => transaction(() async {
    await delete(chatMessages).go();
    await delete(conversations).go();
    await delete(examResults).go();
    await delete(lessonProgress).go();
    await delete(earnedBadges).go();
    await delete(userProgress).go();
    await delete(srsCards).go();
    await (delete(flashcards)
      ..where((row) => row.id.isBiggerThanValue(900000))).go();
    await delete(syncQueue).go();
    await delete(syncState).go();
    await delete(gamificationStateTable).go();
  });

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // v2: per-lesson gating — flashcards learn which lesson taught
      // them. The seeder backfills values from the content pack on the
      // next launch, so the column just needs to exist.
      if (from < 2) {
        await m.addColumn(flashcards, flashcards.lessonId);
      }
      // v3: sync outbox for offline-first backend sync.
      if (from < 3) {
        await m.createTable(syncQueue);
      }
      // v4: local-only sync bookkeeping (pull cursors).
      if (from < 4) {
        await m.createTable(syncState);
      }
      // v5: bounded outbox retry and dead-letter diagnostics.
      if (from >= 3 && from < 5) {
        await m.addColumn(syncQueue, syncQueue.nextAttemptAt);
        await m.addColumn(syncQueue, syncQueue.deadLetteredAt);
        await m.addColumn(syncQueue, syncQueue.lastError);
      }
      // v6: gamification state moved from SharedPreferences to Drift for
      // transactional integrity and future cross-device sync.
      if (from < 6) {
        await m.createTable(gamificationStateTable);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ceskina_pro.db'));
    return NativeDatabase.createInBackground(file);
  });
}
