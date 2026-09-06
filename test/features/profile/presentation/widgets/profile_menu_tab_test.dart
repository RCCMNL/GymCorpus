import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_menu_tab.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockAuthBloc authBloc;
  late MockTrainingBloc trainingBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    trainingBloc = MockTrainingBloc();
    when(() => trainingBloc.state).thenReturn(
      const TrainingState.loaded(exercises: []),
    );
  });

  /// Le preferenze arrivano dallo stato di allenamento, dove vivono tutte
  /// le impostazioni dell'app.
  void withSettings(Map<String, String> settings) {
    when(() => trainingBloc.state).thenReturn(
      TrainingState.loaded(exercises: const [], settings: settings),
    );
  }

  /// Il calendario ciclo e' l'unica voce del menu legata al profilo: viene
  /// mostrata solo a chi ha indicato "Donna" come sesso.
  void withGender(String? gender) {
    when(() => authBloc.state).thenReturn(
      AuthState.authenticated(
        UserEntity(id: '1', email: 'a@a.com', gender: gender),
      ),
    );
  }

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(child: ProfileMenuTab()),
          ),
        ),
        GoRoute(
          path: '/profile/records',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Schermata Record'))),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<TrainingBloc>.value(value: trainingBloc),
      ],

      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('mostra le sezioni e le voci del menu', (tester) async {
    withGender('Uomo');
    await tester.pumpWidget(wrap());

    expect(find.text('COMMUNITY & GAMIFICATION'), findsOneWidget);
    expect(find.text('PERFORMANCE & DATI'), findsOneWidget);
    expect(find.text('ALLENAMENTO'), findsOneWidget);
    expect(find.text('PALESTRA'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Progressi'), findsOneWidget);
  });

  testWidgets(
    'le voci non ancora implementate mostrano il badge Prossimamente',
    (tester) async {
      withGender('Uomo');
      await tester.pumpWidget(wrap());

      expect(find.text('Classifica Utenti'), findsOneWidget);
      expect(find.text('Prossimamente'), findsWidgets);
    },
  );

  testWidgets('il tap su Record naviga a /profile/records', (tester) async {
    withGender('Uomo');
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();

    expect(find.text('Schermata Record'), findsOneWidget);
  });

  group('calendario ciclo', () {
    testWidgets('compare per un profilo femminile', (tester) async {
      withGender('Donna');
      await tester.pumpWidget(wrap());

      expect(find.text('Calendario ciclo'), findsOneWidget);
    });

    testWidgets('non compare per gli altri profili', (tester) async {
      withGender('Uomo');
      await tester.pumpWidget(wrap());

      expect(find.text('Calendario ciclo'), findsNothing);
    });

    testWidgets('non compare se il sesso non e stato indicato', (tester) async {
      // Chi entra con Google o Apple non ha il campo valorizzato.
      withGender(null);
      await tester.pumpWidget(wrap());

      expect(find.text('Calendario ciclo'), findsNothing);
    });

    testWidgets('non mostra piu il badge BETA', (tester) async {
      withGender('Donna');
      await tester.pumpWidget(wrap());

      expect(find.text('BETA'), findsNothing);
    });
  });

  group('interruttore del calendario ciclo', () {
    testWidgets('acceso, la voce compare anche per gli altri profili', (
      tester,
    ) async {
      // Chi indica "Altro" resterebbe altrimenti tagliato fuori per sempre.
      withGender('Altro');
      withSettings(const {'cycle_calendar_enabled': 'true'});
      await tester.pumpWidget(wrap());

      expect(find.text('Calendario ciclo'), findsOneWidget);
    });

    testWidgets('spento, la voce sparisce anche per i profili femminili', (
      tester,
    ) async {
      withGender('Donna');
      withSettings(const {'cycle_calendar_enabled': 'false'});
      await tester.pumpWidget(wrap());

      expect(find.text('Calendario ciclo'), findsNothing);
    });
  });
}
