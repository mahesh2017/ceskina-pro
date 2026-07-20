import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/llm_service_exception.dart';
import '../../domain/entities/enums.dart';
import 'llm_providers.dart';

/// Result of an AI writing evaluation.
class WritingEvaluation {
  final int grammar;
  final int vocabulary;
  final int coherence;
  final int overall;
  final String feedback;
  final List<Map<String, dynamic>> errors;

  const WritingEvaluation({
    required this.grammar,
    required this.vocabulary,
    required this.coherence,
    required this.overall,
    required this.feedback,
    required this.errors,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as Map<String, dynamic>? ?? {};
    return WritingEvaluation(
      grammar: _boundedScore(score['grammar']),
      vocabulary: _boundedScore(score['vocabulary']),
      coherence: _boundedScore(score['coherence']),
      overall: _boundedScore(score['overall']),
      feedback: json['feedback'] as String? ?? '',
      errors:
          (json['errors'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [],
    );
  }

  static int _boundedScore(Object? value) {
    final numeric = value is num && value.isFinite ? value : 0;
    return numeric.clamp(0, 100).round();
  }
}

/// State for writing evaluation.
class WritingEvalState {
  final bool isEvaluating;
  final WritingEvaluation? evaluation;
  final String? error;

  const WritingEvalState({
    this.isEvaluating = false,
    this.evaluation,
    this.error,
  });

  WritingEvalState copyWith({
    bool? isEvaluating,
    WritingEvaluation? evaluation,
    String? error,
  }) {
    return WritingEvalState(
      isEvaluating: isEvaluating ?? this.isEvaluating,
      evaluation: evaluation ?? this.evaluation,
      error: error,
    );
  }
}

/// Notifier for writing evaluation.
class WritingEvalNotifier extends Notifier<WritingEvalState> {
  @override
  WritingEvalState build() => const WritingEvalState();

  /// Evaluate a learner's writing using the LLM.
  ///
  /// Returns null on failure — the error is surfaced via [WritingEvalState]
  /// so the UI shows what happened instead of a fabricated score.
  Future<WritingEvaluation?> evaluate({
    required CEFRLevel level,
    required String taskDescription,
    required String learnerText,
  }) async {
    state = const WritingEvalState(isEvaluating: true);

    try {
      final orchestrator = ref.read(llmOrchestratorProvider);
      final request = orchestrator.buildWritingEvaluationRequest(
        level: level,
        taskDescription: taskDescription,
        learnerText: learnerText,
      );

      final llm = ref.read(llmServiceProvider);
      final response = await llm.complete(request);

      final json = jsonDecode(response.content) as Map<String, dynamic>;
      final evaluation = WritingEvaluation.fromJson(json);

      state = WritingEvalState(evaluation: evaluation);
      return evaluation;
    } on LlmServiceException catch (e) {
      state = WritingEvalState(error: e.message);
      return null;
    } on FormatException {
      state = const WritingEvalState(
        error: 'The AI returned an unreadable evaluation. Try again.',
      );
      return null;
    } catch (_) {
      state = const WritingEvalState(
        error:
            'Could not evaluate your writing. '
            'Check your connection and try again.',
      );
      return null;
    }
  }

  void reset() {
    state = const WritingEvalState();
  }
}

/// Provider for writing evaluation.
final writingEvalProvider =
    NotifierProvider<WritingEvalNotifier, WritingEvalState>(
      WritingEvalNotifier.new,
    );
