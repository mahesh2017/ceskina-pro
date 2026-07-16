import 'dart:convert';
import 'package:drift/drift.dart';
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

  ContentSeeder(this._db);

  /// Seed all content if not already seeded.
  Future<void> seedIfNeeded() async {
    final isSeeded = await _db.curriculumDao.isSeeded();
    if (isSeeded) {
      _log.info('Database already seeded, skipping.');
      return;
    }

    _log.info('Seeding database from assets...');

    await _seedUnits();
    await _seedGrammarRules();
    await _seedVocabulary();

    _log.info('Database seeding complete.');
  }

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
        ));

    await _db.curriculumDao.insertUnits(a1Companions.toList());

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
        ));

    await _db.curriculumDao.insertUnits(a2Companions.toList());

    // Load lessons from individual lesson files (if they exist)
    await _seedLessons();
  }

  /// Load lessons from JSON files.
  Future<void> _seedLessons() async {
    // Lesson files are named: unit{NN}_lesson{NN}.json
    // Dynamically try loading common lesson patterns for Units 1-3
    final lessonFiles = [
      'assets/curriculum/lessons/unit01_lesson01.json',
      'assets/curriculum/lessons/unit01_lesson02.json',
      'assets/curriculum/lessons/unit02_lesson01.json',
      'assets/curriculum/lessons/unit02_lesson02.json',
      'assets/curriculum/lessons/unit03_lesson01.json',
      'assets/curriculum/lessons/unit03_lesson02.json',
    ];

    for (final filePath in lessonFiles) {
      try {
        final json = await _loadAsset(filePath);
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
                  answerKey: Value(e['answer_key'] as String?),
                  grammarRuleId: Value(e['grammar_rule_id'] as String?),
                  xpReward: Value(e['xp_reward'] as int? ?? 10),
                )).toList(),
          );
        }

        _log.info('Loaded lesson: $filePath');
      } catch (e) {
        // Lesson file doesn't exist yet — skip silently
        _log.fine('Skipped (not found): $filePath');
      }
    }
  }

  /// Load and insert grammar rules.
  Future<void> _seedGrammarRules() async {
    try {
      final json =
          await _loadAsset('assets/curriculum/grammar_rules.json');
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
              unitId: Value(r['unit_id'] as int?),
            )).toList(),
      );
    } catch (e) {
      _log.fine('No grammar rules file found, skipping.');
    }
  }

  /// Load and insert vocabulary.
  Future<void> _seedVocabulary() async {
    final vocabSeeded = await _db.vocabularyDao.isVocabularySeeded();
    if (vocabSeeded) return;

    for (final level in ['a1', 'a2']) {
      try {
        final json =
            await _loadAsset('assets/vocabulary/${level}_vocabulary.json');
        final words = jsonDecode(json) as List<dynamic>;

        if (words.isEmpty) continue;

        await _db.vocabularyDao.insertFlashcards(
          words.map((w) => db.FlashcardsCompanion.insert(
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
                unitId: Value(w['unit_id'] as int?),
              )).toList(),
        );

        _log.info('Loaded ${words.length} $level vocabulary words.');
      } catch (e) {
        _log.fine('No $level vocabulary file found, skipping.');
      }
    }
  }

  /// Load a text asset, returning empty string if not found.
  Future<String> _loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }
}