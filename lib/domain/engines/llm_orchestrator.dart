import 'dart:convert';
import 'package:logging/logging.dart';
import '../repositories/llm_service.dart';
import '../entities/chat_message.dart';
import '../entities/enums.dart';

/// LLM Orchestrator — builds prompts and parses structured responses.
/// Stateless: callers pass the built request to whichever [LlmService]
/// is currently configured.
class LLMOrchestrator {
  const LLMOrchestrator();

  static final _log = Logger('LLMOrchestrator');

  /// Build a conversation turn request with system prompt and history.
  LlmRequest buildConversationRequest({
    required CEFRLevel level,
    required String scenarioId,
    required String userMessage,
    required List<ChatMessage> history,
  }) {
    final messages = <LlmMessage>[
      ...history.map(
        (m) => LlmMessage(
          m.role == MessageRole.user ? LlmRole.user : LlmRole.assistant,
          m.content,
        ),
      ),
      LlmMessage(LlmRole.user, userMessage),
    ];

    return LlmRequest(
      operation: LlmOperation.conversation,
      model: _selectModel(level),
      messages: messages,
      context: {'level': level.name, 'scenario_id': scenarioId},
    );
  }

  /// Parse the LLM response into structured data.
  ///
  /// Throws [FormatException] when the response is not valid JSON or is
  /// missing required fields. Callers are expected to catch this and show
  /// a user-facing fallback. The [parseTutorResponseSafe] variant returns
  /// a typed result instead.
  TutorResponse parseTutorResponse(LlmResponse response) {
    final json = jsonDecode(response.content) as Map<String, dynamic>;
    return TutorResponse.fromJson(json);
  }

  /// Parse the LLM response with structured error handling.
  ///
  /// Returns a [TutorParseResult] that distinguishes between:
  /// - [TutorParseOk] — successful parse
  /// - [TutorParseError] — malformed JSON or missing fields, with a
  ///   human-readable reason and the raw content length for telemetry.
  ///
  /// This is the preferred entry point for new call sites. The throwing
  /// [parseTutorResponse] is retained for backward compatibility.
  TutorParseResult parseTutorResponseSafe(LlmResponse response) {
    final content = response.content;
    if (content.isEmpty) {
      _log.warning('LLM returned empty content');
      return const TutorParseError(
        reason: 'The tutor returned an empty response.',
      );
    }

    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        _log.warning('LLM returned non-object JSON: ${decoded.runtimeType}');
        return const TutorParseError(
          reason: 'The tutor response was not a JSON object.',
        );
      }
      json = decoded;
    } on FormatException catch (e) {
      _log.warning('LLM returned invalid JSON: ${e.message}');
      return TutorParseError(
        reason: 'The tutor sent an unreadable reply.',
        rawLength: content.length,
      );
    }

    try {
      return TutorParseOk(TutorResponse.fromJson(json));
    } on FormatException catch (e) {
      _log.warning('LLM JSON missing required fields: ${e.message}');
      return TutorParseError(
        reason: 'The tutor response was missing required information.',
        rawLength: content.length,
      );
    } on TypeError catch (e) {
      _log.warning('LLM JSON has wrong types: $e');
      return TutorParseError(
        reason: 'The tutor response had unexpected data.',
        rawLength: content.length,
      );
    }
  }

  /// Build a grammar check request.
  LlmRequest buildGrammarCheckRequest({
    required CEFRLevel level,
    required String userText,
  }) {
    return LlmRequest(
      operation: LlmOperation.grammarCheck,
      model: _selectModel(level),
      messages: [LlmMessage(LlmRole.user, userText)],
      context: {'level': level.name},
    );
  }

  /// Build a writing evaluation request (for mock exam writing section).
  LlmRequest buildWritingEvaluationRequest({
    required CEFRLevel level,
    required String taskDescription,
    required String learnerText,
  }) {
    return LlmRequest(
      operation: LlmOperation.writingEvaluation,
      model: _selectModel(level),
      messages: [LlmMessage(LlmRole.user, learnerText)],
      context: {'level': level.name, 'task_description': taskDescription},
    );
  }

  String _selectModel(CEFRLevel level) {
    // 'deepseek-chat' is the official API model ID for DeepSeek-V3 —
    // the cheapest model that handles Czech well.
    return 'deepseek-chat';
  }
}

/// Result of parsing a tutor response — either OK or an error.
sealed class TutorParseResult {
  const TutorParseResult();
}

/// Successful parse.
class TutorParseOk extends TutorParseResult {
  final TutorResponse response;
  const TutorParseOk(this.response);
}

/// Failed parse with a human-readable reason.
class TutorParseError extends TutorParseResult {
  final String reason;

  /// Length of the raw LLM content, for telemetry. Null when the content
  /// was empty or not string-typed.
  final int? rawLength;

  const TutorParseError({required this.reason, this.rawLength});
}
