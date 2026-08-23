import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/set_input_cell.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra il valore iniziale del controller e la label', (
    tester,
  ) async {
    final controller = TextEditingController(text: '12');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        SetInputCell(controller: controller, label: 'REPS', onChanged: (_) {}),
      ),
    );

    expect(find.text('12'), findsOneWidget);
    expect(find.text('REPS'), findsOneWidget);
  });

  testWidgets('onChanged riceve il nuovo testo digitato', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? received;

    await tester.pumpWidget(
      wrap(
        SetInputCell(
          controller: controller,
          label: 'KG',
          onChanged: (v) => received = v,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '60.5');
    expect(received, '60.5');
  });
}
