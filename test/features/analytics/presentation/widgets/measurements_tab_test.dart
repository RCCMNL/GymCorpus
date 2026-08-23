import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/measurements_tab.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

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

  // I provider vanno sopra MaterialApp: i fogli modali aperti da questo tab
  // usano il root navigator e non vedrebbero un provider annidato in home.
  Widget wrap({required List<BodyMeasurementEntity> measurements}) {
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: MaterialApp(
        home: Scaffold(
          body: MeasurementsTab(
            measurements: measurements,
            logs: const [],
            settings: const {},
            hero: const SizedBox(key: Key('hero')),
          ),
        ),
      ),
    );
  }

  testWidgets("mostra l'hero, lo stato vuoto e la card dei consigli", (
    tester,
  ) async {
    await tester.pumpWidget(wrap(measurements: const []));

    expect(find.byKey(const Key('hero')), findsOneWidget);
    expect(find.text('Nessuna misura salvata'), findsOneWidget);
    expect(find.text('Buone pratiche'), findsOneWidget);
  });

  testWidgets('con misure mostra il conteggio delle aree monitorate', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        measurements: [
          BodyMeasurementEntity(
            id: 1,
            part: 'Petto',
            value: 100,
            date: DateTime(2026, 1, 5, 8),
          ),
        ],
      ),
    );

    expect(find.text('1 aree monitorate'), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
  });

  testWidgets('aggiungere un check-in invia AddMultipleBodyMeasurementsEvent', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(measurements: const []));

    await tester.tap(find.text('Check-in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '95');
    // Il pulsante e' sotto gli 8 campi misura: va scrollato in vista prima
    // che lo sliver lo materializzi nell'albero.
    await tester.scrollUntilVisible(
      find.text('Salva Check-in'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Salva Check-in'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<AddMultipleBodyMeasurementsEvent>().single;
    expect(event.measurements['Petto'], 95.0);
  });

  testWidgets(
    'il tap su una misura esistente invia UpdateBodyMeasurementEvent',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          measurements: [
            BodyMeasurementEntity(
              id: 7,
              part: 'Vita',
              value: 80,
              date: DateTime(2026, 1, 5, 8),
            ),
          ],
        ),
      );

      await tester.tap(find.text('80.0'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '78.5');
      await tester.tap(find.text('Aggiorna'));
      await tester.pump();

      final captured = verify(() => bloc.add(captureAny())).captured;
      final event = captured.whereType<UpdateBodyMeasurementEvent>().single;
      expect(event.id, 7);
      expect(event.value, 78.5);
    },
  );
}
