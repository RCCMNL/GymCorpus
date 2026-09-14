import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Su iOS offrire Google senza un'alternativa equivalente e' un motivo di
/// rifiuto in App Store: il supporto ad Apple esisteva gia' nel repository,
/// ma non c'era modo di usarlo.
void main() {
  late _MockAuthRepository repository;
  final getIt = GetIt.instance;

  setUp(() {
    repository = _MockAuthRepository();

    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(repository);

    when(() => repository.isBiometricEnabled()).thenAnswer((_) async => false);
    when(
      () => repository.signInWithApple(
        acceptedTerms: any(named: 'acceptedTerms'),
        acceptedPrivacy: any(named: 'acceptedPrivacy'),
        marketingConsent: any(named: 'marketingConsent'),
        profilingConsent: any(named: 'profilingConsent'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('accesso annullato')));
  });

  Future<void> pumpLogin(WidgetTester tester, TargetPlatform platform) async {
    debugDefaultTargetPlatformOverride = platform;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(repository),
          child: const LoginScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('su iOS compare l accesso con Apple', (tester) async {
    await pumpLogin(tester, TargetPlatform.iOS);

    expect(find.text('Accedi con Apple'), findsOneWidget);
    expect(find.text('Accedi con Google'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('su Android resta il solo accesso con Google', (tester) async {
    await pumpLogin(tester, TargetPlatform.android);

    expect(find.text('Accedi con Apple'), findsNothing);
    expect(find.text('Accedi con Google'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('il tap avvia l accesso con Apple', (tester) async {
    await pumpLogin(tester, TargetPlatform.iOS);

    await tester.ensureVisible(find.text('Accedi con Apple'));
    await tester.tap(find.text('Accedi con Apple'));
    await tester.pump();

    verify(
      () => repository.signInWithApple(
        acceptedTerms: any(named: 'acceptedTerms'),
        acceptedPrivacy: any(named: 'acceptedPrivacy'),
        marketingConsent: any(named: 'marketingConsent'),
        profilingConsent: any(named: 'profilingConsent'),
      ),
    ).called(1);

    debugDefaultTargetPlatformOverride = null;
  });
}
