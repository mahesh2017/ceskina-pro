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

  /// Record until the speaker falls silent (voice-activity auto-stop), the
  /// [maxDuration] cap is reached, or [stopSignal] fires (manual stop) —
  /// whichever comes first — then stop and return the recorded file path.
  /// The captured audio is always returned so the caller can transcribe it,
  /// regardless of which condition ended the recording.
  Future<String> recordUntilSilence({
    Duration silenceTimeout,
    Duration maxDuration,
    Future<void>? stopSignal,
  });
}

/// On-device live transcriber used as the degraded fallback.
abstract class LiveTranscriber {
  Future<String> listenFor({Duration timeout});
  Future<void> stop();
}
