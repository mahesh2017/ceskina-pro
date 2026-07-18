import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceskina_pro/domain/engines/llm_orchestrator.dart';
import 'package:ceskina_pro/domain/entities/chat_message.dart';
import 'package:ceskina_pro/domain/entities/enums.dart';
import 'package:ceskina_pro/domain/repositories/llm_service.dart';

void main() {
  const orchestrator = LLMOrchestrator();

  group('buildConversationRequest', () {
    test('uses a valid DeepSeek model ID', () {
      final request = orchestrator.buildConversationRequest(
        level: CEFRLevel.a1,
        scenario: 'test',
        userMessage: 'Ahoj',
        history: [],
      );
      // 'deepseek-v3' is NOT a valid API model ID — regression guard.
      expect(request.model, 'deepseek-chat');
    });

    test('appends the user message exactly once', () {
      final history = [
        ChatMessage.tutor(text: 'Ahoj!', conversationId: 'c1'),
        ChatMessage.user('Dobrý den', conversationId: 'c1'),
        ChatMessage.tutor(text: 'Jak se máš?', conversationId: 'c1'),
      ];

      final request = orchestrator.buildConversationRequest(
        level: CEFRLevel.a1,
        scenario: 'test',
        userMessage: 'Mám se dobře',
        history: history,
      );

      // system + 3 history + 1 new user message
      expect(request.messages.length, 5);
      final occurrences = request.messages
          .where((m) => m.content == 'Mám se dobře')
          .length;
      expect(occurrences, 1);
      expect(request.messages.last.role, LlmRole.user);
      expect(request.messages.first.role, LlmRole.system);
    });

    test('maps history roles correctly', () {
      final history = [
        ChatMessage.user('u1', conversationId: 'c1'),
        ChatMessage.tutor(text: 't1', conversationId: 'c1'),
      ];
      final request = orchestrator.buildConversationRequest(
        level: CEFRLevel.a2,
        scenario: 'test',
        userMessage: 'u2',
        history: history,
      );
      expect(request.messages[1].role, LlmRole.user);
      expect(request.messages[2].role, LlmRole.assistant);
    });
  });

  group('parseTutorResponse', () {
    test('parses a complete response', () {
      final response = LlmResponse(
        content: jsonEncode({
          'tutor_reply_cz': 'Ahoj!',
          'tutor_reply_en': 'Hi!',
          'corrections': [
            {
              'type': 'verb_conjugation',
              'user_said': 'já jsi',
              'correct': 'já jsem',
              'rule': 'být conjugation',
              'severity': 'error',
            }
          ],
          'new_vocabulary': [
            {'cz': 'ahoj', 'en': 'hi'},
          ],
        }),
      );

      final parsed = orchestrator.parseTutorResponse(response);
      expect(parsed.tutorReplyCz, 'Ahoj!');
      expect(parsed.corrections, hasLength(1));
      expect(parsed.corrections.first.type, CorrectionType.verbConjugation);
      expect(parsed.newVocabulary, hasLength(1));
    });

    test('tolerates missing optional fields', () {
      final response = LlmResponse(
        content: jsonEncode({'tutor_reply_cz': 'Ahoj!'}),
      );
      final parsed = orchestrator.parseTutorResponse(response);
      expect(parsed.tutorReplyEn, '');
      expect(parsed.corrections, isEmpty);
      expect(parsed.newVocabulary, isEmpty);
    });

    test('throws FormatException when the reply itself is missing', () {
      final response = LlmResponse(content: jsonEncode({'foo': 'bar'}));
      expect(
        () => orchestrator.parseTutorResponse(response),
        throwsFormatException,
      );
    });
  });

  group('CorrectionType.parse', () {
    test('accepts LLM snake_case labels', () {
      expect(CorrectionType.parse('verb_conjugation'),
          CorrectionType.verbConjugation);
      expect(CorrectionType.parse('word_order'), CorrectionType.wordOrder);
      expect(CorrectionType.parse('case'), CorrectionType.case_);
    });

    test('accepts Dart enum names persisted by older builds', () {
      expect(CorrectionType.parse('verbConjugation'),
          CorrectionType.verbConjugation);
      expect(CorrectionType.parse('case_'), CorrectionType.case_);
    });

    test('unknown labels fall back to other instead of crashing', () {
      expect(CorrectionType.parse('emphasis'), CorrectionType.other);
      expect(CorrectionType.parse(''), CorrectionType.other);
    });
  });
}
