import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_stats_panel.dart';

void main() {
  Widget buildPanel({
    bool isRun = true,
    bool isTracking = false,
    bool isLocating = false,
    bool isPaused = false,
    bool isSaving = false,
    VoidCallback? onStart,
    VoidCallback? onPauseResume,
    VoidCallback? onStop,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CardioStatsPanel(
          isRun: isRun,
          distanceKm: 5.2,
          elapsedSeconds: 1830, // 30:30
          currentSpeedKmh: 10.4,
          currentSteps: 4200,
          userWeightKg: 70,
          isTracking: isTracking,
          isLocating: isLocating,
          isPaused: isPaused,
          isSaving: isSaving,
          onStart: onStart ?? () {},
          onPauseResume: onPauseResume ?? () {},
          onStop: onStop ?? () {},
        ),
      ),
    );
  }

  testWidgets('mostra le statistiche formattate correttamente', (tester) async {
    await tester.pumpWidget(buildPanel());

    expect(find.text('5.20 km'), findsOneWidget);
    expect(find.text('30:30'), findsOneWidget);
    expect(find.text('10.4 km/h'), findsOneWidget);
    expect(find.text('4200'), findsOneWidget);
  });

  testWidgets('mostra il pulsante di avvio quando non in tracking', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(buildPanel(onStart: () => started = true));

    expect(find.text('INIZIA CORSA'), findsOneWidget);
    await tester.tap(find.text('INIZIA CORSA'));
    expect(started, isTrue);
  });

  testWidgets('mostra INIZIA CAMMINATA quando isRun e false', (tester) async {
    await tester.pumpWidget(buildPanel(isRun: false));
    expect(find.text('INIZIA CAMMINATA'), findsOneWidget);
  });

  testWidgets('mostra PAUSA e FINE durante il tracking, invoca le callback', (
    tester,
  ) async {
    var pauseResumeTapped = false;
    var stopped = false;

    await tester.pumpWidget(
      buildPanel(
        isTracking: true,
        onPauseResume: () => pauseResumeTapped = true,
        onStop: () => stopped = true,
      ),
    );

    expect(find.text('PAUSA'), findsOneWidget);
    expect(find.text('FINE'), findsOneWidget);

    await tester.tap(find.text('PAUSA'));
    expect(pauseResumeTapped, isTrue);

    await tester.tap(find.text('FINE'));
    expect(stopped, isTrue);
  });

  testWidgets('mostra RIPRENDI quando in pausa', (tester) async {
    await tester.pumpWidget(buildPanel(isTracking: true, isPaused: true));
    expect(find.text('RIPRENDI'), findsOneWidget);
    expect(find.text('PAUSA'), findsNothing);
  });

  testWidgets('mostra SALVO... e disabilita FINE quando isSaving e true', (
    tester,
  ) async {
    await tester.pumpWidget(buildPanel(isTracking: true, isSaving: true));

    expect(find.text('SALVO...'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('SALVO...'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}
