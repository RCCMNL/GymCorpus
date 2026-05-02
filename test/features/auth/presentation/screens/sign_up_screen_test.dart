import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(repository),
          child: const SignUpScreen(),
        ),
      ),
    );
  }

  Future<void> goToProfileStep(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'mario@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.ensureVisible(find.text('CONTINUA'));
    await tester.tap(find.text('CONTINUA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('SignUpScreen', () {
    testWidgets('mostra i campi profilo richiesti', (tester) async {
      await pumpScreen(tester);
      await goToProfileStep(tester);

      expect(find.text('NOME'), findsOneWidget);
      expect(find.text('COGNOME'), findsOneWidget);
      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('DATA DI NASCITA'), findsOneWidget);
      expect(find.text('GENERE'), findsOneWidget);
      expect(find.text('CONSENSI E PRIVACY'), findsOneWidget);
      expect(find.text('Accetto Termini e Privacy Policy'), findsOneWidget);
      expect(find.text('Leggi i termini'), findsOneWidget);
    });

    testWidgets('non invia signup se mancano campi obbligatori',
        (tester) async {
      await pumpScreen(tester);
      await goToProfileStep(tester);

      await tester.ensureVisible(find.text('CREA ACCOUNT'));
      await tester.tap(find.text('CREA ACCOUNT'));
      await tester.pump();

      expect(find.text('Compila tutti i campi obbligatori.'), findsOneWidget);
      verifyNever(() => repository.signUp(any(), any()));
    });
  });
}
