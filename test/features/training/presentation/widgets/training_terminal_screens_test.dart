import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_terminal_screens.dart';

import '../../../../helpers/mock_notifications_bloc.dart';

void main() {
  late MockNotificationsBloc notificationsBloc;

  setUp(() {
    notificationsBloc = MockNotificationsBloc();
    whenListen(
      notificationsBloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsState(),
    );
  });

  // GymHeader (usato come appBar da entrambe le schermate) legge
  // BlocBuilder<NotificationsBloc, ...>, quindi serve nell'albero anche se
  // il widget sotto test non ha nulla a che fare con le notifiche.
  Widget buildWithRouter(Widget home) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => BlocProvider<NotificationsBloc>.value(
            value: notificationsBloc,
            child: home,
          ),
        ),
        GoRoute(
          path: '/training',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Training Dashboard'))),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('WorkoutCompletedScreen', () {
    testWidgets('mostra il titolo della routine e il messaggio di successo', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithRouter(const WorkoutCompletedScreen(routineTitle: 'Push Day')),
      );

      expect(find.text('COMPLETATO!'), findsOneWidget);
      expect(find.text('PUSH DAY'), findsOneWidget);
    });

    testWidgets('il tap su "torna alla dashboard" naviga a /training', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithRouter(const WorkoutCompletedScreen(routineTitle: 'Push Day')),
      );

      await tester.tap(find.text('TORNA ALLA DASHBOARD'));
      await tester.pumpAndSettle();

      expect(find.text('Training Dashboard'), findsOneWidget);
    });
  });

  group('EmptyRoutineScreen', () {
    testWidgets('mostra il messaggio di routine vuota', (tester) async {
      await tester.pumpWidget(buildWithRouter(const EmptyRoutineScreen()));

      expect(find.text('Nessun esercizio in questa routine'), findsOneWidget);
    });

    testWidgets('il tap su "torna indietro" naviga a /training', (
      tester,
    ) async {
      await tester.pumpWidget(buildWithRouter(const EmptyRoutineScreen()));

      await tester.tap(find.text('TORNA INDIETRO'));
      await tester.pumpAndSettle();

      expect(find.text('Training Dashboard'), findsOneWidget);
    });
  });
}
