import 'package:logging/logging.dart';

/// Emits support-useful diagnostics without serializing learner input, audio,
/// prompts, account identifiers, exception messages, or arbitrary state.
class SafeDiagnostics {
  SafeDiagnostics._();

  static final Logger _logger = Logger('SafeDiagnostics');
  static final RegExp _safeIdentifier = RegExp(r'^[A-Za-z0-9._:-]{1,80}$');

  static void error(
    String event,
    Object error,
    StackTrace stack, {
    Object? contentId,
    String? releaseId,
    String? fromState,
    String? toState,
  }) {
    final fields = <String, String>{
      'event': _identifier(event) ?? 'unknown_error',
      'error_type': error.runtimeType.toString(),
      if (_identifier(contentId?.toString()) case final value?)
        'content_id': value,
      if (_identifier(releaseId) case final value?) 'release_id': value,
      if (_identifier(fromState) case final value?) 'from': value,
      if (_identifier(toState) case final value?) 'to': value,
    };
    _logger.severe(
      fields.entries.map((entry) => '${entry.key}=${entry.value}').join(' '),
      null,
      stack,
    );
  }

  static String? _identifier(String? value) {
    if (value == null || !_safeIdentifier.hasMatch(value)) return null;
    return value;
  }
}
