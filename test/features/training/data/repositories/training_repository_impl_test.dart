import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/features/training/data/repositories/training_repository_impl.dart';

/// Copre la guardia sui nomi duplicati aggiunta dopo che la UI permetteva
/// di creare piu' esercizi custom identici senza alcun avviso.
void main() {
  late AppDatabase database;
  late TrainingRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TrainingRepositoryImpl(database: database);
  });

  tearDown(() => database.close());

  group('addCustomExercise - nomi duplicati', () {
    test('blocca un nome gia usato nello stesso gruppo muscolare', () async {
      final first = await repository.addCustomExercise(
        name: 'Curl con elastici viola',
        targetMuscle: 'Bicipiti',
        difficulty: 'Principiante',
      );
      expect(first, isA<Right<Object?, int>>());

      final second = await repository.addCustomExercise(
        name: 'Curl con elastici viola',
        targetMuscle: 'Bicipiti',
        difficulty: 'Intermedio',
      );

      expect(second, isA<Left<Object?, int>>());
    });

    test('il confronto ignora maiuscole/minuscole e spazi ai lati', () async {
      await repository.addCustomExercise(
        name: 'Curl con elastici viola',
        targetMuscle: 'Bicipiti',
        difficulty: 'Principiante',
      );

      final duplicate = await repository.addCustomExercise(
        name: '  CURL CON ELASTICI VIOLA  ',
        targetMuscle: 'Bicipiti',
        difficulty: 'Intermedio',
      );

      expect(duplicate, isA<Left<Object?, int>>());
    });

    test('permette lo stesso nome in un gruppo muscolare diverso', () async {
      await repository.addCustomExercise(
        name: 'Esercizio Test Cross-Gruppo',
        targetMuscle: 'Dorso',
        difficulty: 'Principiante',
      );

      final result = await repository.addCustomExercise(
        name: 'Esercizio Test Cross-Gruppo',
        targetMuscle: 'Spalle',
        difficulty: 'Principiante',
      );

      expect(result, isA<Right<Object?, int>>());
    });
  });

  group('updateCustomExercise - nomi duplicati', () {
    test(
      'permette di salvare senza cambiare nome (non collide con se stesso)',
      () async {
        final created = await repository.addCustomExercise(
          name: 'Curl con elastici viola',
          targetMuscle: 'Bicipiti',
          difficulty: 'Principiante',
        );
        final id = (created as Right).value as int;

        final result = await repository.updateCustomExercise(
          id: id,
          name: 'Curl con elastici viola',
          targetMuscle: 'Bicipiti',
          difficulty: 'Avanzato',
        );

        expect(result, isA<Right<Object?, void>>());
      },
    );

    test(
      'blocca la rinomina se collide con un altro esercizio esistente',
      () async {
        await repository.addCustomExercise(
          name: 'Curl A',
          targetMuscle: 'Bicipiti',
          difficulty: 'Principiante',
        );
        final second = await repository.addCustomExercise(
          name: 'Curl B',
          targetMuscle: 'Bicipiti',
          difficulty: 'Principiante',
        );
        final secondId = (second as Right).value as int;

        final result = await repository.updateCustomExercise(
          id: secondId,
          name: 'Curl A',
          targetMuscle: 'Bicipiti',
          difficulty: 'Principiante',
        );

        expect(result, isA<Left<Object?, void>>());
      },
    );
  });

  // Le routine di sistema sono seedate automaticamente all'apertura del DB
  // (vedi database.dart _seedDefaultRoutines), quindi ne basta una qualsiasi
  // per verificare la guardia modifica/elimina e il flusso di copia.
  group('ordine degli esercizi di una routine', () {
    test('gli esercizi tornano nell ordine indicato da orderIndex', () async {
      final exercises = await database.select(database.exercises).get();
      final routineId = await database
          .into(database.routines)
          .insert(const RoutinesCompanion(title: Value('Ordine')));

      // Inseriti al contrario rispetto all'ordine voluto: senza un ordine
      // esplicito tornerebbero come sono stati scritti.
      for (final (position, exercise) in [
        (2, exercises[0]),
        (0, exercises[1]),
        (1, exercises[2]),
      ]) {
        await database
            .into(database.routineExercises)
            .insert(
              RoutineExercisesCompanion.insert(
                routineId: routineId,
                exerciseId: exercise.id,
                orderIndex: Value(position),
              ),
            );
      }

      final routines = await repository.watchRoutines().first;
      final saved = routines.firstWhere((r) => r.id == routineId);

      expect(saved.exercises.map((e) => e.orderIndex), [0, 1, 2]);
      expect(saved.exercises.map((e) => e.exercise.id), [
        exercises[1].id,
        exercises[2].id,
        exercises[0].id,
      ]);
    });
  });

  group('routine di sistema', () {
    test('non si possono modificare direttamente', () async {
      final systemRoutine = (await (database.select(
        database.routines,
      )..where((r) => r.isSystem.equals(true))).get()).first;

      final result = await repository.updateRoutine(
        systemRoutine.id,
        'Nome modificato',
        const [],
        null,
      );

      expect(result, isA<Left<Object?, void>>());
      final unchanged = await (database.select(
        database.routines,
      )..where((r) => r.id.equals(systemRoutine.id))).getSingle();
      expect(unchanged.title, systemRoutine.title);
    });

    test('non si possono eliminare direttamente', () async {
      final systemRoutine = (await (database.select(
        database.routines,
      )..where((r) => r.isSystem.equals(true))).get()).first;

      final result = await repository.deleteRoutine(systemRoutine.id);

      expect(result, isA<Left<Object?, void>>());
      final stillThere = await (database.select(
        database.routines,
      )..where((r) => r.id.equals(systemRoutine.id))).getSingleOrNull();
      expect(stillThere, isNotNull);
    });

    test(
      'la copia crea una routine utente indipendente con gli stessi esercizi',
      () async {
        final systemRoutine = (await (database.select(
          database.routines,
        )..where((r) => r.isSystem.equals(true))).get()).first;
        final originalExercises = await (database.select(
          database.routineExercises,
        )..where((t) => t.routineId.equals(systemRoutine.id))).get();

        final result = await repository.copyRoutine(systemRoutine.id);
        expect(result, isA<Right<Object?, int>>());
        final newId = (result as Right).value as int;

        final copy = await (database.select(
          database.routines,
        )..where((r) => r.id.equals(newId))).getSingle();
        expect(copy.isSystem, isFalse);
        expect(copy.title, '${systemRoutine.title} (copia)');

        final copiedExercises = await (database.select(
          database.routineExercises,
        )..where((t) => t.routineId.equals(newId))).get();
        expect(copiedExercises.length, originalExercises.length);

        // La copia e' una routine utente normale...
        final updateResult = await repository.updateRoutine(
          newId,
          'Nome personalizzato',
          const [],
          null,
        );
        expect(updateResult, isA<Right<Object?, void>>());

        // ...mentre l'originale di sistema resta intatto e bloccato.
        final originalStillThere = await (database.select(
          database.routines,
        )..where((r) => r.id.equals(systemRoutine.id))).getSingle();
        expect(originalStillThere.title, systemRoutine.title);
      },
    );

    test(
      'la copia registra l origine di sistema per poterla ripristinare',
      () async {
        final systemRoutine = (await (database.select(
          database.routines,
        )..where((r) => r.isSystem.equals(true))).get()).first;

        final result = await repository.copyRoutine(systemRoutine.id);
        final newId = (result as Right).value as int;

        final copy = await (database.select(
          database.routines,
        )..where((r) => r.id.equals(newId))).getSingle();
        expect(copy.sourceRoutineId, systemRoutine.id);
      },
    );
  });

  group('resetRoutineToSource', () {
    test(
      'riporta la copia identica alla routine di sistema di origine, anche '
      'dopo aggiunte/rimozioni di esercizi',
      () async {
        final systemRoutine = (await (database.select(
          database.routines,
        )..where((r) => r.isSystem.equals(true))).get()).first;

        final copyResult = await repository.copyRoutine(systemRoutine.id);
        final copyId = (copyResult as Right).value as int;

        // L'utente stravolge la sua copia: cambia i parametri di un
        // esercizio e ne rimuove un altro.
        final copiedExercises = await (database.select(
          database.routineExercises,
        )..where((t) => t.routineId.equals(copyId))).get();
        await (database.update(
          database.routineExercises,
        )..where((t) => t.id.equals(copiedExercises.first.id))).write(
          const RoutineExercisesCompanion(
            sets: Value(99),
            reps: Value(99),
            weight: Value(999),
          ),
        );
        if (copiedExercises.length > 1) {
          await (database.delete(database.routineExercises)
                ..where((t) => t.id.equals(copiedExercises.last.id)))
              .go();
        }

        final resetResult = await repository.resetRoutineToSource(copyId);
        expect(resetResult, isA<Right<Object?, void>>());

        final originalExercises = await (database.select(
          database.routineExercises,
        )..where((t) => t.routineId.equals(systemRoutine.id))).get();
        final resetExercises = await (database.select(
          database.routineExercises,
        )..where((t) => t.routineId.equals(copyId))).get();

        expect(resetExercises.length, originalExercises.length);
        for (final original in originalExercises) {
          final restored = resetExercises.firstWhere(
            (row) => row.exerciseId == original.exerciseId,
          );
          expect(restored.sets, original.sets);
          expect(restored.reps, original.reps);
          expect(restored.weight, original.weight);
          expect(restored.orderIndex, original.orderIndex);
        }
      },
    );

    test(
      'fallisce se la routine non ha un origine di sistema da ripristinare',
      () async {
        final ownRoutineResult = await repository.addRoutine(
          'Scheda mia',
          const [],
          null,
        );
        final ownRoutineId = (ownRoutineResult as Right).value as int;

        final result = await repository.resetRoutineToSource(ownRoutineId);

        expect(result, isA<Left<Object?, void>>());
      },
    );
  });
}
