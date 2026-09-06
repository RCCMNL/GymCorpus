import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_action_button.dart';

/// Il pulsante fa una cosa sola per volta: la scelta dipende dal fatto che
/// esista o meno una mestruazione ancora aperta.
void main() {
  Widget wrap({
    required bool hasOpenLog,
    VoidCallback? onStart,
    VoidCallback? onEnd,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CycleActionButton(
          hasOpenLog: hasOpenLog,
          onStart: onStart ?? () {},
          onEnd: onEnd ?? () {},
        ),
      ),
    );
  }

  testWidgets('senza ciclo aperto propone di segnare l inizio', (tester) async {
    var started = 0;
    await tester.pumpWidget(wrap(hasOpenLog: false, onStart: () => started++));

    expect(find.text('SEGNA INIZIO CICLO'), findsOneWidget);

    await tester.tap(find.byType(CycleActionButton));
    expect(started, 1);
  });

  testWidgets('con un ciclo aperto propone di segnarne la fine', (
    tester,
  ) async {
    var ended = 0;
    await tester.pumpWidget(wrap(hasOpenLog: true, onEnd: () => ended++));

    expect(find.text('SEGNA FINE CICLO'), findsOneWidget);

    await tester.tap(find.byType(CycleActionButton));
    expect(ended, 1);
  });
}
