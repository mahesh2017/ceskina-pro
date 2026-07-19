import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';
import 'backend_service.dart';
import 'device_id.dart';

/// Drains the local sync outbox to Supabase.
///
/// Upward sync only, for now (pull/LWW-merge lands next). Each queued mutation
/// is stamped with the current user id, this device's id, and the mutation
/// time, then upserted into the matching backend table. Rows are removed from
/// the outbox only after the backend acknowledges them, so a failed or offline
/// push is simply retried next time — no data is lost.
///
/// Every method is a safe no-op when the backend is disabled or signed out.
class SyncService {
  SyncService({
    required AppDatabase db,
    required BackendService backend,
    required DeviceId deviceId,
    Logger? log,
  })  : _db = db,
        _backend = backend,
        _deviceId = deviceId,
        _log = log ?? Logger('SyncService');
  // Named-private initializing formals read worse than these plain fields.
  // ignore_for_file: prefer_initializing_formals

  final AppDatabase _db;
  final BackendService _backend;
  final DeviceId _deviceId;
  final Logger _log;

  bool _pushing = false;

  /// Conflict target (composite natural key) for each backend table.
  static const _conflictKeys = <String, String>{
    'lesson_progress': 'user_id,lesson_id',
    'earned_badges': 'user_id,badge_id',
    'user_progress': 'user_id,key',
    'srs_cards': 'user_id,card_type,content_key',
  };

  /// Push all pending outbox rows. Re-entrant-safe (skips if already running).
  Future<void> push() async {
    if (!_backend.isEnabled || !_backend.isSignedIn) return;
    if (_pushing) return;
    _pushing = true;
    try {
      final client = Supabase.instance.client;
      final userId = _backend.userId!;
      final deviceId = await _deviceId.get();

      var batch = await _db.syncDao.pending();
      while (batch.isNotEmpty) {
        final acked = <int>[];
        for (final row in batch) {
          try {
            await _send(client, row, userId, deviceId);
            acked.add(row.id);
          } catch (e) {
            // Stop on first failure in the batch; keep what already succeeded.
            await _db.syncDao.markFailed(row.id);
            _log.warning('Push failed for ${row.entity}/${row.entityKey}', e);
            break;
          }
        }
        if (acked.isNotEmpty) await _db.syncDao.ack(acked);
        // If we couldn't ack the whole batch, stop — retry next cycle.
        if (acked.length != batch.length) break;
        batch = await _db.syncDao.pending();
      }
    } finally {
      _pushing = false;
    }
  }

  /// Full sync cycle: push local changes, then pull remote ones.
  Future<void> sync() async {
    await push();
    await pull();
  }

  bool _pulling = false;

  /// Pull remote changes since the last cursor and merge them into Drift.
  /// Merges are domain-aware/monotonic (see the DAO merge methods), so this is
  /// safe to run repeatedly and in any order relative to local edits.
  Future<void> pull() async {
    if (!_backend.isEnabled || !_backend.isSignedIn) return;
    if (_pulling) return;
    _pulling = true;
    try {
      final client = Supabase.instance.client;
      final userId = _backend.userId!;
      final deviceId = await _deviceId.get();

      for (final entity in _conflictKeys.keys) {
        try {
          final cursor = await _db.syncDao.pullCursor(entity);
          var query = client.from(entity).select().eq('user_id', userId);
          if (cursor != null) {
            query = query.gt('updated_at', cursor.toUtc().toIso8601String());
          }
          final rows = await query.order('updated_at');

          DateTime? maxSeen = cursor;
          for (final row in rows.cast<Map<String, dynamic>>()) {
            // Skip our own echoes — this device already has these locally.
            if (row['device_id'] == deviceId) {
              maxSeen = _maxTs(maxSeen, row['updated_at']);
              continue;
            }
            await _applyRemote(entity, row);
            maxSeen = _maxTs(maxSeen, row['updated_at']);
          }
          if (maxSeen != null) {
            await _db.syncDao.setPullCursor(entity, maxSeen);
          }
        } catch (e) {
          _log.warning('Pull failed for $entity', e);
        }
      }
    } finally {
      _pulling = false;
    }
  }

  DateTime? _maxTs(DateTime? current, Object? iso) {
    final t = iso is String ? DateTime.tryParse(iso) : null;
    if (t == null) return current;
    if (current == null) return t;
    return t.isAfter(current) ? t : current;
  }

  DateTime? _ts(Object? iso) =>
      iso is String ? DateTime.tryParse(iso)?.toLocal() : null;

  Future<void> _applyRemote(String entity, Map<String, dynamic> r) async {
    switch (entity) {
      case 'lesson_progress':
        await _db.progressDao.mergeLessonProgress(
          lessonId: (r['lesson_id'] as num).toInt(),
          unitId: (r['unit_id'] as num).toInt(),
          isCompleted: r['is_completed'] as bool? ?? false,
          bestScore: (r['best_score'] as num?)?.toDouble() ?? 0,
          attempts: (r['attempts'] as num?)?.toInt() ?? 0,
          lastAttempted: _ts(r['last_attempted']),
        );
        break;
      case 'earned_badges':
        await _db.progressDao.mergeBadge(
          r['badge_id'] as String,
          _ts(r['earned_at']) ?? DateTime.now(),
        );
        break;
      case 'user_progress':
        await _db.progressDao.mergeUserProgress(
          r['key'] as String,
          _decodeKvValue(r['value']),
        );
        break;
      case 'srs_cards':
        await _db.vocabularyDao.mergeSrsCard(
          cardType: r['card_type'] as String,
          contentKey: r['content_key'] as String,
          stability: (r['stability'] as num?)?.toDouble() ?? 0,
          difficulty: (r['difficulty'] as num?)?.toDouble() ?? 0,
          due: _ts(r['due']) ?? DateTime.now(),
          reps: (r['reps'] as num?)?.toInt() ?? 0,
          state: r['state'] as String? ?? 'newCard',
          lastReviewed: _ts(r['last_reviewed']),
        );
        break;
    }
  }

  /// user_progress.value is jsonb. Locally it's an app-defined string; unwrap a
  /// bare JSON string, otherwise re-encode structured JSON back to a string.
  String _decodeKvValue(Object? value) {
    if (value is String) return value;
    return jsonEncode(value);
  }

  Future<void> _send(
    SupabaseClient client,
    SyncQueueData row,
    String userId,
    String deviceId,
  ) async {
    final table = row.entity;
    final onConflict = _conflictKeys[table];
    if (onConflict == null) {
      throw StateError('Unknown sync entity: $table');
    }

    if (row.op == 'delete') {
      // Deletes are keyed by natural key; not yet emitted, but handled for
      // completeness once tombstones exist.
      final payload = jsonDecode(row.payload) as Map<String, dynamic>;
      var q = client.from(table).delete().eq('user_id', userId);
      payload.forEach((k, v) => q = q.eq(k, v as Object));
      await q;
      return;
    }

    final record = <String, dynamic>{
      ...jsonDecode(row.payload) as Map<String, dynamic>,
      'user_id': userId,
      'device_id': deviceId,
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
    };
    await client.from(table).upsert(record, onConflict: onConflict);
  }
}
