import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/insights_section.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

void main() {
  Widget wrap(TrainingState state) {
    return MaterialApp(
      home: Scaffold(body: InsightsSection(state: state, isImperial: false)),
    );
  }

  testWidgets('non mostra nulla quando lo stato non e caricato', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loading()));
    expect(find.text('INSIGHTS'), findsNothing);
  });

  testWidgets('non mostra nulla quando non ci sono dati per alcun insight', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));
    expect(find.text('INSIGHTS'), findsNothing);
  });

  testWidgets("mostra l'insight di stabilita del peso con 3+ log stabili", (
    tester,
  ) async {
    final state = TrainingState.loaded(
      exercises: const [],
      bodyWeightLogs: [
        BodyWeightLogEntity(id: 1, weight: 80.1, date: DateTime(2026, 1, 3)),
        BodyWeightLogEntity(id: 2, weight: 80, date: DateTime(2026, 1, 2)),
        BodyWeightLogEntity(id: 3, weight: 79.9, date: DateTime(2026)),
      ],
    );

    await tester.pumpWidget(wrap(state));

    expect(find.text('INSIGHTS'), findsOneWidget);
    expect(find.textContaining('peso è stabile'), findsOneWidget);
  });

  testWidgets("mostra l'insight cardio con distanza totale e conteggio", (
    tester,
  ) async {
    final state = TrainingState.loaded(
      exercises: const [],
      cardioSessions: [
        CardioSessionEntity(
          id: 1,
          type: 'run',
          distance: 5,
          duration: 1800,
          avgSpeed: 10,
          pace: '06:00',
          calories: 400,
          date: DateTime(2026),
        ),
        CardioSessionEntity(
          id: 2,
          type: 'run',
          distance: 3,
          duration: 1200,
          avgSpeed: 9,
          pace: '06:40',
          calories: 250,
          date: DateTime(2026, 1, 2),
        ),
      ],
    );

    await tester.pumpWidget(wrap(state));

    expect(
      find.text('Hai percorso 8.0 km in 2 sessioni cardio.'),
      findsOneWidget,
    );
  });
}
