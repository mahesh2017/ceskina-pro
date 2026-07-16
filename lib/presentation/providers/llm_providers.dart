import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/engines/llm_orchestrator.dart';
import '../../domain/repositories/llm_service.dart';
import '../../data/repositories/deepseek_llm_service.dart';
import 'database_providers.dart';

/// Secure storage key for the DeepSeek API key.
const _kDeepSeekApiKey = 'deepseek_api_key';

/// Provider for the secure storage instance.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for the API key (loaded from secure storage).
final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return storage.read(key: _kDeepSeekApiKey);
});

/// Provider for the LLM service.
/// Returns a DeepSeekLlmService if an API key is configured,
/// or a MockLlmService for development/demo purposes.
final llmServiceProvider = Provider<LlmService>((ref) {
  final apiKeyAsync = ref.watch(apiKeyProvider);
  return apiKeyAsync.maybeWhen(
    data: (apiKey) {
      if (apiKey != null && apiKey.isNotEmpty) {
        return DeepSeekLlmService(apiKey: apiKey);
      }
      return MockLlmService();
    },
    orElse: () => MockLlmService(),
  );
});

/// Provider for the LLM orchestrator.
final llmOrchestratorProvider = Provider<LLMOrchestrator>((ref) {
  final llm = ref.read(llmServiceProvider);
  return LLMOrchestrator(llm);
});

/// Saves the DeepSeek API key to secure storage.
Future<void> saveApiKey(WidgetRef ref, String key) async {
  final storage = ref.read(secureStorageProvider);
  await storage.write(key: _kDeepSeekApiKey, value: key);
  ref.invalidate(apiKeyProvider);
}

/// Clears the API key.
Future<void> clearApiKey(WidgetRef ref) async {
  final storage = ref.read(secureStorageProvider);
  await storage.delete(key: _kDeepSeekApiKey);
  ref.invalidate(apiKeyProvider);
}

/// Mock LLM service for development/demo when no API key is configured.
/// Returns canned responses so the chat UI can be tested without an API.
class MockLlmService implements LlmService {
  @override
  Future<LlmResponse> complete(LlmRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Return a canned tutor response
    final mockJson = jsonEncode({
      'tutor_reply_cz': 'Ahoj! Jak se máš? Já se mám dobře. Co děláš dnes?',
      'tutor_reply_en': 'Hi! How are you? I am doing well. What are you doing today?',
      'corrections': [],
      'new_vocabulary': [
        {'cz': 'ahoj', 'en': 'hello/hi', 'ipa': 'aɦoj'},
        {'cz': 'dobře', 'en': 'well/good', 'ipa': 'dobr̝ɛ'},
      ],
    });

    return LlmResponse(
      content: mockJson,
      inputTokens: 50,
      outputTokens: 80,
      model: 'mock',
    );
  }

  @override
  Stream<LlmChunk> streamComplete(LlmRequest request) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield const LlmChunk(delta: 'Ahoj!', isFinal: true);
  }

  @override
  Future<bool> isAvailable() async => true;
}