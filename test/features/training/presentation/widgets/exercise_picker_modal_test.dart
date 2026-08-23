import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/exercise_picker_modal.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

  const squat = ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Gambe');
  const bench = ExerciseEntity(
    id: 2,
    name: 'Panca piana',
    targetMuscle: 'Petto',
  );

  setUp(() {
    bloc = MockTrainingBloc();
  });

  Widget buildModal({
    List<ExerciseEntity> alreadySelected = const [],
    void Function(List<ExerciseEntity>)? onConfirm,
  }) {
    whenListen(
      bloc,
      const Stream<TrainingState>.empty(),
      initialState: const TrainingState.loaded(exercises: [squat, bench]),
    );

    return MaterialApp(
      home: BlocProvider<TrainingBloc>.value(
        value: bloc,
        child: Scaffold(
          body: ExercisePickerModal(
            onConfirm: onConfirm ?? (_) {},
            alreadySelected: alreadySelected,
          ),
        ),
      ),
    );
  }

  testWidgets('mostra tutti gli esercizi caricati', (tester) async {
    await tester.pumpWidget(buildModal());
    await tester.pump();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Panca piana'), findsOneWidget);
  });

  testWidgets('la ricerca filtra la lista per nome', (tester) async {
    await tester.pumpWidget(buildModal());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'squat');
    await tester.pump();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Panca piana'), findsNothing);
  });

  testWidgets(
    'mostra GIÀ AGGIUNTO per esercizi gia selezionati e blocca il tap',
    (tester) async {
      await tester.pumpWidget(buildModal(alreadySelected: const [squat]));
      await tester.pump();

      expect(find.text('GIÀ AGGIUNTO'), findsOneWidget);
    },
  );

  testWidgets('selezionando un esercizio compare il pulsante di conferma', (
    tester,
  ) async {
    await tester.pumpWidget(buildModal());
    await tester.pump();

    expect(find.textContaining('AGGIUNGI'), findsNothing);

    await tester.tap(find.text('Squat'));
    await tester.pump();

    expect(find.text('AGGIUNGI 1 ESERCIZI'), findsOneWidget);
  });

  testWidgets('conferma invoca onConfirm con gli esercizi selezionati', (
    tester,
  ) async {
    List<ExerciseEntity>? confirmed;
    await tester.pumpWidget(buildModal(onConfirm: (list) => confirmed = list));
    await tester.pump();

    await tester.tap(find.text('Squat'));
    await tester.pump();
    await tester.tap(find.text('AGGIUNGI 1 ESERCIZI'));
    await tester.pump();

    expect(confirmed, [squat]);
  });
}
