import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/sync_queue.dart';

part 'sync_dao.g.dart';

class PullCursor {
  const PullCursor({required this.updatedAt, required this.syncId});

  final DateTime updatedAt;
  final int syncId;
}

/// Data access for the sync outbox. Repositories call [enqueue] alongside
/// every local mutation; the sync service drains via [pending] and [ack].
@DriftAccessor(tables: [SyncQueue, SyncState])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // ── Pull cursors (local-only) ──

  /// Composite keyset cursor. Legacy timestamp-only values are accepted with
  /// a zero tie-breaker so existing installations upgrade without data loss.
  Future<PullCursor?> pullCursor(String entity) async {
    final row =
        await (select(syncState)
          ..where((s) => s.key.equals('pull:$entity'))).getSingleOrNull();
    if (row == null) return null;
    try {
      final value = jsonDecode(row.value) as Map<String, dynamic>;
      final timestamp = DateTime.tryParse(value['updated_at'] as String);
      if (timestamp == null) return null;
      return PullCursor(
        updatedAt: timestamp,
        syncId: (value['sync_id'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      final timestamp = DateTime.tryParse(row.value);
      return timestamp == null
          ? null
          : PullCursor(updatedAt: timestamp, syncId: 0);
    }
  }

  Future<void> setPullCursor(String entity, PullCursor value) {
    return into(syncState).insertOnConflictUpdate(
      SyncStateCompanion.insert(
        key: 'pull:$entity',
        value: jsonEncode({
          'updated_at': value.updatedAt.toUtc().toIso8601String(),
          'sync_id': value.syncId,
        }),
      ),
    );
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
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entity: entity,
        entityKey: entityKey,
        op: Value(op),
        payload: jsonEncode(payload),
        deviceId: '',
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Oldest [limit] unsynced mutations, FIFO.
  Future<List<SyncQueueData>> pending({int limit = 100, DateTime? now}) {
    final eligibleAt = now ?? DateTime.now();
    return (select(syncQueue)
          ..where(
            (t) =>
                t.deadLetteredAt.isNull() &
                (t.nextAttemptAt.isNull() |
                    t.nextAttemptAt.isSmallerOrEqualValue(eligibleAt)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(limit))
        .get();
  }

  /// Remove rows the backend has acknowledged.
  Future<void> ack(List<int> ids) {
    return (delete(syncQueue)..where((t) => t.id.isIn(ids))).go();
  }

  /// Record a failure and either schedule exponential backoff or dead-letter
  /// the row once [maxAttempts] is reached.
  Future<void> markFailed(
    int id, {
    required Object error,
    required DateTime now,
    int maxAttempts = 5,
  }) async {
    final row =
        await (select(syncQueue)
          ..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    final attempts = row.attempts + 1;
    final dead = attempts >= maxAttempts;
    final exponent = attempts > 6 ? 6 : attempts;
    final delay = Duration(seconds: 1 << exponent);
    final message = error.toString();
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        attempts: Value(attempts),
        nextAttemptAt: Value(dead ? null : now.add(delay)),
        deadLetteredAt: Value(dead ? now : null),
        lastError: Value(
          message.length <= 500 ? message : message.substring(0, 500),
        ),
      ),
    );
  }

  Future<int> pendingCount() async {
    final row =
        await customSelect(
          'SELECT COUNT(*) AS c FROM sync_queue',
          readsFrom: {syncQueue},
        ).getSingle();
    return row.read<int>('c');
  }

  Future<int> deadLetterCount() async {
    final count = syncQueue.id.count();
    final row =
        await (selectOnly(syncQueue)
              ..addColumns([count])
              ..where(syncQueue.deadLetteredAt.isNotNull()))
            .getSingle();
    return row.read(count) ?? 0;
  }
}
