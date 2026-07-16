import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/repositories/stt_service.dart';

/// STT provider using the speech_to_text package (on-device, OS-native).
///
/// For Czech, this uses the OS's built-in speech recognition (Google on
/// Android, Apple on iOS/macOS). This is the Phase 1 approach —
/// Vosk offline model integration is planned for Phase 2 enhancement.
final sttServiceProvider = Provider<SttService>((ref) {
  return NativeSttService();
});

/// Native on-device STT implementation using speech_to_text package.
class NativeSttService implements SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

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
  Future<String> listenFor({Duration timeout = const Duration(seconds: 10)}) async {
    await _ensureInitialized();
    if (!_initialized) return '';

    final completer = Completer<String>();
    String result = '';

    await _speech.listen(
      onResult: (recognition) {
        if (recognition.finalResult) {
          result = recognition.recognizedWords;
          if (!completer.isCompleted) completer.complete(result);
        }
      },
      listenFor: timeout,
      localeId: 'cs_CZ',
      listenMode: ListenMode.dictation,
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