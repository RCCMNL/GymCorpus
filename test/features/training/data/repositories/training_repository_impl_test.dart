import 'package:dartz/dartz.dart';
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
}
