import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Il foglio del cambio password, estratto da SecurityScreen. Qui conta che
/// non chiami il repository a vuoto e che dica come e' andata.
void main() {
  late _MockAuthRepository repository;
  final getIt = GetIt.instance;

  setUp(() {
    repository = _MockAuthRepository();
    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(repository);
  });

  tearDown(getIt.reset);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChangePasswordSheet())),
    );
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'vecchia');
    await tester.enterText(find.byType(TextField).at(1), 'nuovissima');
  }

  testWidgets('con i campi vuoti non chiama il repository', (tester) async {
    await pump(tester);

    await tester.tap(find.text('AGGIORNA PASSWORD'));
    await tester.pump();

    verifyNever(() => repository.changePassword(any(), any()));
  });

  testWidgets('invia le due password inserite', (tester) async {
    when(
      () => repository.changePassword(any(), any()),
    ).thenAnswer((_) async => const Right(null));

    await pump(tester);
    await fill(tester);
    await tester.tap(find.text('AGGIORNA PASSWORD'));
    await tester.pump();

    verify(() => repository.changePassword('vecchia', 'nuovissima')).called(1);
  });

  testWidgets('un errore resta visibile e il foglio non si chiude', (
    tester,
  ) async {
    when(() => repository.changePassword(any(), any())).thenAnswer(
      (_) async =>
          const Left(AuthFailure('La password inserita non e corretta.')),
    );

    await pump(tester);
    await fill(tester);
    await tester.tap(find.text('AGGIORNA PASSWORD'));
    await tester.pump();

    expect(find.text('La password inserita non e corretta.'), findsOneWidget);
    expect(find.byType(ChangePasswordSheet), findsOneWidget);
  });

  testWidgets('la password si puo rendere leggibile', (tester) async {
    await pump(tester);

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_rounded).first);
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).obscureText,
      isFalse,
    );
  });
}
