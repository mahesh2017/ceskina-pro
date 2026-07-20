import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../sync/backend_service.dart';

// A public named parameter initializes an intentionally private dependency.
// ignore_for_file: prefer_initializing_formals

/// A content release manifest fetched from Supabase.
///
/// Ties together a set of curriculum packs into a versioned, checksummed
/// release. The client compares the manifest version to its local state to
/// determine whether a content update is available.
class ContentRelease {
  final String releaseId;
  final int version;
  final String contentChecksum;
  final List<PackRef> packRefs;
  final String? previousRelease;
  final String? notes;

  const ContentRelease({
    required this.releaseId,
    required this.version,
    required this.contentChecksum,
    required this.packRefs,
    this.previousRelease,
    this.notes,
  });

  factory ContentRelease.fromJson(Map<String, dynamic> json) {
    final refs = (json['pack_refs'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PackRef.fromJson)
        .toList();
    return ContentRelease(
      releaseId: json['release_id'] as String,
      version: json['version'] as int,
      contentChecksum: json['content_checksum'] as String,
      packRefs: refs,
      previousRelease: json['previous_release'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// A reference to a single pack within a release manifest.
class PackRef {
  final String packKey;
  final int version;
  final String checksum;

  const PackRef({
    required this.packKey,
    required this.version,
    required this.checksum,
  });

  factory PackRef.fromJson(Map<String, dynamic> json) {
    return PackRef(
      packKey: json['pack_key'] as String,
      version: json['version'] as int,
      checksum: json['checksum'] as String,
    );
  }
}

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

  /// The last release manifest fetched from Supabase, or null when only
  /// bundled content has been loaded.
  ContentRelease? _lastRelease;
  ContentRelease? get currentRelease => _lastRelease;

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

    // Check for a published content release manifest. If one exists and is
    // newer than the local version, the packs referenced in the manifest are
    // the authoritative set. Otherwise, fall back to all published packs.
    ContentRelease? release;
    try {
      final releaseRows = await client
          .from('content_releases')
          .select()
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(1)
          .timeout(const Duration(seconds: 10));
      if (releaseRows.isNotEmpty) {
        release = ContentRelease.fromJson(releaseRows.first);
        _log.info(
          'Found content release ${release.releaseId} v${release.version}'
          '${release.notes != null ? ': ${release.notes}' : ''}',
        );
      }
    } catch (e) {
      _log.warning('Failed to fetch content release manifest; '
          'falling back to pack-level select.', e);
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
    _lastRelease = release;
    _log.info('Loaded ${remote.length} curriculum packs from Supabase.');
  }

  /// The version of the currently loaded release, or 0 when only bundled
  /// content (no release manifest) is in use.
  int get releaseVersion => _lastRelease?.version ?? 0;

  Future<String> load(String path) async {
    final pack = _packs[path];
    if (pack != null) return jsonEncode(pack);
    throw StateError('Curriculum pack is not present in the snapshot: $path');
  }
}
