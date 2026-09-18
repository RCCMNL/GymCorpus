import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/services/routine_draft.dart';

RoutineExerciseEntity _exercise({
  bool isBodyweight = false,
  double weight = 40,
  String? setsData,
}) {
  return RoutineExerciseEntity(
    id: 1,
    routineId: 1,
    exercise: ExerciseEntity(
      id: 1,
      name: 'Panca',
      targetMuscle: 'Petto',
      isBodyweight: isBodyweight,
    ),
    sets: 2,
    reps: 10,
    weight: weight,
    orderIndex: 0,
    setsData: setsData,
  );
}

RoutineDraft _draft({
  String name = 'forza',
  List<RoutineExerciseEntity>? exercises,
}) {
  return RoutineDraft(name: name, exercises: exercises ?? [_exercise()]);
}

List<Map<String, dynamic>> _sets(RoutineExerciseEntity exercise) {
  return (jsonDecode(exercise.setsData!) as List<dynamic>)
      .cast<Map<String, dynamic>>();
}

void main() {
  group('RoutineDraft.problem', () {
    test('senza nome non si salva', () {
      expect(_draft(name: '').problem, RoutineDraftProblem.missingName);
    });

    test('un nome di soli spazi resta un nome mancante', () {
      expect(_draft(name: '   ').problem, RoutineDraftProblem.missingName);
    });

    test('senza esercizi non si salva', () {
      expect(
        _draft(exercises: const []).problem,
        RoutineDraftProblem.noExercises,
      );
    });

    test('una bozza completa non ha problemi', () {
      expect(_draft().problem, isNull);
    });
  });

  group('RoutineDraft.normalizedName', () {
    test('il nome viene salvato con l iniziale maiuscola', () {
      expect(_draft(name: 'forza totale').normalizedName, 'Forza totale');
    });

    test('gli spazi ai lati del nome non vengono salvati', () {
      expect(_draft(name: '  push day ').normalizedName, 'Push day');
    });
  });

  group('RoutineDraft.exercisesToSave', () {
    test('un esercizio a corpo libero viene salvato senza peso', () {
      final saved = _draft(
        exercises: [
          _exercise(
            isBodyweight: true,
            weight: 20,
            setsData: '[{"weight":20,"reps":12},{"weight":20,"reps":10}]',
          ),
        ],
      ).exercisesToSave().single;

      expect(saved.weight, 0);
      expect(_sets(saved), [
        {'weight': 0, 'reps': 12},
        {'weight': 0, 'reps': 10},
      ]);
    });

    test('a corpo libero un setsData illeggibile ricade su una serie', () {
      final saved = _draft(
        exercises: [_exercise(isBodyweight: true, setsData: 'non e json')],
      ).exercisesToSave().single;

      expect(_sets(saved), [
        {'weight': 0, 'reps': 0},
      ]);
    });

    test('a corpo libero un setsData assente non blocca il salvataggio', () {
      final saved = _draft(
        exercises: [_exercise(isBodyweight: true)],
      ).exercisesToSave().single;

      expect(_sets(saved), [
        {'weight': 0, 'reps': 0},
      ]);
    });

    test('gli esercizi vengono salvati come sono', () {
      final original = _exercise(setsData: '[{"weight":40,"reps":10}]');

      final saved = _draft(exercises: [original]).exercisesToSave().single;

      expect(saved, original);
    });

    test('i pesi arrivano gia in chili e non vengono riconvertiti', () {
      // Chi compila la bozza lavora in libbre, ma converte prima di
      // consegnare: qui un peso e' gia' un peso in chili, sempre.
      final saved = _draft(
        exercises: [
          _exercise(
            weight: UnitConverter.lbToKg(100),
            setsData: '[{"weight":45.359,"reps":10}]',
          ),
        ],
      ).exercisesToSave().single;

      expect(saved.weight, closeTo(45.359, 0.001));
      expect(_sets(saved).single['weight'], closeTo(45.359, 0.001));
      expect(_sets(saved).single['reps'], 10);
    });
  });
}
