import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/monthly_accordion.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('e chiuso di default e mostra titolo/conteggio', (tester) async {
    await tester.pumpWidget(
      wrap(
        const MonthlyAccordion(
          title: 'GENNAIO 2026',
          count: 4,
          child: Text('contenuto'),
        ),
      ),
    );

    expect(find.text('GENNAIO 2026'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('contenuto'), findsNothing);
  });

  testWidgets('initiallyExpanded true mostra subito il contenuto', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const MonthlyAccordion(
          title: 'GENNAIO 2026',
          count: 4,
          initiallyExpanded: true,
          child: Text('contenuto'),
        ),
      ),
    );

    expect(find.text('contenuto'), findsOneWidget);
  });

  testWidgets("il tap sull'header espande e richiude il contenuto", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const MonthlyAccordion(
          title: 'GENNAIO 2026',
          count: 4,
          child: Text('contenuto'),
        ),
      ),
    );

    await tester.tap(find.text('GENNAIO 2026'));
    await tester.pump();
    expect(find.text('contenuto'), findsOneWidget);

    await tester.tap(find.text('GENNAIO 2026'));
    await tester.pump();
    expect(find.text('contenuto'), findsNothing);
  });
}
