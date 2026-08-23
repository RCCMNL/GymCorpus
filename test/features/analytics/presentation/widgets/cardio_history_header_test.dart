import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_history_header.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('CardioHistoryTopBar', () {
    testWidgets('mostra il titolo della sezione', (tester) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => CardioHistoryTopBar(theme: Theme.of(context)),
          ),
        ),
      );

      expect(find.text('Cronologia cardio'), findsOneWidget);
      expect(find.text('CRONOLOGIA E PERCORSI'), findsOneWidget);
    });
  });

  group('CardioOverviewStat', () {
    testWidgets('mostra etichetta e valore', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Row(
            children: [
              CardioOverviewStat(
                label: 'Sessioni',
                value: '12',
                accentColor: Colors.blue,
              ),
            ],
          ),
        ),
      );

      expect(find.text('SESSIONI'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });

  group('CardioHistoryOverview', () {
    testWidgets('mostra sessioni, distanza e calorie totali', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CardioHistoryOverview(
            totalSessions: 10,
            totalDistance: 42.5,
            totalCalories: 3200,
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.text('42.5 km'), findsOneWidget);
      expect(find.text('3200'), findsOneWidget);
    });
  });

  group('EmptyCardioHistoryView', () {
    testWidgets('mostra il messaggio di nessuna sessione salvata', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) =>
                EmptyCardioHistoryView(theme: Theme.of(context)),
          ),
        ),
      );

      expect(find.text('Nessuna sessione cardio salvata'), findsOneWidget);
    });
  });
}
