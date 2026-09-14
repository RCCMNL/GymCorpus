import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/confirm_dialog.dart';

/// Apre la domanda e consegna a [onAnswer] la risposta dell'utente.
Future<void> _ask(
  WidgetTester tester,
  void Function({required bool answer}) onAnswer, {
  String confirmLabel = 'ELIMINA',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              onAnswer(
                answer: await ConfirmDialog.ask(
                  context,
                  title: 'Elimina esercizio?',
                  message: 'Non si torna indietro.',
                  confirmLabel: confirmLabel,
                ),
              );
            },
            child: const Text('chiedi'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('chiedi'));
  await tester.pumpAndSettle();
}

void main() {
  group('ConfirmDialog.ask', () {
    testWidgets('mostra domanda, spiegazione e le due scelte', (tester) async {
      await _ask(tester, ({required answer}) {});

      expect(find.text('Elimina esercizio?'), findsOneWidget);
      expect(find.text('Non si torna indietro.'), findsOneWidget);
      expect(find.text('ANNULLA'), findsOneWidget);
      expect(find.text('ELIMINA'), findsOneWidget);
    });

    testWidgets('confermare risponde di si', (tester) async {
      bool? risposta;
      await _ask(tester, ({required answer}) => risposta = answer);

      await tester.tap(find.text('ELIMINA'));
      await tester.pumpAndSettle();

      expect(risposta, isTrue);
    });

    testWidgets('annullare risponde di no', (tester) async {
      bool? risposta;
      await _ask(tester, ({required answer}) => risposta = answer);

      await tester.tap(find.text('ANNULLA'));
      await tester.pumpAndSettle();

      expect(risposta, isFalse);
    });

    testWidgets('chiudere il dialogo di lato risponde di no', (tester) async {
      bool? risposta;
      await _ask(tester, ({required answer}) => risposta = answer);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(risposta, isFalse);
    });

    testWidgets('l etichetta della conferma si puo cambiare', (tester) async {
      await _ask(tester, ({required answer}) {}, confirmLabel: 'ESCI');

      expect(find.text('ESCI'), findsOneWidget);
      expect(find.text('ELIMINA'), findsNothing);
    });
  });
}
