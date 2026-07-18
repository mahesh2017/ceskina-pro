import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pronunciation_result.dart';
import '../../domain/engines/pronunciation_scorer.dart';
import 'stt_providers.dart';
import 'gamification_providers.dart';

/// State of a pronunciation practice session.
class PronunciationState {
  final String expectedText;
  final String? transcribedText;
  final PronunciationResult? result;
  final bool isRecording;
  final bool isProcessing;
  final String? error;

  const PronunciationState({
    required this.expectedText,
    this.transcribedText,
    this.result,
    this.isRecording = false,
    this.isProcessing = false,
    this.error,
  });

  PronunciationState copyWith({
    String? expectedText,
    String? transcribedText,
    PronunciationResult? result,
    bool? isRecording,
    bool? isProcessing,
    String? error,
  }) {
    return PronunciationState(
      expectedText: expectedText ?? this.expectedText,
      transcribedText: transcribedText ?? this.transcribedText,
      result: result ?? this.result,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}

/// Notifier that manages the pronunciation practice flow.
class PronunciationNotifier extends Notifier<PronunciationState> {
  final _scorer = PronunciationScorer();

  @override
  PronunciationState build() => const PronunciationState(
        expectedText: '',
      );

  /// Set the expected text to practice.
  void setExpectedText(String text) {
    state = PronunciationState(expectedText: text);
  }

  /// Start recording and recognize speech.
  Future<void> startRecording() async {
    if (state.isRecording || state.isProcessing) return;

    state = state.copyWith(isRecording: true, error: null, result: null);

    try {
      final stt = ref.read(sttServiceProvider) as NativeSttService;
      final transcription = await stt.listenFor(
        timeout: const Duration(seconds: 10),
      );

      state = state.copyWith(
        isRecording: false,
        isProcessing: true,
        transcribedText: transcription,
      );

      // Score the transcription
      final result = _scorer.score(
        expectedText: state.expectedText,
        actualTranscription: transcription,
      );

      state = state.copyWith(
        isProcessing: false,
        result: result,
      );

      // Award XP for pronunciation practice
      final gamification = ref.read(gamificationProvider.notifier);
      gamification.onPronunciationDrill(accuracy: result.overallScore);
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        error: 'Speech recognition failed: $e',
      );
    }
  }

  /// Stop recording (if in progress).
  Future<void> stopRecording() async {
    final stt = ref.read(sttServiceProvider) as NativeSttService;
    await stt.stop();
    state = state.copyWith(isRecording: false);
  }

  /// Reset for a new attempt.
  void reset() {
    state = PronunciationState(expectedText: state.expectedText);
  }
}

/// Provider for the pronunciation state.
final pronunciationProvider =
    NotifierProvider<PronunciationNotifier, PronunciationState>(
        PronunciationNotifier.new,);