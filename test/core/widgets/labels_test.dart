import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

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

  group('Eyebrow', () {
    testWidgets('mostra la riga che riceve', (tester) async {
      await pump(tester, const Eyebrow('PROSSIMO'));

      expect(find.text('PROSSIMO'), findsOneWidget);
    });

    testWidgets('di suo e smorzato', (tester) async {
      await pump(tester, const Eyebrow('RECUPERO'));

      expect(
        styleOf(tester, 'RECUPERO').color,
        AppTheme.darkTheme.colorScheme.outline,
      );
    });

    testWidgets('prende l accento della scheda quando ne ha uno', (
      tester,
    ) async {
      await pump(tester, const Eyebrow('PRO TIP', color: Colors.orangeAccent));

      expect(styleOf(tester, 'PRO TIP').color, Colors.orangeAccent);
    });

    testWidgets('la misura non si sceglie', (tester) async {
      await pump(
        tester,
        const Eyebrow('ALLENAMENTO', color: Colors.orangeAccent),
      );

      final style = styleOf(tester, 'ALLENAMENTO');

      expect(style.fontSize, 10);
      expect(style.letterSpacing, 2);
      expect(style.fontWeight, FontWeight.w900);
    });
  });

  group('StatLabel', () {
    testWidgets('mostra l etichetta che riceve', (tester) async {
      await pump(tester, const StatLabel('DISTANZA'));

      expect(find.text('DISTANZA'), findsOneWidget);
    });

    testWidgets('e sempre smorzata e sempre della stessa misura', (
      tester,
    ) async {
      await pump(tester, const StatLabel('CALORIE'));

      final style = styleOf(tester, 'CALORIE');

      expect(style.color, AppTheme.darkTheme.colorScheme.outline);
      expect(style.fontSize, 10);
      expect(style.letterSpacing, 1.5);
      expect(style.fontWeight, FontWeight.w900);
    });
  });
}
