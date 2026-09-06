import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// L'ultima barriera tra un tocco e la perdita dell'account.
void main() {
  late _MockAuthRepository repository;
  final getIt = GetIt.instance;

  setUp(() {
    repository = _MockAuthRepository();
    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(repository);

    when(
      () => repository.deleteAccount(
        currentPassword: any(named: 'currentPassword'),
      ),
    ).thenAnswer((_) async => const Right(null));
  });

  tearDown(getIt.reset);

  Future<void> pump(
    WidgetTester tester, {
    required List<String> providers,
    VoidCallback? onDeleted,
    void Function(String)? onError,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeleteAccountDialog(
            authProviders: providers,
            onDeleted: onDeleted ?? () {},
            onError: onError ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('con account email chiede la password', (tester) async {
    await pump(tester, providers: const ['password']);

    expect(find.text('Password attuale'), findsOneWidget);
  });

  testWidgets('senza password non cancella e lo dice', (tester) async {
    await pump(tester, providers: const ['password']);

    await tester.tap(find.text('ELIMINA PERMANENTEMENTE'));
    await tester.pump();

    verifyNever(
      () => repository.deleteAccount(
        currentPassword: any(named: 'currentPassword'),
      ),
    );
    expect(find.textContaining('Inserisci la password'), findsOneWidget);
  });

  testWidgets('con la password inserita procede', (tester) async {
    var deleted = 0;
    await pump(
      tester,
      providers: const ['password'],
      onDeleted: () => deleted++,
    );

    await tester.enterText(find.byType(TextField), 'segreta');
    await tester.tap(find.text('ELIMINA PERMANENTEMENTE'));
    await tester.pumpAndSettle();

    verify(
      () => repository.deleteAccount(currentPassword: 'segreta'),
    ).called(1);
    expect(deleted, 1);
  });

  testWidgets('con un provider esterno non chiede nessuna password', (
    tester,
  ) async {
    await pump(tester, providers: const ['google.com']);

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('ELIMINA PERMANENTEMENTE'));
    await tester.pumpAndSettle();

    verify(() => repository.deleteAccount()).called(1);
  });

  testWidgets('un errore viene riportato a chi ha aperto il dialogo', (
    tester,
  ) async {
    String? error;
    when(
      () => repository.deleteAccount(
        currentPassword: any(named: 'currentPassword'),
      ),
    ).thenAnswer((_) async => const Left(AuthFailure('sessione scaduta')));

    await pump(
      tester,
      providers: const ['google.com'],
      onError: (message) => error = message,
    );

    await tester.tap(find.text('ELIMINA PERMANENTEMENTE'));
    await tester.pumpAndSettle();

    expect(error, 'sessione scaduta');
  });

  testWidgets('annullare non cancella niente', (tester) async {
    await pump(tester, providers: const ['password']);

    await tester.tap(find.text('ANNULLA'));
    await tester.pumpAndSettle();

    verifyNever(
      () => repository.deleteAccount(
        currentPassword: any(named: 'currentPassword'),
      ),
    );
  });
}
