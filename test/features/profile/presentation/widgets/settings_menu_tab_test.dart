import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/settings_menu_tab.dart';
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
    registerFallbackValue(const AuthEvent.logoutRequested());
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

  // Provider sopra MaterialApp.router: i fogli aperti da questo tab (timer,
  // unita' di misura) usano il root navigator e non vedrebbero un provider
  // annidato in home.
  Widget wrap(TrainingState trainingState) {
    whenListen(
      trainingBloc,
      const Stream<TrainingState>.empty(),
      initialState: trainingState,
    );

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(
              child: SettingsMenuTab(trainingState: trainingState),
            ),
          ),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Modifica Profilo'))),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<TrainingBloc>.value(value: trainingBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('mostra le sezioni principali e i valori correnti', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const TrainingState.loaded(
          exercises: [],
          settings: {'rest_timer': '120', 'units': 'LB'},
        ),
      ),
    );

    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('IMPOSTAZIONI ALLENAMENTO'), findsOneWidget);
    expect(find.text('PREFERENZE APP'), findsOneWidget);
    expect(find.text('COMMUNITY & FEEDBACK'), findsOneWidget);
    expect(find.text('120s'), findsOneWidget);
    expect(find.text('Lb / inch'), findsOneWidget);
  });

  testWidgets('attivare Effetti Audio invia UpdatePreferenceEvent', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    final captured = verify(() => trainingBloc.add(captureAny())).captured;
    final event = captured.whereType<UpdatePreferenceEvent>().single;
    expect(event.key, 'audio_effects');
    expect(event.value, 'true');
  });

  testWidgets('il tap sul timer di recupero apre il relativo foglio', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

    await tester.tap(find.text('Timer di Recupero'));
    await tester.pumpAndSettle();

    expect(find.text('PAUSA TRA LE SERIE'), findsOneWidget);
  });

  testWidgets("il tap sull'unita di misura apre il relativo foglio", (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

    await tester.tap(find.text('Unità di Misura'));
    await tester.pumpAndSettle();

    expect(find.text('SISTEMA METRICO O IMPERIALE'), findsOneWidget);
  });

  testWidgets('il tap su disconnetti invia AuthEvent.logoutRequested', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

    await tester.ensureVisible(find.text('DISCONNETTI ACCOUNT'));
    await tester.tap(find.text('DISCONNETTI ACCOUNT'));
    await tester.pump();

    verify(() => authBloc.add(const AuthEvent.logoutRequested())).called(1);
  });
}
