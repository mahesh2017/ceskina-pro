import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/engines/llm_orchestrator.dart';
import '../../domain/repositories/llm_service.dart';
import '../../data/repositories/deepseek_llm_service.dart';

/// Secure storage key for the DeepSeek API key.
const kDeepSeekApiKeyStorageKey = 'deepseek_api_key';

/// Provider for the secure storage instance.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for the API key (loaded from secure storage).
final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return storage.read(key: kDeepSeekApiKeyStorageKey);
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

/// Provider for the LLM orchestrator (stateless prompt builder/parser).
final llmOrchestratorProvider = Provider<LLMOrchestrator>((ref) {
  return const LLMOrchestrator();
});

/// Mock LLM service for development/demo when no API key is configured.
/// Returns canned responses shaped like the real contracts so every
/// AI-backed flow (chat, grammar check, writing eval) works offline.
class MockLlmService implements LlmService {
  @override
  Future<LlmResponse> complete(LlmRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final systemPrompt =
        request.messages.isNotEmpty ? request.messages.first.content : '';

    final String mockJson;
    if (systemPrompt.contains('CCE exam evaluator')) {
      // Writing evaluation contract
      mockJson = jsonEncode({
        'score': {
          'grammar': 70,
          'vocabulary': 68,
          'coherence': 72,
          'overall': 70,
        },
        'feedback':
            'Mock evaluation (no API key configured). Add a DeepSeek API key '
                'in Settings for real AI feedback on your writing.',
        'errors': <Map<String, dynamic>>[],
      });
    } else if (systemPrompt.contains('grammar expert')) {
      // Grammar check contract
      mockJson = jsonEncode({
        'corrected_text': '',
        'errors': <Map<String, dynamic>>[],
      });
    } else {
      // Conversation tutor contract
      mockJson = jsonEncode({
        'tutor_reply_cz': 'Ahoj! Jak se máš? Já se mám dobře. Co děláš dnes?',
        'tutor_reply_en':
            'Hi! How are you? I am doing well. What are you doing today?',
        'corrections': <Map<String, dynamic>>[],
        'new_vocabulary': [
          {'cz': 'ahoj', 'en': 'hello/hi', 'ipa': 'aɦoj'},
          {'cz': 'dobře', 'en': 'well/good', 'ipa': 'dobr̝ɛ'},
        ],
      });
    }

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
