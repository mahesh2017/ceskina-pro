import 'dart:convert';
import '../repositories/llm_service.dart';
import '../entities/chat_message.dart';
import '../entities/enums.dart';

/// LLM Orchestrator — builds prompts and parses structured responses.
/// Stateless: callers pass the built request to whichever [LlmService]
/// is currently configured.
class LLMOrchestrator {
  const LLMOrchestrator();

  /// Build a conversation turn request with system prompt and history.
  LlmRequest buildConversationRequest({
    required CEFRLevel level,
    required String scenario,
    required String userMessage,
    required List<ChatMessage> history,
  }) {
    final systemPrompt = _buildTutorPrompt(level, scenario);
    final messages = <LlmMessage>[
      LlmMessage(LlmRole.system, systemPrompt),
      ...history.map((m) => LlmMessage(
            m.role == MessageRole.user ? LlmRole.user : LlmRole.assistant,
            m.content,
          ),),
      LlmMessage(LlmRole.user, userMessage),
    ];

    return LlmRequest(
      model: _selectModel(level),
      messages: messages,
      temperature: 0.7,
    );
  }

  /// Parse the LLM response into structured data.
  TutorResponse parseTutorResponse(LlmResponse response) {
    final json = jsonDecode(response.content) as Map<String, dynamic>;
    return TutorResponse.fromJson(json);
  }

  /// Build a grammar check request.
  LlmRequest buildGrammarCheckRequest({
    required CEFRLevel level,
    required String userText,
  }) {
    final systemPrompt = '''
You are a Czech grammar expert. Correct the following Czech text from a CEFR ${level.label} learner.

Return JSON: {
  "corrected_text": "...",
  "errors": [
    {"type": "case|verb_conjugation|aspect|word_order|gender_agreement|spelling|vowel_length|preposition",
     "original": "...", "correction": "...", "explanation": "..."}
  ]
}

User's text: "$userText"
''';

    return LlmRequest(
      model: _selectModel(level),
      messages: [LlmMessage(LlmRole.system, systemPrompt)],
      temperature: 0.3,
    );
  }

  /// Build a writing evaluation request (for mock exam writing section).
  LlmRequest buildWritingEvaluationRequest({
    required CEFRLevel level,
    required String taskDescription,
    required String learnerText,
  }) {
    final systemPrompt = '''
You are a CCE exam evaluator. Assess the learner's Czech writing at ${level.label} level.

Task: $taskDescription
Learner's text: "$learnerText"

Evaluate grammar, vocabulary, and coherence (0-100 each).
Return JSON: {
  "score": {"grammar": 0-100, "vocabulary": 0-100, "coherence": 0-100, "overall": 0-100},
  "feedback": "...",
  "errors": [...]
}
''';

    return LlmRequest(
      model: _selectModel(level),
      messages: [LlmMessage(LlmRole.system, systemPrompt)],
      temperature: 0.3,
    );
  }

  String _buildTutorPrompt(CEFRLevel level, String scenario) {
    return '''
You are a patient Czech language tutor for a CEFR ${level.label} learner.

Rules:
- Respond primarily in Czech using vocabulary appropriate for ${level.label}.
- Keep responses short: max 3 sentences for A1, max 5 sentences for A2.
- If the learner makes a grammar error, correct it and explain the rule briefly in English.
- Stay in character for the scenario: "$scenario".
- Include English translation for any new vocabulary in brackets.
- Return your response as JSON matching this schema:
{
  "tutor_reply_cz": "...",
  "tutor_reply_en": "...",
  "corrections": [
    {"type": "case|verb_conjugation|aspect|word_order|gender_agreement|spelling|vowel_length",
     "user_said": "...", "correct": "...", "rule": "...", "severity": "error|minor|stylistic"}
  ],
  "new_vocabulary": [
    {"cz": "...", "en": "...", "ipa": "..."}
  ]
}
''';
  }

  String _selectModel(CEFRLevel level) {
    // 'deepseek-chat' is the official API model ID for DeepSeek-V3 —
    // the cheapest model that handles Czech well.
    return 'deepseek-chat';
  }
}