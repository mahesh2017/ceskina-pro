/// Pure voice-activity state machine for auto-stopping a recording.
///
/// Fed a stream of amplitude samples (dBFS; ~0 is loud, ~-160 is silent) with
/// the elapsed time of each sample, it decides when to stop: once speech has
/// been detected, it stops after [silenceTimeout] of continuous quiet. Before
/// any speech it never stops (so a slow starter isn't cut off), and the caller
/// still enforces a hard maximum duration independently.
///
/// No timers or I/O — deterministic and unit-testable.
class SilenceDetector {
  SilenceDetector({
    this.speechThresholdDb = -40,
    this.silenceTimeout = const Duration(seconds: 3),
  });

  /// A sample at or above this dBFS level counts as speech.
  final double speechThresholdDb;

  /// How long the level must stay below [speechThresholdDb] (after speech has
  /// started) before recording should stop.
  final Duration silenceTimeout;

  bool _speechStarted = false;
  Duration? _silenceStart;

  /// Whether any speech has been observed yet.
  bool get speechStarted => _speechStarted;

  /// Feed one amplitude sample. [currentDb] is the sample's dBFS level and
  /// [elapsed] is the time since recording began. Returns true when recording
  /// should stop.
  bool accept(double currentDb, Duration elapsed) {
    final isSpeech = currentDb >= speechThresholdDb;
    if (isSpeech) {
      _speechStarted = true;
      _silenceStart = null;
      return false;
    }
    if (!_speechStarted) return false; // still waiting for the user to begin
    _silenceStart ??= elapsed;
    return elapsed - _silenceStart! >= silenceTimeout;
  }
}
