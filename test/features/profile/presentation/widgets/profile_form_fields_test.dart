import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/profile_form_fields.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ProfileTextField', () {
    testWidgets('mostra etichetta e suggerimento', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        ProfileTextField(
          controller: controller,
          label: 'NOME',
          hint: 'Inserisci il nome',
        ),
      );

      expect(find.text('NOME'), findsOneWidget);
      expect(find.text('Inserisci il nome'), findsOneWidget);
    });

    testWidgets('mentre si salva non si puo scrivere', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        ProfileTextField(
          controller: controller,
          label: 'NOME',
          hint: 'Inserisci il nome',
          enabled: false,
        ),
      );

      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
        isFalse,
      );
    });
  });

  group('ProfileDateField', () {
    testWidgets('senza data invita a sceglierne una', (tester) async {
      await _pump(
        tester,
        ProfileDateField(label: 'DATA DI NASCITA', onTap: () {}),
      );

      expect(find.text('Seleziona data'), findsOneWidget);
    });

    testWidgets('con una data la scrive in giorno mese anno', (tester) async {
      await _pump(
        tester,
        ProfileDateField(
          label: 'DATA DI NASCITA',
          value: DateTime(1994, 3, 7),
          onTap: () {},
        ),
      );

      expect(find.text('07/03/1994'), findsOneWidget);
    });

    testWidgets('toccarla apre la scelta', (tester) async {
      var aperta = false;
      await _pump(
        tester,
        ProfileDateField(label: 'DATA DI NASCITA', onTap: () => aperta = true),
      );

      await tester.tap(find.text('Seleziona data'));

      expect(aperta, isTrue);
    });
  });

  group('ProfileSaveButton', () {
    testWidgets('mostra l etichetta quando non sta salvando', (tester) async {
      await _pump(
        tester,
        ProfileSaveButton(label: 'SALVA MODIFICHE', onPressed: () {}),
      );

      expect(find.text('SALVA MODIFICHE'), findsOneWidget);
    });

    testWidgets('mentre salva gira e non si tocca', (tester) async {
      var premuto = false;
      await _pump(
        tester,
        ProfileSaveButton(
          label: 'SALVA MODIFICHE',
          isSaving: true,
          onPressed: () => premuto = true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(premuto, isFalse);
    });
  });
}
