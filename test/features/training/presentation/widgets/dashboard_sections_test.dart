import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/skeleton.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/widgets/dashboard_sections.dart';

RoutineEntity _routine(String title) {
  return RoutineEntity(
    id: 1,
    title: title,
    createdAt: DateTime(2026, 5, 4),
    estimatedDuration: 45,
  );
}

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('TrainingHubGreeting', () {
    testWidgets('saluta chi si e appena connesso', (tester) async {
      await _pump(tester, const TrainingHubGreeting(userName: 'Marco'));

      expect(find.text('Bentornato, Marco'), findsOneWidget);
    });
  });

  group('YourRoutinesCard', () {
    testWidgets('mostra le routine che ha ricevuto', (tester) async {
      await _pump(
        tester,
        YourRoutinesCard(
          routines: [_routine('Push day')],
          onOpenRoutine: (_) {},
          onCreateFirst: () {},
          onStartWorkout: () {},
        ),
      );

      expect(find.text('PUSH DAY'), findsOneWidget);
    });

    testWidgets('senza routine invita a crearne una', (tester) async {
      var creato = false;
      await _pump(
        tester,
        YourRoutinesCard(
          routines: const [],
          onOpenRoutine: (_) {},
          onCreateFirst: () => creato = true,
          onStartWorkout: () {},
        ),
      );

      expect(find.text('Nessuna routine trovata'), findsOneWidget);
      await tester.tap(find.text('CREA LA TUA PRIMA ROUTINE'));
      expect(creato, isTrue);
    });

    testWidgets('finche le routine non sono arrivate mostra l attesa', (
      tester,
    ) async {
      await _pump(
        tester,
        YourRoutinesCard(
          routines: null,
          onOpenRoutine: (_) {},
          onCreateFirst: () {},
          onStartWorkout: () {},
        ),
      );

      // L'attesa ha la forma delle righe che sta aspettando, non di
      // una rotella al centro del vuoto.
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.text('Nessuna routine trovata'), findsNothing);
    });

    testWidgets('il pulsante avvia allenamento avvisa la schermata', (
      tester,
    ) async {
      var avviato = false;
      await _pump(
        tester,
        YourRoutinesCard(
          routines: const [],
          onOpenRoutine: (_) {},
          onCreateFirst: () {},
          onStartWorkout: () => avviato = true,
        ),
      );

      await tester.tap(find.text('AVVIA ALLENAMENTO'));

      expect(avviato, isTrue);
    });
  });

  group('QuickActivityGrid', () {
    testWidgets('mostra le tre attivita rapide', (tester) async {
      await _pump(
        tester,
        QuickActivityGrid(onCardio: () {}, onYoga: () {}, onNutrition: () {}),
      );

      expect(find.text('Cardio Training'), findsOneWidget);
      expect(find.text('Yoga & Mindfulness'), findsOneWidget);
      expect(find.text('Nutrizione & Dieta'), findsOneWidget);
    });

    testWidgets('toccare il cardio apre la scelta del cardio', (tester) async {
      var cardio = false;
      await _pump(
        tester,
        QuickActivityGrid(
          onCardio: () => cardio = true,
          onYoga: () {},
          onNutrition: () {},
        ),
      );

      await tester.tap(find.text('Cardio Training'));

      expect(cardio, isTrue);
    });
  });
}
