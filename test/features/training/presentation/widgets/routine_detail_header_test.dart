import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_detail_header.dart';

void main() {
  testWidgets('mostra titolo, numero esercizi e durata stimata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoutineDetailHeader(
            title: 'Push Day',
            exerciseCount: 6,
            estimatedDuration: 45,
          ),
        ),
      ),
    );

    expect(find.text('Push Day'), findsOneWidget);
    expect(find.text('6 ESERCIZI'), findsOneWidget);
    expect(find.text('45 MIN'), findsOneWidget);
  });

  testWidgets('mostra -- quando la durata stimata e assente', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoutineDetailHeader(
            title: 'Full Body',
            exerciseCount: 3,
            estimatedDuration: null,
          ),
        ),
      ),
    );

    expect(find.text('-- MIN'), findsOneWidget);
  });
}
