import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

BoxDecoration _decorationOf(WidgetTester tester, Finder finder) {
  return tester.widget<Container>(finder).decoration! as BoxDecoration;
}

void main() {
  group('RoutineCardShell', () {
    testWidgets('mostra il contenuto che riceve', (tester) async {
      await _pump(
        tester,
        RoutineCardShell(
          accent: Colors.blue,
          onTap: () {},
          child: const Text('Push day'),
        ),
      );

      expect(find.text('Push day'), findsOneWidget);
    });

    testWidgets('il tocco arriva a chi ha creato la scheda', (tester) async {
      var toccata = false;
      await _pump(
        tester,
        RoutineCardShell(
          accent: Colors.blue,
          onTap: () => toccata = true,
          child: const Text('Push day'),
        ),
      );

      await tester.tap(find.text('Push day'));

      expect(toccata, isTrue);
    });

    testWidgets('il bordo prende il colore di accento', (tester) async {
      await _pump(
        tester,
        RoutineCardShell(
          accent: const Color(0xFF00FF00),
          onTap: () {},
          child: const Text('Push day'),
        ),
      );

      final border =
          _decorationOf(tester, find.byType(Container).first).border! as Border;

      expect(border.top.color, const Color(0xFF00FF00).withValues(alpha: 0.15));
    });
  });

  group('RoutineTagChip', () {
    testWidgets('mostra etichetta e icona', (tester) async {
      await _pump(
        tester,
        const RoutineTagChip(
          label: '5 ESERCIZI',
          color: Colors.blue,
          icon: Icons.fitness_center_rounded,
        ),
      );

      expect(find.text('5 ESERCIZI'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });

    testWidgets('senza icona resta la sola etichetta', (tester) async {
      await _pump(
        tester,
        const RoutineTagChip(label: 'CONSIGLIATA', color: Colors.blue),
      );

      expect(find.text('CONSIGLIATA'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('lo sfondo di default e una velatura del colore', (
      tester,
    ) async {
      await _pump(
        tester,
        const RoutineTagChip(label: '5 ESERCIZI', color: Color(0xFF00FF00)),
      );

      expect(
        _decorationOf(tester, find.byType(Container).first).color,
        const Color(0xFF00FF00).withValues(alpha: 0.1),
      );
    });

    testWidgets('uno sfondo esplicito vince su quello di default', (
      tester,
    ) async {
      await _pump(
        tester,
        const RoutineTagChip(
          label: 'CONSIGLIATA',
          color: Colors.white,
          background: Color(0xFF123456),
        ),
      );

      expect(
        _decorationOf(tester, find.byType(Container).first).color,
        const Color(0xFF123456),
      );
    });
  });
}
