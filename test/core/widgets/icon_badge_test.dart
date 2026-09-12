import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  );
}

Container _boxOf(WidgetTester tester) {
  return tester.widget<Container>(
    find
        .descendant(
          of: find.byType(IconBadge),
          matching: find.byType(Container),
        )
        .first,
  );
}

void main() {
  const accent = Color(0xFF3366FF);

  group('IconBadge', () {
    testWidgets('mostra l icona che riceve', (tester) async {
      await _pump(tester, const IconBadge(Icons.bolt));

      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('le tre misure sono 8, 12 e 24 di bordo interno', (
      tester,
    ) async {
      for (final entry in {
        IconBadgeSize.small: 8.0,
        IconBadgeSize.medium: 12.0,
        IconBadgeSize.large: 24.0,
      }.entries) {
        await _pump(tester, IconBadge(Icons.bolt, size: entry.key));

        expect(
          _boxOf(tester).padding,
          EdgeInsets.all(entry.value),
          reason: 'misura ${entry.key}',
        );
      }
    });

    testWidgets('con un accento si tinge di quell accento', (tester) async {
      await _pump(tester, const IconBadge(Icons.bolt, color: accent));

      final decoration = _boxOf(tester).decoration! as BoxDecoration;

      expect(decoration.color, accent.withValues(alpha: 0.1));
      expect(tester.widget<Icon>(find.byType(Icon)).color, accent);
    });

    testWidgets('senza accento resta neutra', (tester) async {
      await _pump(tester, const IconBadge(Icons.bolt));

      final decoration = _boxOf(tester).decoration! as BoxDecoration;
      final scheme = AppTheme.darkTheme.colorScheme;

      expect(decoration.color, scheme.surfaceContainerHigh);
      expect(tester.widget<Icon>(find.byType(Icon)).color, scheme.outline);
    });

    testWidgets('di suo ha gli angoli tondi', (tester) async {
      await _pump(tester, const IconBadge(Icons.bolt));

      final decoration = _boxOf(tester).decoration! as BoxDecoration;

      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('se richiesto e un cerchio', (tester) async {
      await _pump(tester, const IconBadge(Icons.bolt, circle: true));

      final decoration = _boxOf(tester).decoration! as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull);
    });

    testWidgets('l icona cresce con la pastiglia', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            IconBadge(Icons.bolt, size: IconBadgeSize.small),
            IconBadge(Icons.star, size: IconBadgeSize.large),
          ],
        ),
      );

      expect(tester.widget<Icon>(find.byIcon(Icons.bolt)).size, 18);
      expect(tester.widget<Icon>(find.byIcon(Icons.star)).size, 48);
    });
  });
}
