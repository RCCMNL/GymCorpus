import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/database/seed_data.dart';
import 'package:path/path.dart' as p;

/// Il riallineamento dei seed su un database gia' popolato.
///
/// Regressione: le righe venivano ritrovate solo per nome, e il catalogo ha
/// esercizi omonimi. `Face Pull` esiste sotto Dorso e sotto Spalle con
/// istruzioni diverse, e tre coppie avevano addirittura lo stesso nome e lo
/// stesso muscolo pur essendo esercizi diversi: a ogni apertura l'ultima
/// voce del catalogo sovrascriveva i testi di tutte le omonime.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gym_corpus_seed_sync');
    dbFile = File(p.join(tempDir.path, 'gym_db.sqlite'));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'gli esercizi omonimi di muscoli diversi tengono le proprie istruzioni',
    () async {
      final seedDorso = getSeedExercises().singleWhere(
        (s) => s.name.value == 'Face Pull' && s.targetMuscle.value == 'Dorso',
      );

      final primo = AppDatabase(NativeDatabase(dbFile));
      await primo.select(primo.exercises).get();
      await primo.close();

      // La seconda apertura e' quella che riallinea un database esistente.
      final secondo = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondo.close);

      final riga =
          await (secondo.select(secondo.exercises)..where(
                (e) =>
                    e.name.equals('Face Pull') & e.targetMuscle.equals('Dorso'),
              ))
              .getSingle();

      expect(riga.preparation, seedDorso.preparation.value);
    },
  );

  test(
    'chi aveva due Alzate frontali omonime ritrova due esercizi distinti',
    () async {
      const nomi = ['Alzate frontali', 'Alzate frontali (Disco o Bilanciere)'];

      final primo = AppDatabase(NativeDatabase(dbFile));
      final seminati =
          await (primo.select(primo.exercises)
                ..where(
                  (e) => e.targetMuscle.equals('Spalle') & e.name.isIn(nomi),
                )
                ..orderBy([(e) => OrderingTerm.asc(e.id)]))
              .get();
      expect(seminati, hasLength(2));

      // Riporta il database allo stato di chi l'ha seminato prima della
      // correzione: due voci con lo stesso nome, con una nota dell'utente
      // sulla seconda, che non deve andare persa.
      await (primo.update(
        primo.exercises,
      )..where((e) => e.id.equals(seminati.last.id))).write(
        const ExercisesCompanion(
          name: Value('Alzate frontali'),
          userNotes: Value('la mia nota'),
        ),
      );
      await primo.close();

      final secondo = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondo.close);

      final dopo =
          await (secondo.select(secondo.exercises)
                ..where((e) => e.id.isIn([seminati.first.id, seminati.last.id]))
                ..orderBy([(e) => OrderingTerm.asc(e.id)]))
              .get();

      expect(dopo.first.name, 'Alzate frontali');
      expect(dopo.first.equipment, 'Manubri');
      expect(dopo.last.name, 'Alzate frontali (Disco o Bilanciere)');
      expect(
        dopo.last.equipment,
        'Disco (bumper/ghisa) o Bilanciere (dritto o EZ)',
      );
      expect(dopo.last.userNotes, 'la mia nota');
    },
  );

  test('la correzione dei nomi non si ripete a ogni apertura', () async {
    for (var apertura = 0; apertura < 3; apertura++) {
      final db = AppDatabase(NativeDatabase(dbFile));
      await db.select(db.exercises).get();
      await db.close();
    }

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);

    Future<int> quanti(String nome) async => (await (db.select(
      db.exercises,
    )..where((e) => e.name.equals(nome))).get()).length;

    expect(await quanti('Alzate frontali'), 1);
    expect(await quanti('Alzate frontali (Disco o Bilanciere)'), 1);
  });

  test(
    'la parentesi orfana nel nome viene corretta anche su chi ce l aveva gia',
    () async {
      const vecchio = 'Calf Raises su scalino, 2 gambe)';
      const nuovo = 'Calf Raises su scalino (2 gambe)';

      final primo = AppDatabase(NativeDatabase(dbFile));
      final riga =
          await (primo.select(primo.exercises)..where(
                (e) =>
                    e.targetMuscle.equals('Polpacci') &
                    e.name.isIn([vecchio, nuovo]),
              ))
              .getSingle();
      await (primo.update(primo.exercises)..where((e) => e.id.equals(riga.id)))
          .write(const ExercisesCompanion(name: Value(vecchio)));
      await primo.close();

      final secondo = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondo.close);

      final dopo = await (secondo.select(
        secondo.exercises,
      )..where((e) => e.id.equals(riga.id))).getSingle();

      expect(dopo.name, nuovo);
    },
  );

  test('la correzione dei nomi non tocca gli esercizi custom', () async {
    final primo = AppDatabase(NativeDatabase(dbFile));
    await primo.select(primo.exercises).get();
    final id = await primo
        .into(primo.exercises)
        .insert(
          const ExercisesCompanion(
            name: Value('Calf Raises su scalino, 2 gambe)'),
            targetMuscle: Value('Polpacci'),
            isCustom: Value(true),
          ),
        );
    await primo.close();

    final secondo = AppDatabase(NativeDatabase(dbFile));
    addTearDown(secondo.close);

    final riga = await (secondo.select(
      secondo.exercises,
    )..where((e) => e.id.equals(id))).getSingle();

    expect(riga.name, 'Calf Raises su scalino, 2 gambe)');
  });
}
