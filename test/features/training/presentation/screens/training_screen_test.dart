import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Arrivano con flutter_local_notifications, che e' una dipendenza diretta:
// servono per sostituire il plugin, che nei test non e' registrato.
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_screen.dart';

// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

/// Registra le notifiche annullate, al posto del plugin vero che nei test
/// non esiste.
class _RecordingNotificationsPlatform extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  final List<String> calls = [];

  @override
  Future<void> cancel(int id) async => calls.add('cancel:$id');

  @override
  Future<void> cancelAll() async => calls.add('cancelAll');
}

/// Un allenamento in corso non deve poter sparire con un tocco distratto
/// sul tasto indietro, e uscendo non deve portarsi via le notifiche di
/// tutta l'app.
void main() {
  late MockTrainingBloc bloc;
  late MockNotificationsBloc notificationsBloc;
  late _RecordingNotificationsPlatform notifications;

  setUp(() {
    bloc = MockTrainingBloc();
    notificationsBloc = MockNotificationsBloc();
    notifications = _RecordingNotificationsPlatform();
    FlutterLocalNotificationsPlatform.instance = notifications;
    whenListen(
      bloc,
      const Stream<TrainingState>.empty(),
      initialState: const TrainingState.loaded(exercises: []),
    );
    whenListen(
      notificationsBloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsState(),
    );
  });

  final routine = RoutineEntity(
    id: 1,
    title: 'Gambe',
    createdAt: DateTime(2026),
    exercises: const [
      RoutineExerciseEntity(
        id: 1,
        routineId: 1,
        exercise: ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Gambe'),
        sets: 3,
        reps: 10,
        weight: 60,
        orderIndex: 0,
      ),
    ],
  );

  Future<void> pumpScreen(WidgetTester tester, {RoutineEntity? withRoutine}) {
    return tester.pumpWidget(
      BlocProvider<TrainingBloc>.value(
        value: bloc,
        child: BlocProvider<NotificationsBloc>.value(
          value: notificationsBloc,
          child: MaterialApp(home: TrainingScreen(routine: withRoutine)),
        ),
      ),
    );
  }

  testWidgets('il tasto indietro chiede conferma invece di uscire', (
    tester,
  ) async {
    await pumpScreen(tester, withRoutine: routine);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Terminare l allenamento?'), findsOneWidget);
  });

  testWidgets('senza esercizi non c e niente da confermare', (tester) async {
    await pumpScreen(tester);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Terminare l allenamento?'), findsNothing);
  });

  testWidgets('uscendo annulla il proprio avviso, non tutte le notifiche', (
    tester,
  ) async {
    await pumpScreen(tester, withRoutine: routine);

    // Smonta la schermata come farebbe l'uscita dall'allenamento.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();

    expect(
      notifications.calls,
      isNot(contains('cancelAll')),
      reason: 'i promemoria dell app non c entrano con questo allenamento',
    );
  });
}
