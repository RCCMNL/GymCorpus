import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/quick_tip_box.dart';

void main() {
  testWidgets("mostra l'etichetta PRO TIP", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: QuickTipBox())),
    );

    expect(find.text('PRO TIP'), findsOneWidget);
    expect(find.byIcon(Icons.tips_and_updates_rounded), findsOneWidget);
  });
}
