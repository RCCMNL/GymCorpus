import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/quick_exercise_edit_panel.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

  const squat = ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Gambe');

  setUpAll(() {
    registerFallbackValue(LoadExercisesEvent());
  });

  setUp(() {
    bloc = MockTrainingBloc();
    whenListen(
      bloc,
      const Stream<TrainingState>.empty(),
      initialState: const TrainingState.loaded(exercises: []),
    );
  });

  RoutineExerciseEntity buildExercise() {
    return RoutineExerciseEntity(
      id: 5,
      routineId: 9,
      exercise: squat,
      sets: 1,
      reps: 8,
      weight: 100,
      orderIndex: 0,
      setsData: jsonEncode([
        {'weight': 100.0, 'reps': 8},
      ]),
    );
  }

  final routine = RoutineEntity(
    id: 9,
    title: 'Leg Day',
    createdAt: DateTime(2026),
    exercises: [buildExercise()],
  );

  Widget wrap(Widget child) {
    return MaterialApp(
      home: BlocProvider<TrainingBloc>.value(
        value: bloc,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('mostra il nome esercizio e i valori pre-compilati', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(QuickExerciseEditPanel(re: buildExercise(), routine: routine)),
    );

    expect(find.text('SQUAT'), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets("aggiungere una serie duplica peso e reps dell'ultima", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(QuickExerciseEditPanel(re: buildExercise(), routine: routine)),
    );

    await tester.tap(find.text('AGGIUNGI SERIE'));
    await tester.pump();

    expect(find.text('100.0'), findsNWidgets(2));
  });

  testWidgets("non si puo rimuovere l'ultima serie rimasta", (tester) async {
    await tester.pumpWidget(
      wrap(QuickExerciseEditPanel(re: buildExercise(), routine: routine)),
    );

    await tester.tap(find.byIcon(Icons.remove_circle_outline_rounded));
    await tester.pump();

    // Il campo peso della serie unica e ancora presente.
    expect(find.text('100.0'), findsOneWidget);
  });

  testWidgets('il salvataggio invia UpdateRoutineEvent e mostra la conferma', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(QuickExerciseEditPanel(re: buildExercise(), routine: routine)),
    );

    await tester.tap(find.text('SALVA MODIFICHE'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(captured, hasLength(1));
    final event = captured.first as UpdateRoutineEvent;
    expect(event.id, 9);
    expect(event.title, 'Leg Day');
    expect(event.exercises.single.weight, 100.0);
    expect(event.exercises.single.reps, 8);

    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Salvataggio completato!'), findsOneWidget);
  });
}
