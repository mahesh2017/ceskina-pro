import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/sync_queue.dart';

part 'sync_dao.g.dart';

/// Data access for the sync outbox. Repositories call [enqueue] alongside
/// every local mutation; the sync service drains via [pending] and [ack].
@DriftAccessor(tables: [SyncQueue, SyncState])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // ── Pull cursors (local-only) ──

  /// Last pull cursor for [entity] as an ISO-8601 UTC string, or null if never
  /// pulled. Rows with a newer `updated_at` are fetched next pull.
  Future<DateTime?> pullCursor(String entity) async {
    final row = await (select(syncState)
          ..where((s) => s.key.equals('pull:$entity')))
        .getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  Future<void> setPullCursor(String entity, DateTime value) {
    return into(syncState).insertOnConflictUpdate(SyncStateCompanion.insert(
      key: 'pull:$entity',
      value: value.toUtc().toIso8601String(),
    ));
  }

  /// Append a mutation to the outbox. [deviceId] is left blank here and
  /// stamped by the sync service at push time — every outbox row is authored
  /// by this device, so it need not be threaded through each write path.
  Future<void> enqueue({
    required String entity,
    required String entityKey,
    required Map<String, dynamic> payload,
    String op = 'upsert',
  }) {
    return into(syncQueue).insert(SyncQueueCompanion.insert(
      entity: entity,
      entityKey: entityKey,
      op: Value(op),
      payload: jsonEncode(payload),
      deviceId: '',
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Oldest [limit] unsynced mutations, FIFO.
  Future<List<SyncQueueData>> pending({int limit = 100}) {
    return (select(syncQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(limit))
        .get();
  }

  /// Remove rows the backend has acknowledged.
  Future<void> ack(List<int> ids) {
    return (delete(syncQueue)..where((t) => t.id.isIn(ids))).go();
  }

  /// Record a failed push attempt (for backoff / diagnostics).
  Future<void> markFailed(int id) {
    return customUpdate(
      'UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {syncQueue},
    );
  }

  Future<int> pendingCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM sync_queue',
      readsFrom: {syncQueue},
    ).getSingle();
    return row.read<int>('c');
  }
}
