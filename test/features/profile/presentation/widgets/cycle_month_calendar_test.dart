import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_month_calendar.dart';

/// Il calendario mostrava sempre 31 caselle con i primi cinque giorni
/// colorati, qualunque fosse il mese e qualunque cosa avesse registrato
/// l'utente. Qui si verifica che ogni casella venga dai dati veri.
void main() {
  final today = DateTime(2026, 9, 20);
  final logs = [
    CycleLogEntity(
      id: 1,
      startDate: DateTime(2026, 9, 2),
      endDate: DateTime(2026, 9, 6),
    ),
  ];
  final summary = CycleForecast.calculate(logs: logs, today: today);

  Widget wrap({DateTime? month, VoidCallback? onPrevious, VoidCallback? onNext}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CycleMonthCalendar(
            month: month ?? DateTime(2026, 9),
            logs: logs,
            summary: summary,
            today: today,
            onPreviousMonth: onPrevious ?? () {},
            onNextMonth: onNext ?? () {},
          ),
        ),
      ),
    );
  }

  List<CycleDayCell> cellsOf(WidgetTester tester) =>
      tester.widgetList<CycleDayCell>(find.byType(CycleDayCell)).toList();

  testWidgets('mostra tutti e soli i giorni del mese', (tester) async {
    await tester.pumpWidget(wrap());

    expect(cellsOf(tester).map((c) => c.day), List.generate(30, (i) => i + 1));
  });

  testWidgets('febbraio 2028 ha ventinove giorni', (tester) async {
    await tester.pumpWidget(wrap(month: DateTime(2028, 2)));

    expect(cellsOf(tester), hasLength(29));
  });

  testWidgets('segna i giorni di mestruazione registrati', (tester) async {
    await tester.pumpWidget(wrap());

    final marked = cellsOf(
      tester,
    ).where((c) => c.isPeriod).map((c) => c.day).toList();
    expect(marked, [2, 3, 4, 5, 6]);
  });

  testWidgets('segna la previsione del prossimo ciclo', (tester) async {
    // Ultimo inizio il 2 settembre, durata stimata 28 giorni: il prossimo
    // ciclo e' atteso dal 30 settembre.
    await tester.pumpWidget(wrap());

    final predicted = cellsOf(
      tester,
    ).where((c) => c.isPredicted).map((c) => c.day).toList();
    expect(predicted, [30]);
  });

  testWidgets('evidenzia il giorno corrente', (tester) async {
    await tester.pumpWidget(wrap());

    final todayCells = cellsOf(tester).where((c) => c.isToday).toList();
    expect(todayCells.single.day, 20);
  });

  testWidgets('un mese diverso da quello corrente non evidenzia nulla', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(month: DateTime(2026, 10)));

    expect(cellsOf(tester).any((c) => c.isToday), isFalse);
  });

  testWidgets('mostra il mese in italiano', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('SETTEMBRE 2026'), findsOneWidget);
  });

  testWidgets('le frecce cambiano mese', (tester) async {
    var previous = 0;
    var next = 0;
    await tester.pumpWidget(
      wrap(onPrevious: () => previous++, onNext: () => next++),
    );

    await tester.tap(find.byKey(const Key('cycle-previous-month')));
    await tester.tap(find.byKey(const Key('cycle-next-month')));

    expect(previous, 1);
    expect(next, 1);
  });
}
