import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/detailed_cardio_card.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mostra le metriche principali della sessione', (tester) async {
    final session = CardioSessionEntity(
      id: 1,
      type: 'run',
      distance: 5.2,
      duration: 1830,
      avgSpeed: 10.4,
      pace: '05:45',
      calories: 420,
      date: DateTime(2026),
    );

    await tester.pumpWidget(
      wrap(DetailedCardioCard(session: session, accentColor: Colors.blue)),
    );

    expect(find.text('5.20 km'), findsOneWidget);
    expect(find.text('30m 30s'), findsOneWidget);
    expect(find.text('10.4 km/h'), findsOneWidget);
    expect(find.text('05:45 /km'), findsOneWidget);
    expect(find.text('420 kcal'), findsOneWidget);
  });

  testWidgets('mostra "camminata" per le sessioni di tipo walk', (
    tester,
  ) async {
    final session = CardioSessionEntity(
      id: 2,
      type: 'walk',
      distance: 3,
      duration: 1200,
      avgSpeed: 6,
      pace: '10:00',
      calories: 200,
      date: DateTime(2026),
    );

    await tester.pumpWidget(
      wrap(DetailedCardioCard(session: session, accentColor: Colors.orange)),
    );

    expect(find.text('Camminata'), findsOneWidget);
  });

  testWidgets('senza percorso mostra "Mappa assente" e nessun toggle', (
    tester,
  ) async {
    final session = CardioSessionEntity(
      id: 3,
      type: 'run',
      distance: 5,
      duration: 1800,
      avgSpeed: 10,
      pace: '06:00',
      calories: 400,
      date: DateTime(2026),
    );

    await tester.pumpWidget(
      wrap(DetailedCardioCard(session: session, accentColor: Colors.blue)),
    );

    expect(find.text('Mappa assente'), findsOneWidget);
    expect(find.text('MAPPA'), findsNothing);
  });

  testWidgets('con un percorso mostra il toggle mappa e la espande al tap', (
    tester,
  ) async {
    final routeJson = jsonEncode([
      {'lat': 41.90, 'lng': 12.49},
      {'lat': 41.91, 'lng': 12.50},
    ]);
    final session = CardioSessionEntity(
      id: 4,
      type: 'run',
      distance: 5,
      duration: 1800,
      avgSpeed: 10,
      pace: '06:00',
      calories: 400,
      date: DateTime(2026),
      routeJson: routeJson,
    );

    await tester.pumpWidget(
      wrap(DetailedCardioCard(session: session, accentColor: Colors.blue)),
    );

    expect(find.text('MAPPA'), findsOneWidget);
    // AnimatedCrossFade costruisce sempre entrambi i rami: la mappa e' gia'
    // nell'albero ma collassata finche' non si espande.
    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showFirst,
    );

    await tester.tap(find.text('MAPPA'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showSecond,
    );
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
