import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/mini_input.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra il valore iniziale del controller e la label', (
    tester,
  ) async {
    final controller = TextEditingController(text: '42');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(MiniInput(controller: controller, label: 'RIP.', onChanged: (_) {})),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('RIP.'), findsOneWidget);
  });

  testWidgets('onChanged riceve il nuovo testo digitato', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? received;

    await tester.pumpWidget(
      wrap(
        MiniInput(
          controller: controller,
          label: 'PESO KG',
          onChanged: (v) => received = v,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '80');
    expect(received, '80');
  });
}
