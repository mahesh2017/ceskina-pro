import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/llm_service.dart';
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
      grammar: (score['grammar'] as num?)?.toInt() ?? 0,
      vocabulary: (score['vocabulary'] as num?)?.toInt() ?? 0,
      coherence: (score['coherence'] as num?)?.toInt() ?? 0,
      overall: (score['overall'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? '',
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
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
  Future<WritingEvaluation> evaluate({
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
    } catch (e) {
      // Fallback: basic word-count based scoring
      final wordCount = learnerText.split(' ').where((w) => w.isNotEmpty).length;
      final baseScore = wordCount >= 30 ? 60 : 30;

      final evaluation = WritingEvaluation(
        grammar: baseScore,
        vocabulary: baseScore,
        coherence: baseScore + 5,
        overall: baseScore + 2,
        feedback: 'Could not reach AI for detailed feedback. '
            'Your text has $wordCount words.',
        errors: [],
      );

      state = WritingEvalState(evaluation: evaluation);
      return evaluation;
    }
  }

  void reset() {
    state = const WritingEvalState();
  }
}

/// Provider for writing evaluation.
final writingEvalProvider =
    NotifierProvider<WritingEvalNotifier, WritingEvalState>(
        WritingEvalNotifier.new);