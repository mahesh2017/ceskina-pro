import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../database/database.dart' as db;

/// Seeds the Drift database from JSON content packs in assets/.
///
/// On first launch, loads curriculum units, lessons, exercises,
/// grammar rules, and vocabulary from bundled JSON files.
class ContentSeeder {
  final db.AppDatabase _db;
  final _log = Logger('ContentSeeder');

  /// Unit ids present in the bundled unit files — used to validate
  /// unit references in other content so one dangling reference
  /// (e.g. vocabulary for a unit that isn't written yet) can't
  /// FK-fail and roll back the whole content sync.
  final Set<int> _validUnitIds = {};

  int? _validatedUnitId(Object? raw, String what) {
    if (raw == null) return null;
    final id = (raw as num).toInt();
    if (_validUnitIds.contains(id)) return id;
    _log.warning('$what references missing unit $id — keeping it unlinked.');
    return null;
  }

  ContentSeeder(this._db);

  /// Sync bundled content into the database on every launch.
  ///
  /// All content inserts are upserts, so this is idempotent AND delivers
  /// units/lessons/vocabulary added in an app update to existing installs.
  /// Learner state (SRS scheduling, lesson progress, XP) is never touched;
  /// new flashcards get fresh SRS cards afterwards.
  ///
  /// Runs inside a single transaction: a crash or bad asset mid-sync
  /// rolls everything back, so the next launch retries cleanly.
  Future<void> seedIfNeeded() async {
    _log.info('Syncing bundled content into the database...');

    await _db.transaction(() async {
      await _seedUnits();
      await _seedGrammarRules();
      await _seedVocabulary();
      await _createMissingSrsCards();
    });

    _log.info('Content sync complete.');
  }

  /// Coerce a JSON value into a nullable String for a text column.
  ///
  /// Lesson content authors sometimes express `answer_key` as an int
  /// (multiple-choice index) or a list (accepted answers) rather than a
  /// plain string. Preserve those non-destructively by JSON-encoding them
  /// instead of failing the whole content sync with a cast error.
  static String? _asNullableString(Object? value) => switch (value) {
        null => null,
        final String s => s,
        final other => jsonEncode(other),
      };

