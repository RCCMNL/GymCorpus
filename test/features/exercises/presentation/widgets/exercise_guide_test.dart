import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_guide.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

  setUp(() {
    bloc = MockTrainingBloc();
    whenListen(
      bloc,
      const Stream<TrainingState>.empty(),
      initialState: const TrainingState.loaded(exercises: []),
    );
  });

  tearDown(() => bloc.close());

  Future<void> pump(WidgetTester tester, ExerciseEntity exercise) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider<TrainingBloc>.value(
          value: bloc,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ExerciseGuide(exercise: exercise),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('divide l esecuzione in salita e discesa', (tester) async {
    await pump(
      tester,
      const ExerciseEntity(
        id: 1,
        name: 'Panca piana',
        targetMuscle: 'Petto',
        execution: 'Abbassa il bilanciere al petto. Spingi verso l alto.',
      ),
    );

    expect(find.text('Abbassa il bilanciere al petto.'), findsOneWidget);
    expect(find.text('Spingi verso l alto.'), findsOneWidget);
  });

  testWidgets('senza indicazioni lo dice, invece di descrivere un crunch', (
    tester,
  ) async {
    await pump(
      tester,
      const ExerciseEntity(id: 1, name: 'Panca piana', targetMuscle: 'Petto'),
    );

    expect(find.textContaining('addominali'), findsNothing);
    expect(
      find.text('Nessuna indicazione salvata per questo esercizio.'),
      findsWidgets,
    );
  });

  testWidgets('attrezzatura e area focus arrivano dall esercizio', (
    tester,
  ) async {
    await pump(
      tester,
      const ExerciseEntity(
        id: 1,
        name: 'Panca piana',
        targetMuscle: 'Petto',
        equipment: 'Bilanciere',
        focusArea: 'Pettorali',
      ),
    );

    expect(find.text('Bilanciere'), findsOneWidget);
    expect(find.text('Pettorali'), findsOneWidget);
  });
}
