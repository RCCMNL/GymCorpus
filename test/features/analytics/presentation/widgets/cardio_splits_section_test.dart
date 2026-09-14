import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_splits_section.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_splits.dart';

/// Gli split esistono solo per le sessioni registrate con i tempi di
/// passaggio: per le altre la sezione deve dirlo, non sparire in silenzio.
void main() {
  const splits = [
    CardioSplit(index: 1, distanceKm: 1, seconds: 300, isPartial: false),
    CardioSplit(index: 2, distanceKm: 1, seconds: 280, isPartial: false),
    CardioSplit(index: 3, distanceKm: 0.5, seconds: 150, isPartial: true),
  ];

  Widget wrap(List<CardioSplit> value) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: CardioSplitsSection(splits: value)),
    ),
  );

  testWidgets('senza split spiega il motivo', (tester) async {
    await tester.pumpWidget(wrap(const []));

    expect(find.textContaining('Split non disponibili'), findsOneWidget);
  });

  testWidgets('elenca un tratto per chilometro', (tester) async {
    await tester.pumpWidget(wrap(splits));

    expect(find.text('KM 1'), findsOneWidget);
    expect(find.text('KM 2'), findsOneWidget);
    expect(
      find.text('05:00'),
      findsNWidgets(2),
      reason: 'il km 1 e il mezzo km finale hanno lo stesso passo',
    );
    expect(find.text('04:40'), findsOneWidget);
  });

  testWidgets('il tratto finale parziale mostra la distanza percorsa', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(splits));

    expect(find.text('0.5 km'), findsOneWidget);
  });

  testWidgets('evidenzia il chilometro piu veloce', (tester) async {
    await tester.pumpWidget(wrap(splits));

    final rows = tester
        .widgetList<CardioSplitRow>(find.byType(CardioSplitRow))
        .toList();
    final fastest = rows.where((r) => r.isFastest).toList();

    expect(fastest.single.split.index, 2);
  });

  testWidgets('un tratto parziale non puo essere il piu veloce', (
    tester,
  ) async {
    // Mezzo chilometro in 150 secondi ha lo stesso passo del primo km, ma
    // confrontare un tratto incompleto con quelli pieni sarebbe fuorviante.
    await tester.pumpWidget(
      wrap(const [
        CardioSplit(index: 1, distanceKm: 1, seconds: 300, isPartial: false),
        CardioSplit(index: 2, distanceKm: 0.1, seconds: 20, isPartial: true),
      ]),
    );

    final rows = tester
        .widgetList<CardioSplitRow>(find.byType(CardioSplitRow))
        .toList();

    expect(rows.where((r) => r.isFastest).single.split.index, 1);
  });
}
