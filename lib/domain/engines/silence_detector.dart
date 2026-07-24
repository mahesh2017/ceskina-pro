/// Pure, adaptive voice-activity state machine for auto-stopping a recording.
///
/// Absolute dBFS thresholds don't work across devices/rooms (one phone's quiet
/// room reads -55 dBFS, another's -30). So this tracks two running references
/// from the samples themselves:
///   * a noise **floor** (the quietest level seen), and
///   * a speech **peak** (the loudest level seen).
/// Speech starts when a sample rises [speechRiseDb] above the floor; after that,
/// the recording stops once the level stays [silenceDropDb] below the peak for
/// [silenceTimeout]. This adapts to whatever the mic actually reports.
///
/// No timers or I/O — deterministic and unit-testable. The caller still
/// enforces a hard maximum duration as a safety net.
class SilenceDetector {
  SilenceDetector({
    this.silenceTimeout = const Duration(seconds: 3),
    this.speechRiseDb = 12,
    this.silenceDropDb = 10,
  });

  /// How long the level must stay quiet (after speech) before stopping.
  final Duration silenceTimeout;

  /// A sample this many dB above the running floor marks the start of speech.
  final double speechRiseDb;

  /// After speech, a sample this many dB below the running peak counts as quiet.
  final double silenceDropDb;

  double? _floor;
  double? _peak;
  bool _speechStarted = false;
  Duration? _silenceStart;

  bool get speechStarted => _speechStarted;

  /// Feed one amplitude sample ([currentDb] dBFS) at [elapsed] since recording
  /// began. Returns true when recording should stop.
  bool accept(double currentDb, Duration elapsed) {
    _floor = (_floor == null || currentDb < _floor!) ? currentDb : _floor!;
    _peak = (_peak == null || currentDb > _peak!) ? currentDb : _peak!;

    if (!_speechStarted) {
      if (currentDb >= _floor! + speechRiseDb) {
        _speechStarted = true;
        _silenceStart = null;
      }
      return false; // never stop before the user has spoken
    }

    final isQuiet = currentDb <= _peak! - silenceDropDb;
    if (!isQuiet) {
      _silenceStart = null; // speaking again — reset the silence timer
      return false;
    }
    _silenceStart ??= elapsed;
    return elapsed - _silenceStart! >= silenceTimeout;
  }
}
