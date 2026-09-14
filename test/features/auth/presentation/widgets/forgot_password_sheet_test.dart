import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_bloc.dart';

void main() {
  late MockAuthBloc bloc;

  setUpAll(() {
    registerFallbackValue(const AuthEvent.checkSessionRequested());
  });

  setUp(() {
    bloc = MockAuthBloc();
    whenListen(
      bloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.unauthenticated(),
    );
  });

  tearDown(() => bloc.close());

  Future<void> pump(WidgetTester tester, {String initialEmail = ''}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: Scaffold(
            body: ForgotPasswordSheet(initialEmail: initialEmail),
          ),
        ),
      ),
    );
  }

  testWidgets('parte dall email gia scritta nel login', (tester) async {
    await pump(tester, initialEmail: 'utente@esempio.com');

    expect(find.text('utente@esempio.com'), findsOneWidget);
  });

  testWidgets('un email senza chiocciola non invia niente', (tester) async {
    await pump(tester, initialEmail: 'non-e-una-email');

    await tester.tap(find.text('INVIA LINK DI RECUPERO'));
    await tester.pump();

    verifyNever(() => bloc.add(any()));
    expect(find.textContaining("Inserisci un'email valida"), findsOneWidget);
  });

  testWidgets('un email valida chiede il link di recupero', (tester) async {
    await pump(tester, initialEmail: 'utente@esempio.com');

    await tester.tap(find.text('INVIA LINK DI RECUPERO'));
    await tester.pump();

    final captured = verify(() => bloc.add(captureAny())).captured;
    expect(
      captured.single,
      const AuthEvent.forgotPasswordRequested(email: 'utente@esempio.com'),
    );
  });
}
