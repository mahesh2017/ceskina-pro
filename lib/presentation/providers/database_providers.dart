import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/database.dart' as db;
import '../../data/repositories/drift_curriculum_repository.dart';
import '../../data/repositories/drift_vocabulary_repository.dart';
import '../../data/repositories/drift_conversation_repository.dart';
import '../../data/repositories/drift_progress_repository.dart';
import '../../data/seeds/content_seeder.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/progress_repository.dart';

/// Database singleton provider.
final databaseProvider = Provider<db.AppDatabase>((ref) {
  final database = db.AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Content seeder provider.
final contentSeederProvider = Provider<ContentSeeder>((ref) {
  return ContentSeeder(ref.read(databaseProvider));
});

/// Curriculum repository provider.
final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  return DriftCurriculumRepository(ref.read(databaseProvider));
});

/// Vocabulary repository provider.
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return DriftVocabularyRepository(ref.read(databaseProvider));
});

/// Conversation repository provider.
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return DriftConversationRepository(ref.read(databaseProvider));
});

/// Progress repository provider.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ref.read(databaseProvider));
});

/// SharedPreferences provider for lightweight KV storage.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// App initialization provider — seeds the database on first launch.
final appInitializationProvider = FutureProvider<void>((ref) async {
  final seeder = ref.read(contentSeederProvider);
  await seeder.seedIfNeeded();
});