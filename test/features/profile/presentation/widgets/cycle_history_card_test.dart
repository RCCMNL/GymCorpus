import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/cycle_history_card.dart';

/// Lo storico e' anche il punto in cui si corregge un tocco sbagliato:
/// senza una via di cancellazione una data segnata per errore resterebbe
/// per sempre nelle medie.
void main() {
  final today = DateTime(2026, 9, 20);

  final closed = [
    CycleLogEntity(
      id: 2,
      startDate: DateTime(2026, 9, 2),
      endDate: DateTime(2026, 9, 6),
    ),
    CycleLogEntity(
      id: 1,
      startDate: DateTime(2026, 8, 5),
      endDate: DateTime(2026, 8, 9),
    ),
  ];

  Widget wrap(List<CycleLogEntity> logs, {ValueChanged<int>? onDelete}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CycleHistoryCard(
            logs: logs,
            summary: CycleForecast.calculate(logs: logs, today: today),
            onDelete: onDelete ?? (_) {},
            onEdit: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('mostra la data prevista del prossimo ciclo', (tester) async {
    // Ultimo inizio il 2 settembre, media 28 giorni: atteso il 30 settembre.
    await tester.pumpWidget(wrap(closed));

    expect(find.text('30 settembre 2026'), findsOneWidget);
  });

  testWidgets('oltre la previsione mostra il ritardo', (tester) async {
    final late = [
      CycleLogEntity(
        id: 1,
        startDate: DateTime(2026, 8, 5),
        endDate: DateTime(2026, 8, 9),
      ),
    ];

    await tester.pumpWidget(wrap(late));

    expect(find.textContaining('In ritardo di'), findsOneWidget);
  });

  testWidgets('dichiara la durata come stima finche i cicli non bastano', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap([CycleLogEntity(id: 1, startDate: DateTime(2026, 9, 2))]),
    );

    expect(find.textContaining('28 giorni (stima)'), findsOneWidget);
  });

  testWidgets('con piu cicli la durata media non e piu una stima', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(closed));

    expect(find.text('28 giorni'), findsOneWidget);
    expect(find.textContaining('(stima)'), findsNothing);
  });

  testWidgets('elenca i cicli registrati', (tester) async {
    await tester.pumpWidget(wrap(closed));

    expect(find.text('2 - 6 settembre 2026'), findsOneWidget);
    expect(find.text('5 - 9 agosto 2026'), findsOneWidget);
    expect(find.text('5 giorni'), findsNWidgets(2));
  });

  testWidgets('un ciclo ancora aperto e mostrato come in corso', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap([CycleLogEntity(id: 3, startDate: DateTime(2026, 9, 18))]),
    );

    expect(find.text('Dal 18 settembre 2026'), findsOneWidget);
    expect(find.text('In corso'), findsOneWidget);
  });

  testWidgets('cancellare una registrazione richiede conferma', (tester) async {
    var deleted = 0;
    await tester.pumpWidget(wrap(closed, onDelete: (_) => deleted++));

    await tester.tap(find.byKey(const Key('cycle-delete-2')));
    await tester.pumpAndSettle();
    expect(deleted, 0, reason: 'il solo tocco non deve cancellare nulla');

    await tester.tap(find.text('ANNULLA'));
    await tester.pumpAndSettle();
    expect(deleted, 0);
  });

  testWidgets('confermando si cancella la registrazione scelta', (
    tester,
  ) async {
    final deleted = <int>[];
    await tester.pumpWidget(wrap(closed, onDelete: deleted.add));

    await tester.tap(find.byKey(const Key('cycle-delete-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ELIMINA'));
    await tester.pumpAndSettle();

    expect(deleted, [2]);
  });

  testWidgets('una data sbagliata si corregge senza cancellare tutto', (
    tester,
  ) async {
    CycleLogEntity? edited;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CycleHistoryCard(
              logs: closed,
              summary: CycleForecast.calculate(logs: closed, today: today),
              onDelete: (_) {},
              onEdit: (log) => edited = log,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('2 - 6 settembre 2026'));
    await tester.pump();

    expect(edited?.id, 2);
  });
}
