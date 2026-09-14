import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/screens/profile_onboarding_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_bloc.dart';

/// La schermata che chiude il buco del primo accesso: chi entra con Google
/// non ha genere ne data di nascita, e prima poteva usare l'app con un
/// profilo a meta senza che nessuno glielo chiedesse piu.
void main() {
  late MockAuthBloc authBloc;

  /// Il profilo tipico appena creato con Google: nome dall'account, il
  /// resto vuoto.
  const googleUser = UserEntity(
    id: '1',
    email: 'mario@example.com',
    firstName: 'Mario',
    lastName: 'Rossi',
  );

  setUpAll(() {
    registerFallbackValue(const AuthEvent.logoutRequested());
  });

  setUp(() {
    authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.authenticated(googleUser),
    );
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: ProfileOnboardingScreen()),
      ),
    );
  }

  testWidgets('precompila i dati che l account ha gia fornito', (tester) async {
    await pump(tester);

    expect(find.text('Mario'), findsOneWidget);
    expect(find.text('Rossi'), findsOneWidget);
  });

  testWidgets('non si entra nell app senza aver scelto il genere', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField).at(2), 'mario');
    await tester.tap(find.byKey(const Key('profile-birthdate')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONTINUA'));
    await tester.pump();

    verifyNever(() => authBloc.add(any()));
    expect(find.textContaining('genere'), findsOneWidget);
  });

  /// Compila e conferma il primo passo, quello obbligatorio.
  Future<void> fillBasics(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(2), 'mario');

    await tester.tap(find.byKey(const Key('profile-gender')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Donna').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-birthdate')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONTINUA'));
    await tester.pumpAndSettle();
  }

  testWidgets('dopo i dati di base chiede peso e altezza, che sono opzionali', (
    tester,
  ) async {
    await pump(tester);
    await fillBasics(tester);

    expect(find.byKey(const Key('profile-weight')), findsOneWidget);
    expect(find.text('Lo faccio dopo'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('con il form compilato salva il profilo', (tester) async {
    await pump(tester);
    await fillBasics(tester);

    await tester.tap(find.text('Lo faccio dopo'));
    await tester.pump();

    final captured = verify(() => authBloc.add(captureAny())).captured;
    final event = captured.whereType<AuthEvent>().last;

    event.maybeWhen(
      updateProfileRequested:
          (firstName, lastName, username, gender, _, __, birthDate, ___) {
            expect(firstName, 'Mario');
            expect(lastName, 'Rossi');
            expect(username, 'mario');
            expect(gender, 'Donna');
            expect(birthDate, isNotNull);
          },
      orElse: () => fail('atteso updateProfileRequested, ricevuto $event'),
    );
  });

  testWidgets('si puo solo uscire, non saltare', (tester) async {
    await pump(tester);

    expect(find.text('Esci'), findsOneWidget);
    expect(find.textContaining('Salta'), findsNothing);

    await tester.tap(find.text('Esci'));
    await tester.pump();

    verify(() => authBloc.add(const AuthEvent.logoutRequested())).called(1);
  });

  testWidgets('il tasto indietro non riporta nell app', (tester) async {
    await pump(tester);

    final popScope = tester.widget<PopScope<dynamic>>(
      find.byType(PopScope<dynamic>),
    );
    expect(popScope.canPop, isFalse);
  });

  testWidgets('un salvataggio fallito viene detto, non ingoiato', (
    tester,
  ) async {
    // Dietro un cancello che blocca l'ingresso, un errore muto diventa un
    // pulsante che non risponde.
    whenListen(
      authBloc,
      Stream<AuthState>.fromIterable([
        const AuthState.authenticated(googleUser, actionError: 'rete assente'),
      ]),
      initialState: const AuthState.authenticated(googleUser),
    );

    await pump(tester);
    await tester.pump();

    expect(find.text('rete assente'), findsOneWidget);
  });

  testWidgets('peso e altezza inseriti finiscono nel profilo', (tester) async {
    await pump(tester);
    await fillBasics(tester);

    await tester.enterText(find.byKey(const Key('profile-weight')), '72,5');
    await tester.enterText(find.byKey(const Key('profile-height')), '178');
    await tester.tap(find.text('ENTRA IN GYMCORPUS'));
    await tester.pump();

    final captured = verify(() => authBloc.add(captureAny())).captured;
    final event = captured.whereType<AuthEvent>().last;

    event.maybeWhen(
      updateProfileRequested:
          (_, __, ___, ____, weight, height, _____, ______) {
            expect(weight, 72.5);
            expect(height, 178);
          },
      orElse: () => fail('atteso updateProfileRequested, ricevuto $event'),
    );
  });
}
