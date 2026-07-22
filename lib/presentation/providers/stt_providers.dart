import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../data/services/stt/audio_recorder.dart';
import '../../data/services/stt/whisper_service.dart';
import 'sync_providers.dart';
import '../../domain/entities/pronunciation_result.dart';
import '../../domain/engines/pronunciation_scorer.dart';
import '../../domain/repositories/stt_service.dart';

/// Provider for the audio recorder.
final audioRecorderProvider = Provider<AudioRecorderService>((ref) {
  final service = AudioRecorderService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the Whisper service. Only available when backend is
/// configured and initialized.
final whisperServiceProvider = Provider<WhisperService?>((ref) {
  final backend = ref.watch(backendServiceProvider);
  return WhisperService(
    client: backend.client,
    log: Logger('WhisperService'),
  );
});

/// Abstract pronunciation assessment provider — tries Whisper first,
/// falls back to OS-native STT when the backend is unavailable.
///
/// This is the primary entry point for pronunciation exercises. It returns
/// a [PronunciationAssessment] which includes the transcription, overall
/// score, per-word scores, and word-level confidence (when available from
/// Whisper).
final pronunciationAssessmentProvider =
    Provider<PronunciationAssessor>((ref) {
  return PronunciationAssessor(
    recorder: ref.watch(audioRecorderProvider),
    whisper: ref.watch(whisperServiceProvider),
    fallbackStt: NativeSttService(),
    log: Logger('PronunciationAssessor'),
  );
});

/// Result of a pronunciation assessment.
class PronunciationAssessment {
  final String transcribedText;
  final PronunciationResult result;
  final List<WhisperWord> whisperWords;

  /// True when this assessment used Whisper (vs OS-native STT fallback).
  final bool usedWhisper;

  const PronunciationAssessment({
    required this.transcribedText,
    required this.result,
    this.whisperWords = const [],
    this.usedWhisper = false,
  });
}

// A public named parameter initializes an intentionally private dependency.
// ignore_for_file: prefer_initializing_formals
/// Assesses pronunciation by recording audio and transcribing it.
///
/// When Whisper is available (backend configured), records audio to a WAV
/// file and sends it to the Whisper Edge Function, which returns word-level
/// timestamps and confidence scores. When Whisper is unavailable, falls back
/// to the OS-native `speech_to_text` package for live recognition.
class PronunciationAssessor {
  PronunciationAssessor({
    required AudioRecorderService recorder,
    required WhisperService? whisper,
    required NativeSttService fallbackStt,
    required Logger log,
  })  : _recorder = recorder,
        _whisper = whisper,
        _fallbackStt = fallbackStt,
        _log = log;

  final AudioRecorderService _recorder;
  final WhisperService? _whisper;
  final NativeSttService _fallbackStt;
  final Logger _log;
  final _scorer = PronunciationScorer();

  /// Whether Whisper is available for high-quality transcription.
  bool get hasWhisper => _whisper?.isAvailable ?? false;

  /// Record audio for [maxDuration] and assess pronunciation against
  /// [expectedText].
  ///
  /// When Whisper is available, records to a WAV file and sends it to the
  /// Whisper API for transcription with word-level confidence. When not,
  /// uses OS-native STT for live recognition (lower quality, no confidence).
  Future<PronunciationAssessment> assess({
    required String expectedText,
    Duration maxDuration = const Duration(seconds: 10),
  }) async {
    if (hasWhisper) {
      return _assessWithWhisper(expectedText, maxDuration);
    }
    return _assessWithNativeStt(expectedText, maxDuration);
  }

  Future<PronunciationAssessment> _assessWithWhisper(
    String expectedText,
    Duration maxDuration,
  ) async {
    // Record audio
    await _recorder.start();

    // Wait for the user to speak (fixed duration or manual stop)
    await Future.delayed(maxDuration);

    if (_recorder.isRecording) {
      final audioPath = await _recorder.stop();

      // Transcribe with Whisper, passing the expected text as a prompt
      // to improve accuracy for known phrases.
      final whisperResult = await _whisper!.transcribe(
        audioPath: audioPath,
        language: 'cs',
        prompt: expectedText,
      );

      // Score using the existing scorer + Whisper word confidence
      final result = _scorer.score(
        expectedText: expectedText,
        actualTranscription: whisperResult.text,
      );

      // Enrich word scores with Whisper confidence
      final enriched = _enrichWithConfidence(result, whisperResult.words);

      _log.info(
        'Whisper assessment: ${result.overallScore.toStringAsFixed(2)} '
        '(${whisperResult.words.length} words, '
        '${whisperResult.duration.toStringAsFixed(1)}s audio)',
      );

      // Cleanup audio file
      await _recorder.cleanup();

      return PronunciationAssessment(
        transcribedText: whisperResult.text,
        result: enriched,
        whisperWords: whisperResult.words,
        usedWhisper: true,
      );
    }

    // User stopped early or recording failed
    return PronunciationAssessment(
      transcribedText: '',
      result: _scorer.score(
        expectedText: expectedText,
        actualTranscription: '',
      ),
      usedWhisper: true,
    );
  }

  Future<PronunciationAssessment> _assessWithNativeStt(
    String expectedText,
    Duration maxDuration,
  ) async {
    _log.info('Whisper unavailable; falling back to OS-native STT.');

    final transcription = await _fallbackStt.listenFor(timeout: maxDuration);

    final result = _scorer.score(
      expectedText: expectedText,
      actualTranscription: transcription,
    );

    return PronunciationAssessment(
      transcribedText: transcription,
      result: result,
      usedWhisper: false,
    );
  }

  /// Enrich word scores with Whisper's per-word probability.
  PronunciationResult _enrichWithConfidence(
    PronunciationResult base,
    List<WhisperWord> whisperWords,
  ) {
    if (whisperWords.isEmpty || base.wordScores.isEmpty) {
      return base;
    }

    // Build a map of normalized word → average probability from Whisper
    final wordConfidence = <String, double>{};
    for (final w in whisperWords) {
      final normalized = w.word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      if (normalized.isNotEmpty) {
        wordConfidence[normalized] =
            (wordConfidence[normalized] ?? 0) + w.probability;
      }
    }

    // The existing scorer already computed word scores from text comparison.
    // Whisper's probability gives us an additional signal: even if the text
    // matches, a low Whisper probability means the model wasn't sure about
    // the pronunciation quality.
    //
    // We blend: finalScore = 0.6 * textSimilarity + 0.4 * whisperConfidence
    // When Whisper confidence is unavailable for a word, we use textSimilarity
    // alone (no penalty).
    final enrichedWordScores = base.wordScores.map((ws) {
      final normalized = ws.word.toLowerCase();
      final whisperProb = wordConfidence[normalized];
      if (whisperProb == null) {
        return ws; // No Whisper data for this word — keep text-based score
      }
      final blended = (ws.score * 0.6) + (whisperProb * 0.4);
      return WordScore(
        word: ws.word,
        isCorrect: blended >= 0.7,
        score: blended,
      );
    }).toList();

    // Recalculate overall score
    final totalScore =
        enrichedWordScores.fold<double>(0.0, (sum, w) => sum + w.score);
    final accuracy = enrichedWordScores.isEmpty
        ? 0.0
        : totalScore / enrichedWordScores.length;

    return PronunciationResult(
      overallScore: accuracy,
      wordScores: enrichedWordScores,
      problemSounds: base.problemSounds,
      feedback: base.feedback,
    );
  }

  /// Stop any active recording.
  Future<void> stop() async {
    if (_recorder.isRecording) {
      await _recorder.stop();
    }
    await _fallbackStt.stop();
  }
}

/// STT provider using the speech_to_text package (on-device, OS-native).
///
/// Used as a fallback when Whisper is unavailable (offline, backend not
/// configured). For Czech, this uses the OS's built-in speech recognition
/// (Google on Android, Apple on iOS/macOS).
final sttServiceProvider = Provider<SttService>((ref) {
  return NativeSttService();
});

/// Native on-device STT implementation using speech_to_text package.
class NativeSttService implements SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  String? _czechLocaleId;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = await _speech.initialize(
      onError: (error) {
        // Log error but don't crash
      },
      onStatus: (status) {
        // Listening state changes
      },
    );
    if (_initialized) {
      // Resolve the device's Czech locale id once. The exact id varies by
      // platform (cs_CZ, cs-CZ, cs); pick whatever the OS actually offers so
      // listen() doesn't silently no-op on an unknown locale.
      try {
        final locales = await _speech.locales();
        final cs = locales
            .where((l) => l.localeId.toLowerCase().startsWith('cs'))
            .toList();
        _czechLocaleId = cs.isNotEmpty ? cs.first.localeId : null;
      } catch (_) {
        _czechLocaleId = null;
      }
    }
  }

  @override
  Future<String> transcribe(String audioPath) async {
    await _ensureInitialized();
    if (!_initialized) return '';

    // speech_to_text works via live listening, not file transcription.
    // For file-based transcription, Vosk would be needed.
    // For now, this returns empty — the pronunciation provider
    // uses listenFor() which captures live speech.
    return '';
  }

  @override
  Stream<PartialTranscript> transcribeStream(String audioPath) async* {
    // Not used for live recognition — see listenFor() in the provider
    yield const PartialTranscript(text: '', isFinal: true);
  }

  @override
  Future<bool> isAvailable() async {
    await _ensureInitialized();
    return _initialized;
  }

  /// Start live listening and return the recognized text.
  /// This is the primary method used for pronunciation practice.
  Future<String> listenFor({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await _ensureInitialized();
    if (!_initialized) return '';

    final completer = Completer<String>();
    String result = '';

    await _speech.listen(
      onResult: (recognition) {
        // Keep the latest transcription — partial OR final. Czech recognition
        // (and short utterances) often never emit a final result, so relying
        // only on finalResult loses everything the user said.
        if (recognition.recognizedWords.isNotEmpty) {
          result = recognition.recognizedWords;
        }
        if (recognition.finalResult && !completer.isCompleted) {
          completer.complete(result);
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: timeout,
        // Use the resolved Czech locale when available; otherwise fall back to
        // the device default rather than a possibly-unknown 'cs_CZ'.
        localeId: _czechLocaleId,
        listenMode: ListenMode.dictation,
      ),
    );

    return completer.future.timeout(timeout, onTimeout: () {
      _speech.stop();
      return result;
    });
  }

  /// Stop listening.
  Future<void> stop() async {
    await _speech.stop();
  }
}