import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TTS provider — manages a singleton FlutterTts instance configured for Czech.
final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  // Configure for Czech language
  tts.setLanguage('cs-CZ');
  tts.setSpeechRate(0.45); // slightly slower for language learners
  tts.setPitch(1.0);
  tts.setVolume(1.0);
  ref.onDispose(() => tts.stop());
  return tts;
});

/// Helper class for speaking Czech text.
class CzechTts {
  final FlutterTts _tts;

  CzechTts(this._tts);

  /// Speak the given Czech text. Stops any currently playing speech.
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stop any currently playing speech.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Check if Czech voice is available on the device.
  Future<bool> isCzechAvailable() async {
    final languages = await _tts.getLanguages;
    if (languages == null) return false;
    return languages.any((lang) =>
        lang.toString().toLowerCase().startsWith('cs'));
  }
}

/// Provider for the CzechTts helper.
final czechTtsProvider = Provider<CzechTts>((ref) {
  final tts = ref.read(ttsProvider);
  return CzechTts(tts);
});