  /// Load and insert all units (A1 + A2).
  Future<void> _seedUnits() async {
    // A1 units
    final a1Json = await _loadAsset('assets/curriculum/a1_units.json');
    final a1Units = (jsonDecode(a1Json)['units'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final a1Companions = a1Units.map((u) => db.UnitsCompanion.insert(
          id: Value(u['id'] as int),
          title: u['title'] as String,
          description: u['description'] as String,
          phase: u['phase'] as String,
          orderIndex: u['order_index'] as int,
          grammarTags: Value((u['grammar_tags'] as List<dynamic>).join(',')),
          isExamPrep: Value(u['is_exam_prep'] as bool? ?? false),
        ),);

    await _db.curriculumDao.insertUnits(a1Companions.toList());
    _validUnitIds.addAll(a1Units.map((u) => u['id'] as int));

    // A2 units
    final a2Json = await _loadAsset('assets/curriculum/a2_units.json');
    final a2Units = (jsonDecode(a2Json)['units'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final a2Companions = a2Units.map((u) => db.UnitsCompanion.insert(
          id: Value(u['id'] as int),
          title: u['title'] as String,
          description: u['description'] as String,
          phase: u['phase'] as String,
          orderIndex: u['order_index'] as int,
          grammarTags: Value((u['grammar_tags'] as List<dynamic>).join(',')),
          isExamPrep: Value(u['is_exam_prep'] as bool? ?? false),
        ),);

    await _db.curriculumDao.insertUnits(a2Companions.toList());
    _validUnitIds.addAll(a2Units.map((u) => u['id'] as int));

    // Load lessons from individual lesson files (if they exist)
    await _seedLessons();
  }

  /// Load lessons from JSON files.
  Future<void> _seedLessons() async {
    // Lesson files are named: unit{NN}_lesson{NN}.json
    // Dynamically try loading lesson files for Units 1-8
    final lessonFiles = [
      'assets/curriculum/lessons/unit01_lesson01.json',
      'assets/curriculum/lessons/unit01_lesson02.json',
      'assets/curriculum/lessons/unit02_lesson01.json',
      'assets/curriculum/lessons/unit02_lesson02.json',
      'assets/curriculum/lessons/unit03_lesson01.json',
      'assets/curriculum/lessons/unit03_lesson02.json',
      'assets/curriculum/lessons/unit04_lesson01.json',
      'assets/curriculum/lessons/unit04_lesson02.json',
      'assets/curriculum/lessons/unit05_lesson01.json',
      'assets/curriculum/lessons/unit05_lesson02.json',
      'assets/curriculum/lessons/unit06_lesson01.json',
      'assets/curriculum/lessons/unit06_lesson02.json',
      'assets/curriculum/lessons/unit07_lesson01.json',
      'assets/curriculum/lessons/unit07_lesson02.json',
      'assets/curriculum/lessons/unit08_lesson01.json',
      'assets/curriculum/lessons/unit08_lesson02.json',
    ];

    for (final filePath in lessonFiles) {
      final String json;
      try {
        json = await _loadAsset(filePath);
      } on FlutterError {
        // Asset not bundled (yet) — fine to skip.
        _log.fine('Skipped (not found): $filePath');
        continue;
      }
      {
        final lessonData = jsonDecode(json) as Map<String, dynamic>;

        // Insert lesson
        await _db.curriculumDao.insertLessons([
          db.LessonsCompanion.insert(
            id: Value(lessonData['id'] as int),
            unitId: lessonData['unit_id'] as int,
            orderInUnit: lessonData['order_in_unit'] as int,
            title: lessonData['title'] as String,
            description: lessonData['description'] as String,
            durationMinutes: Value(lessonData['duration_min'] as int? ?? 10),
            lessonType: Value(lessonData['lesson_type'] as String? ?? 'introduction'),
            isReview: Value(lessonData['is_review'] as bool? ?? false),
          ),
        ]);

        // Insert exercises for this lesson
        final exercises =
            (lessonData['exercises'] as List<dynamic>?) ?? [];
        if (exercises.isNotEmpty) {
          await _db.curriculumDao.insertExercises(
            exercises.map((e) => db.ExercisesCompanion.insert(
                  id: Value((e as Map<String, dynamic>)['id'] as int),
                  lessonId: e['lesson_id'] as int,
                  type: e['type'] as String,
                  prompt: e['prompt'] as String,
                  data: jsonEncode(e['data']),
                  answerKey: Value(_asNullableString(e['answer_key'])),
                  grammarRuleId: Value(e['grammar_rule_id'] as String?),
                  xpReward: Value(e['xp_reward'] as int? ?? 10),
                ),).toList(),
          );
        }

        _log.info('Loaded lesson: $filePath');
      }
    }
  }

  /// Load and insert grammar rules.
  Future<void> _seedGrammarRules() async {
    final String json;
    try {
      json = await _loadAsset('assets/curriculum/grammar_rules.json');
    } on FlutterError {
      _log.fine('No grammar rules file found, skipping.');
      return;
    }
    {
      final rules = jsonDecode(json) as Map<String, dynamic>;

      if (rules.isEmpty) {
        _log.fine('No grammar rules to seed.');
        return;
      }

      final ruleList = (rules['rules'] as List<dynamic>?) ?? [];
      if (ruleList.isEmpty) return;

      await _db.curriculumDao.insertGrammarRules(
        ruleList.map((r) => db.GrammarRulesCompanion.insert(
              id: (r as Map<String, dynamic>)['id'] as String,
              ruleName: r['rule_name'] as String,
              pattern: r['pattern'] as String,
              explanation: r['explanation'] as String,
              caseAffected: Value(r['case_affected'] as String?),
              examples: Value(jsonEncode(r['examples'] ?? [])),
              unitId: Value(_validatedUnitId(
                  r['unit_id'], 'Grammar rule ${r['id']}',),),
            ),).toList(),
      );
    }
  }

  /// Load and upsert vocabulary flashcards.
  Future<void> _seedVocabulary() async {
    for (final level in ['a1', 'a2']) {
      final String json;
      try {
        json = await _loadAsset('assets/vocabulary/${level}_vocabulary.json');
      } on FlutterError {
        _log.fine('No $level vocabulary file found, skipping.');
        continue;
      }
      {
        final words = jsonDecode(json) as List<dynamic>;

        if (words.isEmpty) continue;

        final flashcardCompanions = words.map((w) => db.FlashcardsCompanion.insert(
              id: Value((w as Map<String, dynamic>)['id'] as int),
              wordCz: w['word_cz'] as String,
              wordEn: w['word_en'] as String,
              ipa: Value(w['ipa'] as String?),
              gender: Value(w['gender'] as String?),
              caseInfo: Value(w['case_info'] as String?),
              audioHash: Value(w['audio_hash'] as String?),
              imagePath: Value(w['image_path'] as String?),
              exampleCz: Value(w['example_cz'] as String?),
              exampleEn: Value(w['example_en'] as String?),
              unitId: Value(_validatedUnitId(
                  w['unit_id'], "Flashcard ${w['id']} '${w['word_cz']}'",),),
            ),).toList();

        await _db.vocabularyDao.insertFlashcards(flashcardCompanions);

        _log.info('Synced ${words.length} $level vocabulary words.');
      }
    }
  }

  /// Create SRS cards for any flashcard that doesn't have one yet —
  /// covers both first launch and vocabulary added in app updates.
  /// Existing SRS cards (and their scheduling state) are left untouched.
  Future<void> _createMissingSrsCards() async {
    final missingIds = await _db.vocabularyDao.flashcardIdsWithoutSrsCards();
    if (missingIds.isEmpty) return;

    for (final flashcardId in missingIds) {
      await _db.vocabularyDao.upsertSrsCard(db.SrsCardsCompanion.insert(
        cardType: 'vocabulary',
        flashcardId: Value(flashcardId),
        stability: const Value(0.0),
        difficulty: const Value(0.0),
        due: Value(DateTime.now()),
        reps: const Value(0),
        state: const Value('newCard'),
      ),);
    }

    _log.info('Created SRS cards for ${missingIds.length} new flashcards.');
  }

  /// Load a text asset, returning empty string if not found.
  Future<String> _loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }
}