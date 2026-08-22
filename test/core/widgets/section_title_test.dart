import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/widgets/section_title.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  group('SectionTitle', () {
    testWidgets('mostra il titolo passato', (tester) async {
      await pump(tester, const SectionTitle('AUTENTICAZIONE'));

      expect(find.text('AUTENTICAZIONE'), findsOneWidget);
    });

    testWidgets('senza withAccentBar non mostra la barra colorata', (
      tester,
    ) async {
      await pump(tester, const SectionTitle('LIVELLO'));

      expect(find.byType(Row), findsNothing);
    });

    testWidgets('con withAccentBar antepone la barra colorata', (tester) async {
      await pump(
        tester,
        const SectionTitle('ZONA PERICOLOSA', withAccentBar: true),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.text('ZONA PERICOLOSA'), findsOneWidget);
    });

    testWidgets('applica color, letterSpacing e fontSize personalizzati', (
      tester,
    ) async {
      await pump(
        tester,
        const SectionTitle(
          'ESPORTAZIONE DATI',
          color: Colors.red,
          letterSpacing: 2,
          fontSize: 10,
        ),
      );

      final textWidget = tester.widget<Text>(find.text('ESPORTAZIONE DATI'));
      expect(textWidget.style?.color, Colors.red);
      expect(textWidget.style?.letterSpacing, 2);
      expect(textWidget.style?.fontSize, 10);
    });
  });
}
