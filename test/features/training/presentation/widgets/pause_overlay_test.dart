import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/pause_overlay.dart';

void main() {
  testWidgets('mostra "IN PAUSA" e invoca onResume al tocco di RIPRENDI', (
    tester,
  ) async {
    var resumed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PauseOverlay(
            accentColor: Colors.blue,
            onResume: () => resumed = true,
          ),
        ),
      ),
    );

    expect(find.text('IN PAUSA'), findsOneWidget);

    await tester.tap(find.text('RIPRENDI'));
    expect(resumed, isTrue);
  });
}
