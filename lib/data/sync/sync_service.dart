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
