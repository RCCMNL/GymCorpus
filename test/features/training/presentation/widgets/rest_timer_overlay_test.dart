import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/rest_timer_overlay.dart';

void main() {
  Widget buildOverlay({
    int secondsRemaining = 90,
    VoidCallback? onRestart,
    VoidCallback? onSkip,
    VoidCallback? onConfirmEnd,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RestTimerOverlay(
          pulseController: null,
          progress: 0.5,
          secondsRemaining: secondsRemaining,
          accentColor: Colors.deepOrange,
          onRestart: onRestart ?? () {},
          onSkip: onSkip ?? () {},
          onConfirmEnd: onConfirmEnd ?? () {},
        ),
      ),
    );
  }

  testWidgets('mostra il countdown formattato mm:ss', (tester) async {
    await tester.pumpWidget(buildOverlay());
    expect(find.text('01:30'), findsOneWidget);

    await tester.pumpWidget(buildOverlay(secondsRemaining: 5));
    expect(find.text('00:05'), findsOneWidget);
  });

  testWidgets('Riavvia, Salta e Termina invocano le rispettive callback', (
    tester,
  ) async {
    var restarted = false;
    var skipped = false;
    var ended = false;

    await tester.pumpWidget(
      buildOverlay(
        onRestart: () => restarted = true,
        onSkip: () => skipped = true,
        onConfirmEnd: () => ended = true,
      ),
    );

    await tester.tap(find.text('Riavvia'));
    expect(restarted, isTrue);

    await tester.tap(find.text('Salta'));
    expect(skipped, isTrue);

    await tester.tap(find.text('TERMINA ALLENAMENTO'));
    expect(ended, isTrue);
  });
}
