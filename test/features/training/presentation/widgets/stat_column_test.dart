import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/stat_column.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    String value, {
    StatProminence prominence = StatProminence.primary,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: StatColumn(
              label: 'DISTANZA',
              value: value,
              theme: Theme.of(context),
              prominence: prominence,
            ),
          ),
        ),
      ),
    );
  }

  double fontSizeOf(WidgetTester tester, String value) =>
      tester.widget<Text>(find.text(value)).style!.fontSize!;

  testWidgets('mostra etichetta e valore', (tester) async {
    await pump(tester, '5.20 km');

    expect(find.text('DISTANZA'), findsOneWidget);
    expect(find.text('5.20 km'), findsOneWidget);
  });

  // Sei numeri tutti dello stesso peso sono sei numeri fra cui scegliere
  // mentre corri. Distanza e durata si guardano di sfuggita, calorie e
  // passi si leggono dopo: il peso lo deve dire la pagina, non l'utente.
  testWidgets('il numero che conta e piu grande di quello di contorno', (
    tester,
  ) async {
    await pump(tester, '5.20 km');
    final primary = fontSizeOf(tester, '5.20 km');

    await pump(tester, '5.20 km', prominence: StatProminence.secondary);
    final secondary = fontSizeOf(tester, '5.20 km');

    expect(secondary, lessThan(primary));
  });

  testWidgets('quello di contorno e anche piu smorzato', (tester) async {
    await pump(tester, '320 kcal');
    final primary = tester.widget<Text>(find.text('320 kcal')).style!.color!;

    await pump(tester, '320 kcal', prominence: StatProminence.secondary);
    final secondary = tester.widget<Text>(find.text('320 kcal')).style!.color!;

    expect(secondary.a, lessThan(primary.a));
  });
}
