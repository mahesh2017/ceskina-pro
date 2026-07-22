import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pronunciation_result.dart';
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
  final bool usedWhisper;

  const PronunciationState({
    required this.expectedText,
    this.transcribedText,
    this.result,
    this.isRecording = false,
    this.isProcessing = false,
    this.error,
    this.usedWhisper = false,
  });

  PronunciationState copyWith({
    String? expectedText,
    String? transcribedText,
    PronunciationResult? result,
    bool? isRecording,
    bool? isProcessing,
    String? error,
    bool? usedWhisper,
  }) {
    return PronunciationState(
      expectedText: expectedText ?? this.expectedText,
      transcribedText: transcribedText ?? this.transcribedText,
      result: result ?? this.result,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      usedWhisper: usedWhisper ?? this.usedWhisper,
    );
  }
}

/// Notifier that manages the pronunciation practice flow.
///
/// Uses the [PronunciationAssessor] which tries Whisper first (high-quality
/// transcription with word-level confidence) and falls back to OS-native
/// STT when the backend is unavailable.
class PronunciationNotifier extends Notifier<PronunciationState> {
  @override
  PronunciationState build() => const PronunciationState(expectedText: '');

  /// Set the expected text to practice.
  void setExpectedText(String text) {
    state = PronunciationState(expectedText: text);
  }

  /// Start recording and assess pronunciation.
  Future<void> startRecording() async {
    if (state.isRecording || state.isProcessing) return;

    state = state.copyWith(isRecording: true, error: null, result: null);

    try {
      final assessor = ref.read(pronunciationAssessmentProvider);
      final assessment = await assessor.assess(
        expectedText: state.expectedText,
      );

      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        transcribedText: assessment.transcribedText,
        result: assessment.result,
        usedWhisper: assessment.usedWhisper,
      );

      // Award XP for pronunciation practice
      final gamification = ref.read(gamificationProvider.notifier);
      gamification.onPronunciationDrill(accuracy: assessment.result.overallScore);
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
    final assessor = ref.read(pronunciationAssessmentProvider);
    await assessor.stop();
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