import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/exercise_set.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/selected_exercise_tile.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

  const squat = ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Gambe');

  setUp(() {
    bloc = MockTrainingBloc();
    whenListen(
      bloc,
      const Stream<TrainingState>.empty(),
      initialState: const TrainingState.loaded(exercises: []),
    );
  });

  RoutineExerciseEntity buildExercise({String? setsData}) {
    return RoutineExerciseEntity(
      id: 1,
      routineId: 1,
      exercise: squat,
      sets: 1,
      reps: 8,
      weight: 100,
      orderIndex: 0,
      setsData: setsData,
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      home: BlocProvider<TrainingBloc>.value(
        value: bloc,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('e collassato di default: mostra nome e conteggio serie', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SelectedExerciseTile(
          exercise: buildExercise(),
          onRemove: () {},
          onSetsUpdated: (_) {},
          index: 0,
        ),
      ),
    );

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('1 serie'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets("il tap sull'header espande e mostra i campi delle serie", (
    tester,
  ) async {
    final setsData = jsonEncode([
      {'weight': 100.0, 'reps': 8},
    ]);

    await tester.pumpWidget(
      wrap(
        SelectedExerciseTile(
          exercise: buildExercise(setsData: setsData),
          onRemove: () {},
          onSetsUpdated: (_) {},
          index: 0,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pump();

    expect(find.byType(TextField), findsWidgets);
    expect(find.text('AGGIUNGI UNA SERIE'), findsOneWidget);
  });

  testWidgets("aggiungere una serie duplica peso e reps dell'ultima e "
      'notifica onSetsUpdated', (tester) async {
    final setsData = jsonEncode([
      {'weight': 100.0, 'reps': 8},
    ]);
    List<ExerciseSet>? updated;

    await tester.pumpWidget(
      wrap(
        SelectedExerciseTile(
          exercise: buildExercise(setsData: setsData),
          onRemove: () {},
          onSetsUpdated: (sets) => updated = sets,
          index: 0,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pump();
    await tester.tap(find.text('AGGIUNGI UNA SERIE'));
    await tester.pump();

    expect(find.text('2 serie'), findsOneWidget);
    expect(updated, isNotNull);
    expect(updated!.length, 2);
    expect(updated![1].weight, 100.0);
    expect(updated![1].reps, 8);
  });

  testWidgets("non si puo rimuovere l'ultima serie rimasta", (tester) async {
    final setsData = jsonEncode([
      {'weight': 100.0, 'reps': 8},
    ]);

    await tester.pumpWidget(
      wrap(
        SelectedExerciseTile(
          exercise: buildExercise(setsData: setsData),
          onRemove: () {},
          onSetsUpdated: (_) {},
          index: 0,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.text('1 serie'), findsOneWidget);
  });

  testWidgets("il tap sull'icona cestino invoca onRemove", (tester) async {
    var removed = false;

    await tester.pumpWidget(
      wrap(
        SelectedExerciseTile(
          exercise: buildExercise(),
          onRemove: () => removed = true,
          onSetsUpdated: (_) {},
          index: 0,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(removed, isTrue);
  });

  testWidgets('esercizi a corpo libero mostrano solo il campo reps', (
    tester,
  ) async {
    const bodyweight = ExerciseEntity(
      id: 2,
      name: 'Push-up',
      targetMuscle: 'Petto',
      isBodyweight: true,
    );
    final exercise = RoutineExerciseEntity(
      id: 2,
      routineId: 1,
      exercise: bodyweight,
      sets: 1,
      reps: 12,
      weight: 0,
      orderIndex: 0,
      setsData: jsonEncode([
        {'weight': 0.0, 'reps': 12},
      ]),
    );

    await tester.pumpWidget(
      wrap(
        SelectedExerciseTile(
          exercise: exercise,
          onRemove: () {},
          onSetsUpdated: (_) {},
          index: 0,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pump();

    // Un solo campo (REPS), niente campo PESO/KG.
    expect(find.byType(TextField), findsOneWidget);
  });
}
