import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_phase_ring.dart';

/// L'anello mostrava "Giorno 3" anche a un utente che non aveva mai
/// registrato nulla. Senza dati non deve esserci alcun numero.
void main() {
  Widget wrap(CycleSummary summary) => MaterialApp(
    home: Scaffold(body: CyclePhaseRing(summary: summary)),
  );

  testWidgets('senza registrazioni invita a segnare il primo giorno', (
    tester,
  ) async {
    final summary = CycleForecast.calculate(
      logs: const [],
      today: DateTime(2026, 9, 5),
    );

    await tester.pumpWidget(wrap(summary));

    expect(find.textContaining('Giorno'), findsNothing);
    expect(find.textContaining('Nessun ciclo registrato'), findsOneWidget);
  });

  testWidgets('con una mestruazione in corso mostra giorno e fase', (
    tester,
  ) async {
    final summary = CycleForecast.calculate(
      logs: [CycleLogEntity(id: 1, startDate: DateTime(2026, 9, 3))],
      today: DateTime(2026, 9, 5),
    );

    await tester.pumpWidget(wrap(summary));

    expect(find.text('Giorno 3'), findsOneWidget);
    expect(find.text('Fase Mestruale'), findsOneWidget);
  });

  testWidgets('con dati vecchi non mostra un giorno del ciclo', (tester) async {
    final summary = CycleForecast.calculate(
      logs: [
        CycleLogEntity(
          id: 1,
          startDate: DateTime(2026, 3),
          endDate: DateTime(2026, 3, 5),
        ),
      ],
      today: DateTime(2026, 9, 5),
    );

    await tester.pumpWidget(wrap(summary));

    expect(find.textContaining('Giorno'), findsNothing);
    expect(find.textContaining('Dati non aggiornati'), findsOneWidget);
  });
}
