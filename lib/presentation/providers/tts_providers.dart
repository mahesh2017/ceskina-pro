import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

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
  String? _cacheDir;

  CzechTts(this._tts, this._player);

  /// Get the cache directory for TTS audio files.
  Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final dir = await getTemporaryDirectory();
    final ttsDir = '${dir.path}/tts_cache';
    await Directory(ttsDir).create(recursive: true);
    _cacheDir = ttsDir;
    return ttsDir;
  }

  /// Generate a cache key from the text.
  String _cacheKey(String text) {
    final bytes = utf8.encode(text.trim().toLowerCase());
    final hash = md5.convert(bytes);
    return hash.toString();
  }

  /// Get the cached file path for a given text.
  Future<String> _cachedFilePath(String text) async {
    final dir = await _getCacheDir();
    return '$dir/${_cacheKey(text)}.mp3';
  }

  /// Speak the given Czech text. Uses cache when available.
  /// Stops any currently playing speech.
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await stop();

    try {
      final filePath = await _cachedFilePath(trimmed);
      final cachedFile = File(filePath);

      if (await cachedFile.exists()) {
        // Play cached file
        await _player.setFilePath(filePath);
        await _player.play();
        return;
      }

      // Try to synthesize to file and cache
      final synthesized = await _tts.synthesizeToFile(trimmed, filePath);
      if (synthesized == 1) {
        // Synthesis succeeded — play the file
        await _player.setFilePath(filePath);
        await _player.play();
      } else {
        // Fallback: direct speak (no caching)
        await _tts.speak(trimmed);
      }
    } catch (_) {
      // Fallback: direct speak
      await _tts.speak(trimmed);
    }
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
        lang.toString().toLowerCase().startsWith('cs'));
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
  return CzechTts(tts, player);
});