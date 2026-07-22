import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/engines/llm_orchestrator.dart';
import '../../domain/repositories/llm_service.dart';
import '../../data/repositories/supabase_llm_service.dart';
import 'sync_providers.dart';

/// Provider for the LLM service.
/// Uses the authenticated Supabase Edge Function when the backend is enabled,
/// or a mock service for offline development before project configuration.
final llmServiceProvider = Provider<LlmService>((ref) {
  final backend = ref.watch(backendServiceProvider);
  if (backend.isEnabled && backend.isSignedIn) {
    return SupabaseLlmService(client: Supabase.instance.client);
  }
  return MockLlmService();
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

    final String mockJson;
    if (request.operation == LlmOperation.writingEvaluation) {
      // Writing evaluation contract
      mockJson = jsonEncode({
        'score': {
          'grammar': 70,
          'vocabulary': 68,
          'coherence': 72,
          'overall': 70,
        },
        'feedback':
            'Mock evaluation (backend not configured). Connect the Czechify '
            'backend for real AI feedback on your writing.',
        'errors': <Map<String, dynamic>>[],
      });
    } else if (request.operation == LlmOperation.grammarCheck) {
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
        'suggested_replies': ['Mám se dobře, děkuji.', 'Dnes se učím česky.'],
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
