import 'dart:convert';

import 'package:logging/logging.dart';

import '../sync/backend_service.dart';

// A public named parameter initializes an intentionally private dependency.
// ignore_for_file: prefer_initializing_formals

/// Loads the complete published curriculum snapshot from Supabase.
///
/// Curriculum is deliberately not bundled with the application. A failed or
/// incomplete remote fetch is an initialization error rather than a signal to
/// silently use stale packaged content.
class CurriculumPackSource {
  CurriculumPackSource({required BackendService backend, Logger? log})
    : _backend = backend,
      _log = log ?? Logger('CurriculumPackSource');

  final BackendService _backend;
  final Logger _log;
  Map<String, Object?> _packs = const {};

  /// Fetch and validate a complete live curriculum snapshot.
  Future<void> refresh(Set<String> requiredPackKeys) async {
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
    final remote = _packs[path];
    if (remote != null) return jsonEncode(remote);
    throw StateError('Curriculum pack was not returned by Supabase: $path');
  }
}
