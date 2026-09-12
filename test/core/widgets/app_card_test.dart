import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  );
}

BoxDecoration _decorationOf(WidgetTester tester) {
  return tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(AppCard),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration!
      as BoxDecoration;
}

void main() {
  group('AppCard', () {
    testWidgets('mostra il contenuto', (tester) async {
      await _pump(tester, const AppCard(child: Text('dentro la scheda')));

      expect(find.text('dentro la scheda'), findsOneWidget);
    });

    testWidgets('le tre misure sono 16, 24 e 32', (tester) async {
      for (final entry in {
        AppCardSize.tight: 16.0,
        AppCardSize.card: 24.0,
        AppCardSize.panel: 32.0,
      }.entries) {
        await _pump(tester, AppCard(size: entry.key, child: const Text('x')));

        expect(
          _decorationOf(tester).borderRadius,
          BorderRadius.circular(entry.value),
          reason: 'misura ${entry.key}',
        );
      }
    });

    testWidgets('di suo e una scheda normale', (tester) async {
      await _pump(tester, const AppCard(child: Text('x')));

      expect(_decorationOf(tester).borderRadius, BorderRadius.circular(24));
    });

    testWidgets('il pozzetto e piu chiaro e non ha filo di bordo', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppCard(tone: AppCardTone.sunken, child: Text('x')),
      );

      final decoration = _decorationOf(tester);

      expect(
        decoration.color,
        AppTheme.darkTheme.colorScheme.surfaceContainerHighest,
      );
      expect(decoration.border, isNull);
    });

    testWidgets('il fondo e il bordo non si scelgono', (tester) async {
      await _pump(
        tester,
        const AppCard(size: AppCardSize.panel, child: Text('x')),
      );

      final decoration = _decorationOf(tester);
      final scheme = AppTheme.darkTheme.colorScheme;

      expect(decoration.color, scheme.surfaceContainerHigh);
      expect(
        decoration.border,
        Border.all(color: scheme.outline.withValues(alpha: 0.08)),
      );
    });

    testWidgets('i bordi interni e lo stacco esterno si passano', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppCard(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(bottom: 16),
          child: Text('x'),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppCard),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.padding, const EdgeInsets.all(20));
      expect(container.margin, const EdgeInsets.only(bottom: 16));
    });

    testWidgets('larghezza e altezza sono layout, e si passano', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppCard(width: 120, height: 64, child: Text('x')),
      );

      expect(tester.getSize(find.byType(AppCard)), const Size(120, 64));
    });

    testWidgets('anche un minimo d altezza e layout', (tester) async {
      await _pump(
        tester,
        const AppCard(
          constraints: BoxConstraints(minHeight: 80),
          child: Text('x'),
        ),
      );

      expect(tester.getSize(find.byType(AppCard)).height, 80);
    });

    testWidgets('il contenuto si puo tagliare sugli angoli', (tester) async {
      await _pump(
        tester,
        const AppCard(clipBehavior: Clip.antiAlias, child: Text('x')),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppCard),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.clipBehavior, Clip.antiAlias);
    });
  });

  group('tinta di un accento', () {
    test('il riempimento e il bordo di una pillola sono fissi', () {
      const accent = Color(0xFF3366FF);

      expect(accent.tintedFill, accent.withValues(alpha: 0.1));
      expect(accent.tintedBorder, accent.withValues(alpha: 0.2));
    });
  });
}
