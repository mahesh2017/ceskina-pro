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
import 'daos/curriculum_dao.dart';
import 'daos/vocabulary_dao.dart';
import 'daos/conversation_dao.dart';
import 'daos/progress_dao.dart';

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
  ],
  daos: [
    CurriculumDao,
    VocabularyDao,
    ConversationDao,
    ProgressDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing — inject an in-memory database.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
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