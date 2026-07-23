import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pronunciation_result.dart';
import 'stt_providers.dart';

/// State of a pronunciation practice session.
class PronunciationState {
  final String expectedText;
  final String? transcribedText;
  final PronunciationResult? result;
  final bool isRecording;
  final bool isProcessing;
  final String? error;
  final bool usedWhisper;
  final int attemptId;

  const PronunciationState({
    required this.expectedText,
    this.transcribedText,
    this.result,
    this.isRecording = false,
    this.isProcessing = false,
    this.error,
    this.usedWhisper = false,
    this.attemptId = 0,
  });

  PronunciationState copyWith({
    String? expectedText,
    String? transcribedText,
    PronunciationResult? result,
    bool? isRecording,
    bool? isProcessing,
    String? error,
    bool? usedWhisper,
    int? attemptId,
  }) {
    return PronunciationState(
      expectedText: expectedText ?? this.expectedText,
      transcribedText: transcribedText ?? this.transcribedText,
      result: result ?? this.result,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      usedWhisper: usedWhisper ?? this.usedWhisper,
      attemptId: attemptId ?? this.attemptId,
    );
  }
}

/// Notifier that manages the pronunciation practice flow.
///
/// Uses the [PronunciationAssessor] which tries Whisper first (high-quality
/// transcription with word-level confidence) and falls back to OS-native
/// STT when the backend is unavailable.
class PronunciationNotifier extends Notifier<PronunciationState> {
  var _attemptSequence = 0;

  @override
  PronunciationState build() => const PronunciationState(expectedText: '');

  /// Set the expected text to practice.
  void setExpectedText(String text) {
    if (text == state.expectedText &&
        !state.isRecording &&
        !state.isProcessing) {
      return;
    }
    _attemptSequence++;
    state = PronunciationState(expectedText: text, attemptId: _attemptSequence);
  }

  /// Start recording and assess pronunciation.
  Future<void> startRecording({required String expectedText}) async {
    if (state.isRecording || state.isProcessing) return;

    final attemptId = ++_attemptSequence;
    state = PronunciationState(
      expectedText: expectedText,
      isRecording: true,
      attemptId: attemptId,
    );

    try {
      final assessor = ref.read(pronunciationAssessmentProvider);
      final assessment = await assessor.assess(expectedText: expectedText);
      if (!ref.mounted || state.attemptId != attemptId) return;

      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        transcribedText: assessment.transcribedText,
        result: assessment.result,
        usedWhisper: assessment.usedWhisper,
      );
    } catch (e) {
      if (!ref.mounted || state.attemptId != attemptId) return;
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        error: 'Speech recognition failed: $e',
      );
    }
  }

  /// Stop recording (if in progress).
  Future<void> stopRecording() async {
    final expectedText = state.expectedText;
    final attemptId = ++_attemptSequence;
    state = PronunciationState(
      expectedText: expectedText,
      isProcessing: true,
      attemptId: attemptId,
    );
    final assessor = ref.read(pronunciationAssessmentProvider);
    try {
      await assessor.stop();
    } finally {
      if (ref.mounted && state.attemptId == attemptId) {
        state = PronunciationState(
          expectedText: expectedText,
          attemptId: attemptId,
        );
      }
    }
  }

  /// Reset for a new attempt.
  void reset() {
    _attemptSequence++;
    state = PronunciationState(
      expectedText: state.expectedText,
      attemptId: _attemptSequence,
    );
  }
}

/// Provider for the pronunciation state.
final pronunciationProvider =
    NotifierProvider<PronunciationNotifier, PronunciationState>(
      PronunciationNotifier.new,
    );
