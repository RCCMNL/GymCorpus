import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/stat_section.dart';

void main() {
  testWidgets('mostra titolo e le StatItem passate', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatSection(
            title: 'Statistiche Totali',
            color: Colors.blue,
            stats: [
              StatItem(
                icon: Icons.fitness_center,
                value: '12',
                label: 'Allenamenti',
              ),
              StatItem(
                icon: Icons.timer,
                value: '3h 20m',
                label: 'Tempo totale',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('STATISTICHE TOTALI'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('ALLENAMENTI'), findsOneWidget);
    expect(find.text('3h 20m'), findsOneWidget);
    expect(find.text('TEMPO TOTALE'), findsOneWidget);
  });
}
