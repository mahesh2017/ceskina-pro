import 'dart:async';

import 'package:ceskina_pro/data/database/daos/sync_dao.dart';
import 'package:ceskina_pro/data/database/database.dart';
import 'package:ceskina_pro/data/sync/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSyncBackend implements SyncBackend {
  final rows = <String, List<Map<String, dynamic>>>{};
  final sentKeys = <String>[];
  final failingKeys = <String>{};
  Completer<void>? sendGate;
  int activeSends = 0;
  int maxActiveSends = 0;

  @override
  bool isReady = true;

  @override
  String? userId = 'user-1';

  @override
  Future<String> deviceId() async => 'local-device';

  @override
  Future<void> send(SyncQueueData row, {required String onConflict}) async {
    activeSends++;
    if (activeSends > maxActiveSends) maxActiveSends = activeSends;
    try {
      await sendGate?.future;
      sentKeys.add(row.entityKey);
      if (failingKeys.contains(row.entityKey)) {
        throw StateError('rejected ${row.entityKey}');
      }
    } finally {
      activeSends--;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pullPage(
    String entity, {
    required PullCursor? cursor,
    required int limit,
  }) async {
    final source = rows[entity] ?? const [];
    return source
        .where((row) {
          if (cursor == null) return true;
          final timestamp = DateTime.parse(row['updated_at'] as String);
          final id = (row['sync_id'] as num).toInt();
          return timestamp.isAfter(cursor.updatedAt) ||
              (timestamp.isAtSameMomentAs(cursor.updatedAt) &&
                  id > cursor.syncId);
        })
        .take(limit)
        .toList();
  }
}

void main() {
  late AppDatabase database;
  late FakeSyncBackend backend;
  late DateTime now;
  late SyncService service;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').get();
    backend = FakeSyncBackend();
    now = DateTime.utc(2026, 7, 20);
    service = SyncService(db: database, backend: backend, clock: () => now);
  });

  tearDown(() => database.close());

  Future<void> enqueue(String key) => database.syncDao.enqueue(
    entity: 'user_progress',
    entityKey: key,
    payload: {'key': key, 'value': 1},
  );

  test('concurrent sync callers share one serialized run', () async {
    await enqueue('streak');
    backend.sendGate = Completer<void>();

    final first = service.sync();
    final second = service.sync();
    await Future<void>.delayed(Duration.zero);

    expect(backend.activeSends, 1);
    expect(backend.maxActiveSends, 1);
    backend.sendGate!.complete();
    await Future.wait([first, second]);

    expect(backend.sentKeys, ['streak']);
    expect(await database.syncDao.pendingCount(), 0);
  });

  test(
    'poison row does not block later rows and is eventually dead-lettered',
    () async {
      await enqueue('poison');
      await enqueue('healthy');
      backend.failingKeys.add('poison');

      await service.push();
      expect(backend.sentKeys, containsAll(['poison', 'healthy']));
      expect(await database.syncDao.pendingCount(), 1);

      for (final seconds in [2, 4, 8, 16]) {
        now = now.add(Duration(seconds: seconds));
        await service.push();
      }

      expect(await database.syncDao.deadLetterCount(), 1);
      expect(await database.syncDao.pending(now: now), isEmpty);
      final failed = await database.select(database.syncQueue).getSingle();
      expect(failed.attempts, 5);
      expect(failed.deadLetteredAt, isNotNull);
      expect(failed.lastError, contains('rejected poison'));
    },
  );

  test('composite cursor pulls every row sharing the same timestamp', () async {
    final timestamp = DateTime.utc(2026, 7, 20, 12).toIso8601String();
    backend.rows['lesson_progress'] = List.generate(205, (index) {
      final id = index + 1;
      return {
        'sync_id': id,
        'updated_at': timestamp,
        'device_id': 'remote-device',
        'lesson_id': id,
        'unit_id': 1,
        'is_completed': true,
        'best_score': 80.0,
        'attempts': 1,
        'last_attempted': timestamp,
      };
    });

    await service.pull();

    expect(
      await database.select(database.lessonProgress).get(),
      hasLength(205),
    );
    final cursor = await database.syncDao.pullCursor('lesson_progress');
    expect(cursor?.updatedAt.toUtc(), DateTime.parse(timestamp));
    expect(cursor?.syncId, 205);
  });

  test(
    'gamification state is pulled without echoing into the outbox',
    () async {
      final timestamp = DateTime.utc(2026, 7, 20, 13).toIso8601String();
      backend.rows['gamification_state'] = [
        {
          'sync_id': 1,
          'updated_at': timestamp,
          'device_id': 'remote-device',
          'key': 'primary',
          'hearts': 3,
          'max_hearts': 5,
          'current_streak': 4,
          'longest_streak': 8,
          'total_xp': 240,
          'daily_xp': 30,
          'daily_goal_xp': 60,
          'gems': 7,
          'earned_badges': ['first', 'streak_7'],
          'last_heart_refill': null,
          'streak_freeze_available': false,
          'last_open_date': '2026-07-20',
          'daily_xp_reset_date': '2026-07-20',
        },
      ];

      await service.pull();

      final state = await database.gamificationDao.load();
      expect(state?.hearts, 3);
      expect(state?.totalXp, 240);
      expect(state?.earnedBadges, '["first","streak_7"]');
      expect(await database.syncDao.pendingCount(), 0);
    },
  );
}
