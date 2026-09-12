import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/section_title.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;

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

    testWidgets('di suo e nel colore del brand', (tester) async {
      await pump(tester, const SectionTitle('PASTI DI OGGI'));

      expect(
        styleOf(tester, 'PASTI DI OGGI').color,
        AppTheme.darkTheme.colorScheme.primary,
      );
    });

    testWidgets('il tono smorzato introduce un gruppo di campi', (
      tester,
    ) async {
      await pump(
        tester,
        const SectionTitle('ATTREZZATURA', tone: SectionTitleTone.muted),
      );

      expect(
        styleOf(tester, 'ATTREZZATURA').color,
        AppTheme.darkTheme.colorScheme.outline,
      );
    });

    testWidgets('i due toni si distinguono anche dalla spaziatura', (
      tester,
    ) async {
      await pump(
        tester,
        const Column(
          children: [
            SectionTitle('BRAND'),
            SectionTitle('SMORZATO', tone: SectionTitleTone.muted),
          ],
        ),
      );

      expect(styleOf(tester, 'BRAND').letterSpacing, 1.5);
      expect(styleOf(tester, 'SMORZATO').letterSpacing, 2);
    });

    testWidgets('il peso e la misura non cambiano fra i toni', (tester) async {
      await pump(
        tester,
        const Column(
          children: [
            SectionTitle('BRAND'),
            SectionTitle('SMORZATO', tone: SectionTitleTone.muted),
          ],
        ),
      );

      for (final text in ['BRAND', 'SMORZATO']) {
        expect(styleOf(tester, text).fontWeight, FontWeight.w900);
        expect(styleOf(tester, text).fontSize, 11);
      }
    });
  });
}
