import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:path/path.dart' as p;

/// Verifica che la strategia di migrazione additiva riporti sul DB di un
/// utente gia' esistente ogni colonna dichiarata nello schema corrente.
///
/// Regressione: `CardioSessions.steps` era stata aggiunta allo schema (v16)
/// senza il corrispondente `_ensureColumn`, quindi chi aggiornava da una
/// versione precedente non riceveva la colonna e ogni insert/select sulle
/// sessioni cardio falliva con "no such column: steps".
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gym_corpus_migration');
    dbFile = File(p.join(tempDir.path, 'gym_db.sqlite'));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Elenco delle colonne realmente presenti su una tabella del DB aperto.
  Future<Set<String>> columnsOf(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.map((row) => row.data['name'] as String).toSet();
  }

  test(
    'la migrazione ripristina una colonna mancante su cardio_sessions',
    () async {
      // 1. Primo avvio: lo schema corrente viene creato per intero.
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      expect(await columnsOf(firstRun, 'cardio_sessions'), contains('steps'));

      // 2. Simula il DB di un utente aggiornato da una versione precedente,
      //    in cui la colonna non era ancora stata introdotta.
      await firstRun.customStatement(
        'ALTER TABLE cardio_sessions DROP COLUMN steps',
      );
      expect(
        await columnsOf(firstRun, 'cardio_sessions'),
        isNot(contains('steps')),
      );
      await firstRun.close();

      // 3. Riapertura: la migrazione additiva deve riaggiungere la colonna.
      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);
      expect(await columnsOf(secondRun, 'cardio_sessions'), contains('steps'));

      // 4. E le scritture che usano la colonna devono funzionare.
      await secondRun
          .into(secondRun.cardioSessions)
          .insert(
            CardioSessionsCompanion.insert(
              distance: 5.2,
              duration: 1800,
              avgSpeed: 10.4,
              pace: '05:46',
              calories: 320,
              date: DateTime(2026, 8, 12),
              steps: const Value(6420),
            ),
          );

      final saved = await secondRun
          .select(secondRun.cardioSessions)
          .getSingle();
      expect(saved.steps, 6420);
    },
  );

  test(
    'ogni colonna dello schema corrente sopravvive a una riapertura',
    () async {
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      final expected = <String, Set<String>>{};
      for (final table in firstRun.allTables) {
        expected[table.actualTableName] = await columnsOf(
          firstRun,
          table.actualTableName,
        );
      }
      await firstRun.close();

      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);
      for (final entry in expected.entries) {
        expect(
          await columnsOf(secondRun, entry.key),
          containsAll(entry.value),
          reason: 'colonne perse sulla tabella ${entry.key}',
        );
      }
    },
  );
}
