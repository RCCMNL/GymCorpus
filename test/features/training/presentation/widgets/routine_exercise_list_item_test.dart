import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_exercise_list_item.dart';

void main() {
  const squat = ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Gambe');

  RoutineExerciseEntity buildExercise({String? setsData}) {
    return RoutineExerciseEntity(
      id: 1,
      routineId: 1,
      exercise: squat,
      sets: 2,
      reps: 8,
      weight: 100,
      orderIndex: 0,
      setsData: setsData,
    );
  }

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra nome esercizio, muscolo e numero di serie parsate', (
    tester,
  ) async {
    final setsData = jsonEncode([
      {'weight': 100.0, 'reps': 8},
      {'weight': 95.0, 'reps': 6},
    ]);

    await tester.pumpWidget(
      wrap(
        RoutineExerciseListItem(
          exercise: buildExercise(setsData: setsData),
          isImperial: false,
          onEdit: () {},
          onRemove: () {},
          onDeleteRoutine: () {},
        ),
      ),
    );

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('GAMBE'), findsOneWidget);
    expect(find.text('2 SERIE'), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
    expect(find.text('95.0'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('mostra il peso in libbre quando isImperial e true', (
    tester,
  ) async {
    final setsData = jsonEncode([
      {'weight': 100.0, 'reps': 8},
    ]);

    await tester.pumpWidget(
      wrap(
        RoutineExerciseListItem(
          exercise: buildExercise(setsData: setsData),
          isImperial: true,
          onEdit: () {},
          onRemove: () {},
          onDeleteRoutine: () {},
        ),
      ),
    );

    // 100 kg convertiti in libbre.
    expect(find.text('220.5'), findsOneWidget);
  });

  testWidgets('0 SERIE quando setsData e assente', (tester) async {
    await tester.pumpWidget(
      wrap(
        RoutineExerciseListItem(
          exercise: buildExercise(),
          isImperial: false,
          onEdit: () {},
          onRemove: () {},
          onDeleteRoutine: () {},
        ),
      ),
    );

    expect(find.text('0 SERIE'), findsOneWidget);
  });

  testWidgets('il menu azioni invoca onEdit/onRemove/onDeleteRoutine', (
    tester,
  ) async {
    var edited = false;
    var removed = false;
    var deleted = false;

    await tester.pumpWidget(
      wrap(
        RoutineExerciseListItem(
          exercise: buildExercise(),
          isImperial: false,
          onEdit: () => edited = true,
          onRemove: () => removed = true,
          onDeleteRoutine: () => deleted = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica serie'));
    await tester.pumpAndSettle();
    expect(edited, isTrue);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rimuovi esercizio'));
    await tester.pumpAndSettle();
    expect(removed, isTrue);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina routine'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });

  testWidgets('il tap sul pulsante info apre il dialog delle note', (
    tester,
  ) async {
    const exerciseWithNotes = ExerciseEntity(
      id: 2,
      name: 'Stacco',
      targetMuscle: 'Schiena',
      userNotes: 'Schiena dritta',
    );

    await tester.pumpWidget(
      wrap(
        RoutineExerciseListItem(
          exercise: const RoutineExerciseEntity(
            id: 2,
            routineId: 1,
            exercise: exerciseWithNotes,
            sets: 3,
            reps: 5,
            weight: 120,
            orderIndex: 1,
          ),
          isImperial: false,
          onEdit: () {},
          onRemove: () {},
          onDeleteRoutine: () {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Le tue note'), findsOneWidget);
    expect(find.text('Schiena dritta'), findsOneWidget);
  });
}
