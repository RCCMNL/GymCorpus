import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/widgets/next_up_card.dart';

void main() {
  const squat = ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Gambe');
  const bench = ExerciseEntity(
    id: 2,
    name: 'Panca piana',
    targetMuscle: 'Petto',
  );

  const squatRoutine = RoutineExerciseEntity(
    id: 1,
    routineId: 1,
    exercise: squat,
    sets: 3,
    reps: 8,
    weight: 100,
    orderIndex: 0,
  );
  const benchRoutine = RoutineExerciseEntity(
    id: 2,
    routineId: 1,
    exercise: bench,
    sets: 4,
    reps: 10,
    weight: 60,
    orderIndex: 1,
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra la prossima serie dello stesso esercizio', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const NextUpCard(
          isLastSet: false,
          currentExercise: squatRoutine,
          nextExercise: benchRoutine,
          setIndex: 0,
          totalSets: 3,
          unit: WeightUnit.kg,
          accent: Colors.blue,
        ),
      ),
    );

    expect(find.text('Squat'), findsOneWidget);
    expect(find.textContaining('Prossima:'), findsOneWidget);
    expect(find.textContaining('Serie 2 di 3'), findsOneWidget);
  });

  testWidgets('mostra il prossimo esercizio quando e finita la serie', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const NextUpCard(
          isLastSet: true,
          currentExercise: squatRoutine,
          nextExercise: benchRoutine,
          setIndex: 2,
          totalSets: 3,
          unit: WeightUnit.kg,
          accent: Colors.blue,
        ),
      ),
    );

    expect(find.text('Panca piana'), findsOneWidget);
    expect(find.textContaining('Inizio:'), findsOneWidget);
    expect(find.textContaining('4 serie totali'), findsOneWidget);
  });

  testWidgets('mostra il messaggio di ultimo esercizio quando non ce un '
      'esercizio successivo', (tester) async {
    await tester.pumpWidget(
      wrap(
        const NextUpCard(
          isLastSet: true,
          currentExercise: benchRoutine,
          nextExercise: null,
          setIndex: 3,
          totalSets: 4,
          unit: WeightUnit.kg,
          accent: Colors.blue,
        ),
      ),
    );

    expect(find.text('Ultimo esercizio!'), findsOneWidget);
    expect(find.text('Dopo questa serie hai finito'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });
}
