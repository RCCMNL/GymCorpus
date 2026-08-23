import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_session_widgets.dart';

void main() {
  group('GlassChip', () {
    testWidgets('mostra label e value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: GlassChip(
                label: 'RIPETIZIONI',
                value: '12',
                color: Colors.blue,
                theme: Theme.of(context),
              ),
            ),
          ),
        ),
      );

      expect(find.text('RIPETIZIONI'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });

  group('ActionPill', () {
    testWidgets('mostra icona e label, invoca onTap al tocco', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ActionPill(
                icon: Icons.refresh_rounded,
                label: 'Riavvia',
                onTap: () => tapped = true,
                filled: false,
                theme: Theme.of(context),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Riavvia'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      await tester.tap(find.byType(ActionPill));
      expect(tapped, isTrue);
    });
  });

  group('TimerRingPainter', () {
    test('shouldRepaint e sempre true', () {
      const painter = TimerRingPainter(
        progress: 0.5,
        color: Colors.red,
        trackColor: Colors.grey,
      );
      const oldPainter = TimerRingPainter(
        progress: 0.5,
        color: Colors.red,
        trackColor: Colors.grey,
      );

      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    testWidgets('si disegna senza errori dentro un CustomPaint', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: TimerRingPainter(
                  progress: 0.75,
                  color: Colors.orange,
                  trackColor: Colors.black12,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
