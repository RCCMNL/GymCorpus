import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_history_section.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;

  setUpAll(() {
    registerFallbackValue(LoadExercisesEvent());
  });

  setUp(() {
    bloc = MockTrainingBloc();
  });

  // Provider sopra MaterialApp.router: il dialog di conferma eliminazione
  // usa il root navigator, che non vedrebbe un provider annidato in home.
  Widget wrap(TrainingState state) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, s) =>
              Scaffold(body: CardioHistorySection(state: state)),
        ),
        GoRoute(
          path: '/analytics/cardio-history',
          builder: (context, s) =>
              const Scaffold(body: Center(child: Text('Cronologia Cardio'))),
        ),
      ],
    );
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('mostra lo stato vuoto senza sessioni', (tester) async {
    await tester.pumpWidget(wrap(const TrainingState.loaded(exercises: [])));

    expect(find.text('Nessuna sessione registrata'), findsOneWidget);
    expect(find.text('GUARDA TUTTE'), findsNothing);
  });

  testWidgets('mostra al massimo le 3 sessioni piu recenti', (tester) async {
    final sessions = List.generate(
      5,
      (i) => CardioSessionEntity(
        id: i,
        type: 'run',
        distance: 5,
        duration: 1800,
        avgSpeed: 10,
        pace: '06:00',
        calories: 400,
        date: DateTime(2026, 1, i + 1),
      ),
    );

    await tester.pumpWidget(
      wrap(TrainingState.loaded(exercises: const [], cardioSessions: sessions)),
    );

    expect(find.byType(CompactCardioCard), findsNWidgets(3));
    expect(find.text('GUARDA TUTTE'), findsOneWidget);
  });

  testWidgets('il tap su GUARDA TUTTE naviga alla cronologia completa', (
    tester,
  ) async {
    final sessions = [
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
    ];

    await tester.pumpWidget(
      wrap(TrainingState.loaded(exercises: const [], cardioSessions: sessions)),
    );

    await tester.tap(find.text('GUARDA TUTTE'));
    await tester.pumpAndSettle();

    expect(find.text('Cronologia Cardio'), findsOneWidget);
  });

  testWidgets("confermare l'eliminazione invia DeleteCardioSessionEvent", (
    tester,
  ) async {
    final sessions = [
      CardioSessionEntity(
        id: 9,
        type: 'run',
        distance: 5,
        duration: 1800,
        avgSpeed: 10,
        pace: '06:00',
        calories: 400,
        date: DateTime(2026),
      ),
    ];

    await tester.pumpWidget(
      wrap(TrainingState.loaded(exercises: const [], cardioSessions: sessions)),
    );

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Elimina sessione'), findsOneWidget);
    await tester.tap(find.text('ELIMINA'));
    await tester.pumpAndSettle();

    final captured = verify(() => bloc.add(captureAny())).captured;
    final event = captured.whereType<DeleteCardioSessionEvent>().single;
    expect(event.id, 9);
  });
}
