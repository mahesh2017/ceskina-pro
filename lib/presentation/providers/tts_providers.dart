import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'settings_providers.dart';

/// TTS provider — manages a singleton FlutterTts instance configured for Czech.
/// The speech rate follows the user's setting.
final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  // Configure for Czech language
  tts.setLanguage('cs-CZ');
  tts.setPitch(1.0);
  tts.setVolume(1.0);
  // Upgrade from the default (often "compact") voice to the best-quality Czech
  // voice the device has — a large audible improvement at no cost. Fire and
  // forget; if it fails the default cs-CZ voice still works.
  _selectBestCzechVoice(tts);
  ref.onDispose(() => tts.stop());

  // Apply the user's speech rate now and whenever the setting changes.
  ref.listen<double>(
    settingsProvider.select((s) => s.ttsSpeechRate),
    (_, rate) => tts.setSpeechRate(rate),
    fireImmediately: true,
  );
  return tts;
});

/// Pick the highest-quality Czech voice available and set it on [tts].
/// Prefers voices flagged enhanced/premium/neural; otherwise the first Czech
/// voice. Best-effort — any failure leaves the default voice in place.
Future<void> _selectBestCzechVoice(FlutterTts tts) async {
  try {
    final raw = await tts.getVoices;
    if (raw is! List) return;
    final czech = raw
        .whereType<Map>()
        .where((v) =>
            (v['locale'] ?? '').toString().toLowerCase().startsWith('cs'))
        .toList();
    if (czech.isEmpty) return;

    final qualityRe = RegExp('enhanced|premium|neural', caseSensitive: false);
    final best = czech.firstWhere(
      (v) => qualityRe.hasMatch(
          '${v['name'] ?? ''} ${v['identifier'] ?? ''} ${v['quality'] ?? ''}'),
      orElse: () => czech.first,
    );

    final name = best['name']?.toString();
    final locale = best['locale']?.toString();
    if (name != null && locale != null) {
      await tts.setVoice({'name': name, 'locale': locale});
    }
  } catch (_) {
    // Keep the default cs-CZ voice.
  }
}

/// Audio player for playing cached TTS files.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Helper class for speaking Czech text with file-based caching.
///
/// Pipeline:
/// 1. Hash the text → cache filename
/// 2. If cached file exists → play with just_audio (fast, no network)
/// 3. If not cached → synthesize to file via flutter_tts, cache, play
/// 4. Fallback: direct speak() if file synthesis unavailable
class CzechTts {
  final FlutterTts _tts;
  final AudioPlayer _player;

  /// Current speech rate — part of the cache key, so audio synthesized at
  /// one rate is never replayed when the user changes the setting.
  final double Function() _speechRate;

  String? _cacheDir;

  CzechTts(this._tts, this._player, this._speechRate);

  /// Get the cache directory for TTS audio files.
  Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final dir = await getTemporaryDirectory();
    final ttsDir = '${dir.path}/tts_cache';
    await Directory(ttsDir).create(recursive: true);
    _cacheDir = ttsDir;
    return ttsDir;
  }

  /// Generate a cache key from the text and effective speech rate.
  String _cacheKey(String text, double rate) {
    final bytes = utf8.encode(
        '${rate.toStringAsFixed(2)}|${text.trim().toLowerCase()}',);
    final hash = md5.convert(bytes);
    return hash.toString();
  }

  /// Get the cached file path for a given text and rate.
  Future<String> _cachedFilePath(String text, double rate) async {
    final dir = await _getCacheDir();
    return '$dir/${_cacheKey(text, rate)}.mp3';
  }

  /// Speak the given Czech text. Uses cache when available.
  /// Stops any currently playing speech. [rate] overrides the user's
  /// configured speech rate for this utterance only (e.g. slow replay).
  Future<void> speak(String text, {double? rate}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await stop();

    final effectiveRate = rate ?? _speechRate();

    // macOS: flutter_tts's synthesizeToFile resolves paths relative to the
    // sandbox Documents dir and can't write mp3 (AVFoundation 'fmt?' error),
    // which spams retries and never produces a playable cache file. Speak
    // directly — native TTS is offline and instant, so the cache adds
    // nothing on this platform anyway.
    if (Platform.isMacOS) {
      if (rate != null) await _tts.setSpeechRate(rate);
      try {
        await _tts.speak(trimmed);
      } finally {
        if (rate != null) await _tts.setSpeechRate(_speechRate());
      }
      return;
    }

    try {
      final filePath = await _cachedFilePath(trimmed, effectiveRate);
      final cachedFile = File(filePath);

      if (await cachedFile.exists()) {
        // Play cached file
        await _player.setFilePath(filePath);
        await _player.play();
        return;
      }

      // Try to synthesize to file and cache. Rate overrides temporarily
      // change the engine rate for synthesis, then restore the setting.
      if (rate != null) await _tts.setSpeechRate(rate);
      try {
        final synthesized = await _tts.synthesizeToFile(trimmed, filePath);
        if (synthesized == 1) {
          // Synthesis succeeded — play the file
          await _player.setFilePath(filePath);
          await _player.play();
        } else {
          // Fallback: direct speak (no caching). The rate override may not
          // be restored until this utterance finishes queuing — acceptable.
          await _tts.speak(trimmed);
        }
      } finally {
        if (rate != null) await _tts.setSpeechRate(_speechRate());
      }
    } catch (_) {
      // Fallback: direct speak
      await _tts.speak(trimmed);
    }
  }

  /// Speak at ~60% of the configured rate — the "turtle button" for
  /// dictation and listening practice.
  Future<void> speakSlow(String text) {
    final slow = (_speechRate() * 0.6).clamp(0.1, 1.0);
    return speak(text, rate: slow);
  }

  /// Stop any currently playing speech.
  Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }

  /// Check if Czech voice is available on the device.
  Future<bool> isCzechAvailable() async {
    final languages = await _tts.getLanguages;
    if (languages == null) return false;
    return languages.any((lang) =>
        lang.toString().toLowerCase().startsWith('cs'),);
  }

  /// Clear the TTS cache directory.
  Future<void> clearCache() async {
    final dir = await _getCacheDir();
    final dirObj = Directory(dir);
    if (await dirObj.exists()) {
      await dirObj.delete(recursive: true);
      await dirObj.create(recursive: true);
    }
  }

  /// Get the current cache size in bytes.
  Future<int> cacheSize() async {
    final dir = await _getCacheDir();
    final dirObj = Directory(dir);
    if (!await dirObj.exists()) return 0;

    int total = 0;
    await for (final entity in dirObj.list()) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}

/// Provider for the CzechTts helper.
final czechTtsProvider = Provider<CzechTts>((ref) {
  final tts = ref.read(ttsProvider);
  final player = ref.read(audioPlayerProvider);
  return CzechTts(
    tts,
    player,
    () => ref.read(settingsProvider).ttsSpeechRate,
  );
});