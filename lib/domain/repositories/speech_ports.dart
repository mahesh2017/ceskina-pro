import '../../data/services/stt/whisper_service.dart' show WhisperResult;

/// Cloud (server-side) transcription capability.
///
/// [isAvailable] reflects authenticated backend capability — an actual
/// usable session — not merely the presence of a client object. Callers must
/// still treat [transcribe] as fallible: a linked backend without the
/// `whisper-proxy` function deployed will throw, and the caller degrades to a
/// live on-device transcriber rather than hard-failing.
abstract class CloudTranscriber {
  bool get isAvailable;

  Future<WhisperResult> transcribe({
    required String audioPath,
    String language,
    String? prompt,
  });
}

/// Records audio to a file for cloud transcription.
abstract class AudioRecorderPort {
  bool get isRecording;
  Future<String> start();
  Future<String> stop();
  Future<void> cleanup();
}

/// On-device live transcriber used as the degraded fallback.
abstract class LiveTranscriber {
  Future<String> listenFor({Duration timeout});
  Future<void> stop();
}
