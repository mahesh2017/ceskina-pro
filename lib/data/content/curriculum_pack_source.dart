import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../sync/backend_service.dart';

// A public named parameter initializes an intentionally private dependency.
// ignore_for_file: prefer_initializing_formals

/// Loads a complete curriculum snapshot from either bundled assets or
/// Supabase. A snapshot is exposed only after every required pack is present.
class CurriculumPackSource {
  CurriculumPackSource({
    required BackendService backend,
    AssetBundle? bundle,
    Logger? log,
  }) : _backend = backend,
       _bundle = bundle ?? rootBundle,
       _log = log ?? Logger('CurriculumPackSource');

  final BackendService _backend;
  final AssetBundle _bundle;
  final Logger _log;
  Map<String, Object?> _packs = const {};

  /// Load and validate the packaged bootstrap snapshot.
  Future<void> loadBundled(Set<String> requiredPackKeys) async {
    final bundled = <String, Object?>{};
    for (final key in requiredPackKeys) {
      bundled[key] = jsonDecode(await _bundle.loadString(key));
    }
    _packs = bundled;
    _log.info('Loaded ${bundled.length} bundled curriculum packs.');
  }

  /// Fetch and validate a complete live curriculum snapshot.
  Future<void> refreshRemote(Set<String> requiredPackKeys) async {
    final client = _backend.client;
    if (client == null) {
      throw StateError(
        'Supabase is not configured; curriculum cannot be loaded.',
      );
    }

    final rows = await client
        .from('curriculum_packs')
        .select('pack_key,content')
        .eq('is_published', true)
        .timeout(const Duration(seconds: 10));
    final remote = <String, Object?>{
      for (final row in rows) row['pack_key'] as String: row['content'],
    };
    final missing = requiredPackKeys.difference(remote.keys.toSet());
    if (missing.isNotEmpty) {
      throw StateError(
        'Published curriculum snapshot is incomplete '
        '(${missing.length} packs missing).',
      );
    }

    _packs = remote;
    _log.info('Loaded ${remote.length} curriculum packs from Supabase.');
  }

  Future<String> load(String path) async {
    final pack = _packs[path];
    if (pack != null) return jsonEncode(pack);
    throw StateError('Curriculum pack is not present in the snapshot: $path');
  }
}
