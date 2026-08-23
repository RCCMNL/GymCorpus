import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/weekly_activity_card.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

void main() {
  Widget wrap(List<WorkoutSetEntity> logs) {
    return MaterialApp(
      home: Scaffold(body: WeeklyActivityCard(weightLogs: logs)),
    );
  }

  testWidgets('mostra le etichette dei 7 giorni della settimana', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const []));

    for (final day in ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM']) {
      expect(find.text(day), findsOneWidget);
    }
  });

  testWidgets('senza log nessun giorno mostra il segno di spunta', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const []));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('un log registrato oggi mostra il segno di spunta', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      wrap([
        WorkoutSetEntity(
          id: 1,
          workoutId: 1,
          exerciseId: 1,
          reps: 8,
          weight: 50,
          timestamp: now,
        ),
      ]),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
