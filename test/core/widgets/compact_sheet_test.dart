import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('CompactSheet', () {
    testWidgets('mostra titolo e contenuto', (tester) async {
      await _pump(
        tester,
        const CompactSheet(
          title: 'Registra peso',
          children: [Text('corpo del foglio')],
        ),
      );

      expect(find.text('Registra peso'), findsOneWidget);
      expect(find.text('corpo del foglio'), findsOneWidget);
    });

    testWidgets('il sottotitolo compare solo se c e', (tester) async {
      await _pump(
        tester,
        const CompactSheet(title: 'Registra peso', children: [SizedBox()]),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('con il sottotitolo i testi diventano due', (tester) async {
      await _pump(
        tester,
        const CompactSheet(
          title: 'Registra peso',
          subtitle: 'Aggiorna la cronologia',
          children: [SizedBox()],
        ),
      );

      expect(find.text('Aggiorna la cronologia'), findsOneWidget);
    });
  });

  group('SheetActions', () {
    testWidgets('la conferma porta l etichetta richiesta', (tester) async {
      await _pump(
        tester,
        SheetActions(confirmLabel: 'Aggiorna', onConfirm: () {}),
      );

      expect(find.text('Aggiorna'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
    });

    testWidgets('toccare la conferma chiama chi l ha chiesta', (tester) async {
      var confermato = false;
      await _pump(
        tester,
        SheetActions(confirmLabel: 'Salva', onConfirm: () => confermato = true),
      );

      await tester.tap(find.text('Salva'));

      expect(confermato, isTrue);
    });
  });

  group('DecimalField', () {
    testWidgets('mostra etichetta e unita di misura', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DecimalField(controller: controller, label: 'Peso', suffix: 'kg'),
      );

      expect(find.text('Peso'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('in versione compatta stringe i bordi interni', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DecimalField(
          controller: controller,
          label: 'Petto',
          suffix: 'cm',
          dense: true,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));

      expect(
        field.decoration!.contentPadding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    });

    testWidgets('accetta la virgola come separatore decimale', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        DecimalField(controller: controller, label: 'Peso', suffix: 'kg'),
      );
      await tester.enterText(find.byType(TextField), '72,5');

      expect(controller.text, '72,5');
    });
  });
}
