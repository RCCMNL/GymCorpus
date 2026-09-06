import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/database/seeds/default_routines.dart';
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
    'la riapertura ripristina la difficolta mancante per nome, senza toccare gli esercizi custom',
    () async {
      // 1. Primo avvio: seeding iniziale, ogni esercizio predefinito ha una
      //    difficolta assegnata.
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      final crunch = await (firstRun.select(
        firstRun.exercises,
      )..where((e) => e.name.equals('Crunch'))).getSingle();
      expect(crunch.difficulty, 'Principiante');

      // Esercizio custom dell'utente, con lo stesso nome di uno predefinito
      // (caso limite): la difficolta e' lasciata volutamente nulla per
      // verificare che il backfill non la sovrascriva per errore.
      await firstRun
          .into(firstRun.exercises)
          .insert(
            ExercisesCompanion.insert(
              name: 'Crunch',
              targetMuscle: 'Addominali',
              isCustom: const Value(true),
            ),
          );

      // 2. Simula un'installazione precedente a questa funzionalita: la
      //    colonna esiste ma i valori non sono mai stati popolati.
      await firstRun.customStatement('UPDATE exercises SET difficulty = NULL');
      final wiped =
          await (firstRun.select(firstRun.exercises)..where(
                (e) => e.name.equals('Crunch') & e.isCustom.equals(false),
              ))
              .getSingle();
      expect(wiped.difficulty, null);
      await firstRun.close();

      // 3. Riapertura: il backfill deve ripristinare la difficolta sugli
      //    esercizi predefiniti cercandoli per nome nei dati seed...
      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);

      final restored =
          await (secondRun.select(secondRun.exercises)..where(
                (e) => e.name.equals('Crunch') & e.isCustom.equals(false),
              ))
              .getSingle();
      expect(restored.difficulty, 'Principiante');

      final noMissing = await (secondRun.select(
        secondRun.exercises,
      )..where((e) => e.isCustom.equals(false))).get();
      expect(noMissing.any((e) => e.difficulty == null), isFalse);

      // ...ma non deve mai toccare un esercizio custom, anche se omonimo.
      final customExercise =
          await (secondRun.select(secondRun.exercises)..where(
                (e) => e.name.equals('Crunch') & e.isCustom.equals(true),
              ))
              .getSingle();
      expect(customExercise.difficulty, null);
    },
  );

  test(
    'la riapertura riallinea i testi di catalogo modificati nei seed',
    () async {
      // Regressione: il refuso "with" al posto di "con" era stato
      // corretto nei seed, ma chi aveva gia' il database popolato
      // continuava a vederlo, perche' il seeding gira solo a tabella
      // vuota.
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      final seeded = await (firstRun.select(
        firstRun.exercises,
      )..where((e) => e.name.equals('Sissy Squat'))).getSingle();
      // isA<String>() invece di isNotNull: quest'ultimo e' esportato sia
      // da drift che da matcher e l'import risulterebbe ambiguo.
      final realEquipment = seeded.equipment;
      expect(realEquipment, isA<String>());

      // Simula il testo vecchio rimasto in un'installazione esistente.
      await (firstRun.update(
        firstRun.exercises,
      )..where((e) => e.id.equals(seeded.id))).write(
        const ExercisesCompanion(equipment: Value('Corpo libero (with X)')),
      );

      // Nota personale e preferito: sono dell'utente, il riallineamento
      // non deve toccarli.
      await (firstRun.update(
        firstRun.exercises,
      )..where((e) => e.id.equals(seeded.id))).write(
        const ExercisesCompanion(
          userNotes: Value('la mia nota'),
          isFavorite: Value(true),
        ),
      );
      await firstRun.close();

      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);

      final repaired = await (secondRun.select(
        secondRun.exercises,
      )..where((e) => e.id.equals(seeded.id))).getSingle();
      expect(repaired.equipment, realEquipment);
      expect(repaired.userNotes, 'la mia nota');
      expect(repaired.isFavorite, isTrue);
    },
  );

  test('il riallineamento non tocca gli esercizi custom dell utente', () async {
    final firstRun = AppDatabase(NativeDatabase(dbFile));
    // Omonimo di un esercizio predefinito: il caso limite in cui una
    // ricerca per nome potrebbe sovrascrivere dati dell'utente.
    final customId = await firstRun
        .into(firstRun.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Sissy Squat',
            targetMuscle: 'Gambe',
            equipment: const Value('Il mio attrezzo'),
            isCustom: const Value(true),
          ),
        );
    await firstRun.close();

    final secondRun = AppDatabase(NativeDatabase(dbFile));
    addTearDown(secondRun.close);

    final custom = await (secondRun.select(
      secondRun.exercises,
    )..where((e) => e.id.equals(customId))).getSingle();
    expect(custom.equipment, 'Il mio attrezzo');
  });

  test(
    'il primo avvio semina le routine di sistema con gli esercizi giusti',
    () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      addTearDown(db.close);

      for (final routineSeed in getDefaultRoutines()) {
        final routine =
            await (db.select(db.routines)..where(
                  (r) =>
                      r.title.equals(routineSeed.title) &
                      r.isSystem.equals(true),
                ))
                .getSingle();

        final exercisesRows = await (db.select(
          db.routineExercises,
        )..where((t) => t.routineId.equals(routine.id))).get();
        expect(
          exercisesRows.length,
          routineSeed.exercises.length,
          reason: 'esercizi mancanti in "${routineSeed.title}"',
        );

        for (final exerciseSeed in routineSeed.exercises) {
          final linkedExercise =
              await (db.select(db.exercises)
                    ..where((e) => e.name.equals(exerciseSeed.exerciseName)))
                  .getSingle();
          final link = exercisesRows.firstWhere(
            (row) => row.exerciseId == linkedExercise.id,
            orElse: () => throw StateError(
              '"${exerciseSeed.exerciseName}" non collegato a '
              '"${routineSeed.title}"',
            ),
          );
          expect(link.sets, exerciseSeed.sets);
          expect(link.reps, exerciseSeed.reps);
        }
      }
    },
  );

  test('il seeding delle routine di sistema e idempotente e non tocca quelle '
      'dell utente', () async {
    final firstRun = AppDatabase(NativeDatabase(dbFile));
    final systemCountBefore = await (firstRun.select(
      firstRun.routines,
    )..where((r) => r.isSystem.equals(true))).get();
    expect(systemCountBefore.length, getDefaultRoutines().length);

    // Routine dell'utente, per verificare che il reseed non la tocchi.
    final userRoutineId = await firstRun
        .into(firstRun.routines)
        .insert(RoutinesCompanion.insert(title: 'La mia routine'));
    await firstRun.close();

    final secondRun = AppDatabase(NativeDatabase(dbFile));
    addTearDown(secondRun.close);

    final systemCountAfter = await (secondRun.select(
      secondRun.routines,
    )..where((r) => r.isSystem.equals(true))).get();
    expect(
      systemCountAfter.length,
      getDefaultRoutines().length,
      reason: 'le routine di sistema non devono duplicarsi al riavvio',
    );

    final userRoutine = await (secondRun.select(
      secondRun.routines,
    )..where((r) => r.id.equals(userRoutineId))).getSingle();
    expect(userRoutine.title, 'La mia routine');
    expect(userRoutine.isSystem, isFalse);
  });

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

  test('la riapertura crea la tabella del ciclo se manca', () async {
    // Il calendario ciclo arriva dopo: chi aggiorna l'app ha un database
    // senza quella tabella, e la strategia additiva deve crearla senza
    // toccare il resto dei dati.
    final firstRun = AppDatabase(NativeDatabase(dbFile));
    await firstRun.customStatement('DROP TABLE cycle_logs');
    await firstRun.close();

    final secondRun = AppDatabase(NativeDatabase(dbFile));
    addTearDown(secondRun.close);

    final id = await secondRun.insertCycleLog(
      CycleLogsCompanion.insert(startDate: DateTime(2026, 9)),
    );
    await secondRun.closeCycleLog(id, DateTime(2026, 9, 5));

    final saved = await secondRun.select(secondRun.cycleLogs).getSingle();
    expect(saved.startDate, DateTime(2026, 9));
    expect(saved.endDate, DateTime(2026, 9, 5));
  });

  test(
    'la riapertura riporta le colonne obiettivo sulle sessioni cardio',
    () async {
      // L'obiettivo di sessione arriva dopo: chi aggiorna l'app ha la tabella
      // senza quelle colonne, e senza il ripristino ogni salvataggio cardio
      // fallirebbe con "no such column".
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      await firstRun.customStatement(
        'ALTER TABLE cardio_sessions DROP COLUMN goal_type',
      );
      await firstRun.customStatement(
        'ALTER TABLE cardio_sessions DROP COLUMN goal_value',
      );
      await firstRun.close();

      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);

      await secondRun
          .into(secondRun.cardioSessions)
          .insert(
            CardioSessionsCompanion.insert(
              distance: 5,
              duration: 1800,
              avgSpeed: 10,
              pace: '06:00',
              calories: 300,
              date: DateTime(2026, 9, 4),
              goalType: const Value('distance'),
              goalValue: const Value(5),
            ),
          );

      final saved = await secondRun
          .select(secondRun.cardioSessions)
          .getSingle();
      expect(saved.goalType, 'distance');
      expect(saved.goalValue, 5);
    },
  );
}
