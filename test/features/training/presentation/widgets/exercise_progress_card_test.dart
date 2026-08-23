import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/widgets/exercise_progress_card.dart';

void main() {
  const barbellExercise = ExerciseEntity(
    id: 1,
    name: 'Panca piana',
    targetMuscle: 'Petto',
  );
  const bodyweightExercise = ExerciseEntity(
    id: 2,
    name: 'Push-up',
    targetMuscle: 'Petto',
    isBodyweight: true,
  );

  RoutineExerciseEntity buildRoutineExercise(
    ExerciseEntity exercise, {
    double weight = 80,
    int reps = 10,
  }) {
    return RoutineExerciseEntity(
      id: 1,
      routineId: 1,
      exercise: exercise,
      sets: 3,
      reps: reps,
      weight: weight,
      orderIndex: 0,
    );
  }

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra nome esercizio, contatore serie, reps e peso', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ExerciseProgressCard(
          exercise: buildRoutineExercise(barbellExercise),
          setIndex: 1,
          totalSets: 3,
          unit: WeightUnit.kg,
        ),
      ),
    );

    expect(find.text('Panca piana'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('80.0 kg'), findsOneWidget);
  });

  testWidgets('non mostra il chip peso per esercizi a corpo libero', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ExerciseProgressCard(
          exercise: buildRoutineExercise(bodyweightExercise, weight: 0),
          setIndex: 0,
          totalSets: 3,
          unit: WeightUnit.kg,
        ),
      ),
    );

    expect(find.text('PESO'), findsNothing);
    expect(find.text('RIPETIZIONI'), findsOneWidget);
  });

  testWidgets('il tap sul pulsante info apre il dialog delle note', (
    tester,
  ) async {
    const exerciseWithNotes = ExerciseEntity(
      id: 3,
      name: 'Squat',
      targetMuscle: 'Gambe',
      userNotes: 'Scendere lentamente',
    );

    await tester.pumpWidget(
      wrap(
        ExerciseProgressCard(
          exercise: buildRoutineExercise(exerciseWithNotes),
          setIndex: 0,
          totalSets: 3,
          unit: WeightUnit.kg,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text('Le tue note'), findsOneWidget);
    expect(find.text('Scendere lentamente'), findsOneWidget);
  });
}
