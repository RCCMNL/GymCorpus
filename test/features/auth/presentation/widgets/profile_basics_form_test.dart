import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/presentation/widgets/profile_basics_form.dart';

/// Il form delle informazioni di base, condiviso tra registrazione e
/// onboarding: e' l'unico posto in cui si decide cosa e' obbligatorio.
void main() {
  final birthDate = DateTime(1990, 5, 12);

  Widget wrap({
    required void Function(ProfileBasics) onSubmit,
    ProfileBasics? initial,
    void Function(String)? onValidationError,
    Widget? footer,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProfileBasicsForm(
            submitLabel: 'COMPLETA',
            onSubmit: onSubmit,
            initial: initial,
            onValidationError: onValidationError ?? (_) {},
            footer: footer,
          ),
        ),
      ),
    );
  }

  /// Compila i tre campi di testo lasciando fuori genere e data.
  Future<void> fillNames(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'Mario');
    await tester.enterText(find.byType(TextField).at(1), 'Rossi');
    await tester.enterText(find.byType(TextField).at(2), 'mario');
  }

  Future<void> pickGender(WidgetTester tester, String value) async {
    await tester.tap(find.byKey(const Key('profile-gender')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  testWidgets('mostra i campi richiesti e l etichetta del pulsante', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onSubmit: (_) {}));

    expect(find.text('NOME'), findsOneWidget);
    expect(find.text('COGNOME'), findsOneWidget);
    expect(find.text('USERNAME'), findsOneWidget);
    expect(find.text('DATA DI NASCITA'), findsOneWidget);
    expect(find.text('GENERE'), findsOneWidget);
    expect(find.text('COMPLETA'), findsOneWidget);
  });

  testWidgets('il genere non e preselezionato', (tester) async {
    // Partire da "Uomo" non e' una scelta dell'utente: e' un'etichetta
    // messa d'ufficio, e finiva salvata tale e quale.
    await tester.pumpWidget(wrap(onSubmit: (_) {}));

    expect(find.text('Seleziona'), findsWidgets);
    expect(find.text('Uomo'), findsNothing);
  });

  testWidgets('senza genere non si prosegue', (tester) async {
    ProfileBasics? submitted;
    String? error;
    await tester.pumpWidget(
      wrap(
        onSubmit: (value) => submitted = value,
        initial: ProfileBasics(
          firstName: '',
          lastName: '',
          username: '',
          birthDate: birthDate,
          gender: null,
        ),
        onValidationError: (message) => error = message,
      ),
    );

    await fillNames(tester);
    await tester.tap(find.text('COMPLETA'));
    await tester.pump();

    expect(submitted, isNull);
    expect(error, contains('genere'));
  });

  testWidgets('senza data di nascita non si prosegue', (tester) async {
    ProfileBasics? submitted;
    String? error;
    await tester.pumpWidget(
      wrap(
        onSubmit: (value) => submitted = value,
        onValidationError: (message) => error = message,
      ),
    );

    await fillNames(tester);
    await pickGender(tester, 'Donna');
    await tester.tap(find.text('COMPLETA'));
    await tester.pump();

    expect(submitted, isNull);
    expect(error, contains('nascita'));
  });

  testWidgets('senza nome, cognome o username non si prosegue', (tester) async {
    ProfileBasics? submitted;
    String? error;
    await tester.pumpWidget(
      wrap(
        onSubmit: (value) => submitted = value,
        initial: ProfileBasics(
          firstName: '',
          lastName: '',
          username: '',
          birthDate: birthDate,
          gender: 'Donna',
        ),
        onValidationError: (message) => error = message,
      ),
    );

    await tester.tap(find.text('COMPLETA'));
    await tester.pump();

    expect(submitted, isNull);
    expect(error, isNotNull);
  });

  testWidgets('con tutto compilato consegna i valori', (tester) async {
    ProfileBasics? submitted;
    await tester.pumpWidget(
      wrap(
        onSubmit: (value) => submitted = value,
        initial: ProfileBasics(
          firstName: '',
          lastName: '',
          username: '',
          birthDate: birthDate,
          gender: null,
        ),
      ),
    );

    await fillNames(tester);
    await pickGender(tester, 'Altro');
    await tester.tap(find.text('COMPLETA'));
    await tester.pump();

    expect(submitted?.firstName, 'Mario');
    expect(submitted?.lastName, 'Rossi');
    expect(submitted?.username, 'mario');
    expect(submitted?.birthDate, birthDate);
    expect(submitted?.gender, 'Altro');
  });

  testWidgets('i valori iniziali precompilano il form', (tester) async {
    // Con Google nome e cognome arrivano gia' dall'account.
    await tester.pumpWidget(
      wrap(
        onSubmit: (_) {},
        initial: ProfileBasics(
          firstName: 'Mario',
          lastName: 'Rossi',
          username: 'mario',
          birthDate: birthDate,
          gender: 'Uomo',
        ),
      ),
    );

    expect(find.text('Mario'), findsOneWidget);
    expect(find.text('12/05/1990'), findsOneWidget);
    expect(find.text('Uomo'), findsOneWidget);
  });

  testWidgets('mostra il contenuto aggiuntivo passato dalla schermata', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(onSubmit: (_) {}, footer: const Text('Consensi e privacy')),
    );

    expect(find.text('Consensi e privacy'), findsOneWidget);
  });
}
