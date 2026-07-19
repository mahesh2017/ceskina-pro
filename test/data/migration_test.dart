import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:ceskina_pro/data/database/database.dart';

void main() {
  test('schema v1 → v4 migration preserves data and adds new schema', () async {
    final file = File(
      p.join(
        Directory.systemTemp.path,
        'ceskina_migration_test_${DateTime.now().microsecondsSinceEpoch}.db',
      ),
    );
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    // 1. Create a current database, then hand-downgrade it to the exact v1
    // shape: no lesson_id, sync_queue, or sync_state.
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await db.customSelect('SELECT 1').get(); // force open + createAll
    await db.close();

    final rawDb = raw.sqlite3.open(file.path);
    rawDb.execute('ALTER TABLE flashcards DROP COLUMN lesson_id');
    rawDb.execute('DROP TABLE sync_queue');
    rawDb.execute('DROP TABLE sync_state');
    rawDb.execute('PRAGMA user_version = 1');
    // Seed a row the way a v1 install would have it.
    rawDb.execute(
      "INSERT INTO flashcards (id, word_cz, word_en) VALUES (1, 'pes', 'dog')",
    );
    final before =
        rawDb
            .select("SELECT name FROM pragma_table_info('flashcards')")
            .map((r) => r['name'])
            .toList();
    expect(before, isNot(contains('lesson_id')));
    final tablesBefore =
        rawDb
            .select("SELECT name FROM sqlite_master WHERE type = 'table'")
            .map((r) => r['name'])
            .toList();
    expect(tablesBefore, isNot(contains('sync_queue')));
    expect(tablesBefore, isNot(contains('sync_state')));
    rawDb.dispose();

    // 2. Reopen through AppDatabase — the complete upgrade chain must add
    // every later schema object without touching existing rows.
    db = AppDatabase.forTesting(NativeDatabase(file));
    final cols =
        await db
            .customSelect("SELECT name FROM pragma_table_info('flashcards')")
            .get();
    expect(cols.map((r) => r.read<String>('name')), contains('lesson_id'));

    final row =
        await db
            .customSelect(
              'SELECT word_cz, lesson_id FROM flashcards WHERE id = 1',
            )
            .getSingle();
    expect(row.read<String>('word_cz'), 'pes');
    expect(row.readNullable<int>('lesson_id'), isNull);

    final tables =
        await db
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
            .get();
    final tableNames = tables.map((r) => r.read<String>('name'));
    expect(tableNames, containsAll(<String>['sync_queue', 'sync_state']));

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 4);
    await db.close();
  });
}
