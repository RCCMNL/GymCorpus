import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  final getIt = GetIt.instance;

  setUp(() {
    repository = MockAuthRepository();

    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(repository);

    when(() => repository.isBiometricEnabled()).thenAnswer((_) async => false);
    when(
      () => repository.signInWithGoogle(
        acceptedTerms: any(named: 'acceptedTerms'),
        acceptedPrivacy: any(named: 'acceptedPrivacy'),
        marketingConsent: any(named: 'marketingConsent'),
        profilingConsent: any(named: 'profilingConsent'),
      ),
    ).thenAnswer(
      (_) async => const Left(
        ServerFailure(
          'Questo account Google non e ancora registrato. '
          'Crea prima un account dalla schermata Registrati.',
        ),
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => BlocProvider(
            create: (_) => AuthBloc(repository),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, __) => BlocProvider(
            create: (_) => AuthBloc(repository),
            child: const SignUpScreen(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('mostra una CTA Google esplicita e un aiuto per il primo accesso',
        (tester) async {
      await pumpScreen(tester);

      expect(find.text('Accedi con Google'), findsOneWidget);
      expect(
        find.text(
          'Primo accesso? Se non hai ancora un account, usa "Registrati" qui sotto.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'porta alla registrazione se Google login viene usato con un account nuovo',
        (tester) async {
      await pumpScreen(tester);

      await tester.ensureVisible(find.text('Accedi con Google'));
      await tester.tap(find.text('Accedi con Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pumpAndSettle();

      expect(find.text('Crea il tuo account'), findsOneWidget);
    });
  });
}
