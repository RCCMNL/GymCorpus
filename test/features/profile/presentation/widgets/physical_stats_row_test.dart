import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/profile/presentation/widgets/physical_stats_row.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

void main() {
  Widget wrap({
    required UserEntity? user,
    required TrainingState trainingState,
  }) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: PhysicalStatsRow(user: user, trainingState: trainingState),
          ),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Modifica Profilo'))),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('senza utente non mostra nulla', (tester) async {
    await tester.pumpWidget(
      wrap(
        user: null,
        trainingState: const TrainingState.loaded(exercises: []),
      ),
    );

    expect(find.byType(Wrap), findsNothing);
  });

  testWidgets('con dati completi mostra peso, altezza ed eta', (tester) async {
    const user = UserEntity(id: '1', email: 'a@a.com', weight: 80, height: 180);

    await tester.pumpWidget(
      wrap(
        user: user,
        trainingState: const TrainingState.loaded(exercises: []),
      ),
    );

    expect(find.text('80.0kg'), findsOneWidget);
    expect(find.text('180cm'), findsOneWidget);
    expect(find.text('? anni'), findsOneWidget);
  });

  testWidgets('mostra libbre e pollici quando le impostazioni sono LB', (
    tester,
  ) async {
    const user = UserEntity(id: '1', email: 'a@a.com', weight: 80, height: 180);

    await tester.pumpWidget(
      wrap(
        user: user,
        trainingState: const TrainingState.loaded(
          exercises: [],
          settings: {'units': 'LB'},
        ),
      ),
    );

    expect(find.text('176.4lb'), findsOneWidget);
    expect(find.text('70in'), findsOneWidget);
  });

  testWidgets('con dati mancanti il tap naviga alla modifica del profilo', (
    tester,
  ) async {
    const user = UserEntity(id: '1', email: 'a@a.com');

    await tester.pumpWidget(
      wrap(
        user: user,
        trainingState: const TrainingState.loaded(exercises: []),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.text('Modifica Profilo'), findsOneWidget);
  });
}
