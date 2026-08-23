import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/weight_tracking_card.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc trainingBloc;
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(LoadExercisesEvent());
  });

  setUp(() {
    trainingBloc = MockTrainingBloc();
    authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.unauthenticated(),
    );
  });

  Widget wrap(TrainingState trainingState) {
    whenListen(
      trainingBloc,
      const Stream<TrainingState>.empty(),
      initialState: trainingState,
    );

    // I provider vanno sopra MaterialApp, non dentro home: showDialog usa di
    // default il root navigator, la cui subtree e' un sibling (non un
    // discendente) della route iniziale, quindi non vedrebbe un provider
    // annidato dentro home.
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrainingBloc>.value(value: trainingBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: const MaterialApp(home: Scaffold(body: WeightTrackingCard())),
    );
  }

  testWidgets('non mostra nulla mentre lo stato e in caricamento', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loading()));
    expect(find.text('Progresso Peso'), findsNothing);
  });

  testWidgets('senza log ne peso profilo mostra -- per le statistiche', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

    expect(find.text('Progresso Peso'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(3));
  });

  testWidgets('con i log mostra attuale/max/min corretti', (tester) async {
    final state = TrainingState.loaded(
      exercises: const [],
      settings: const {'units': 'KG'},
      bodyWeightLogs: [
        BodyWeightLogEntity(id: 1, weight: 78, date: DateTime(2026, 1, 10)),
        BodyWeightLogEntity(id: 2, weight: 82, date: DateTime(2026)),
        BodyWeightLogEntity(id: 3, weight: 76, date: DateTime(2026, 1, 5)),
      ],
    );

    await tester.pumpWidget(wrap(state));

    expect(find.text('78.0'), findsOneWidget); // Attuale = logs.first
    expect(find.text('82.0'), findsOneWidget); // Max
    expect(find.text('76.0'), findsOneWidget); // Min
  });

  testWidgets(
    'il tap sul pulsante + apre il dialog e invia AddBodyWeightLogEvent',
    (tester) async {
      await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Registra Peso'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '81.5');
      await tester.tap(find.text('Salva'));
      await tester.pump();

      final captured = verify(() => trainingBloc.add(captureAny())).captured;
      final event = captured.whereType<AddBodyWeightLogEvent>().single;
      expect(event.weight, 81.5);
    },
  );
}
