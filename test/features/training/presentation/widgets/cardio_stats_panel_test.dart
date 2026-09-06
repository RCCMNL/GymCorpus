import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_stats_panel.dart';

void main() {
  Widget buildPanel({
    CardioActivity activity = CardioActivity.run,
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
          activity: activity,
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

  testWidgets('mostra INIZIA CAMMINATA per la camminata', (tester) async {
    await tester.pumpWidget(buildPanel(activity: CardioActivity.walk));
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

  group('obiettivo di sessione', () {
    Widget buildWithGoal(CardioGoal? goal) {
      return MaterialApp(
        home: Scaffold(
          body: CardioStatsPanel(
            activity: CardioActivity.run,
            distanceKm: 2.5,
            elapsedSeconds: 900,
            currentSpeedKmh: 10,
            currentSteps: 3000,
            userWeightKg: 70,
            isTracking: true,
            isLocating: false,
            isPaused: false,
            isSaving: false,
            goal: goal,
            onStart: () {},
            onPauseResume: () {},
            onStop: () {},
          ),
        ),
      );
    }

    testWidgets('senza obiettivo non compare alcuna barra', (tester) async {
      await tester.pumpWidget(buildWithGoal(null));

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('mostra quanto manca all obiettivo scelto', (tester) async {
      await tester.pumpWidget(
        buildWithGoal(const CardioGoal(type: CardioGoalType.distance, value: 5)),
      );

      expect(find.text('Obiettivo 5 km'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(0.5, 0.001));
    });

    testWidgets('al traguardo la barra e piena e lo dichiara', (tester) async {
      await tester.pumpWidget(
        buildWithGoal(const CardioGoal(type: CardioGoalType.duration, value: 15)),
      );

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 1.0);
      expect(find.text('Obiettivo raggiunto'), findsOneWidget);
    });
  });

  testWidgets('le calorie tengono conto dell andatura, non solo del tempo', (
    tester,
  ) async {
    // Prima la stima usava un MET fisso: mezz'ora di corsa lenta e mezz'ora
    // di corsa veloce risultavano identiche.
    Widget panel(double distanceKm) => MaterialApp(
      home: Scaffold(
        body: CardioStatsPanel(
          activity: CardioActivity.run,
          distanceKm: distanceKm,
          elapsedSeconds: 1800,
          currentSpeedKmh: 10,
          currentSteps: 0,
          userWeightKg: 70,
          isTracking: true,
          isLocating: false,
          isPaused: false,
          isSaving: false,
          onStart: () {},
          onPauseResume: () {},
          onStop: () {},
        ),
      ),
    );

    int kcalOf(WidgetTester tester) {
      final text = tester
          .widgetList<Text>(find.textContaining('kcal'))
          .first
          .data!;
      return int.parse(text.split(' ').first);
    }

    await tester.pumpWidget(panel(4));
    final slow = kcalOf(tester);

    await tester.pumpWidget(panel(7));
    final fast = kcalOf(tester);

    expect(fast, greaterThan(slow));
  });
}
