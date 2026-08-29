import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_detail_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

void main() {
  late MockTrainingBloc bloc;
  late MockNotificationsBloc notificationsBloc;

  const exercise = ExerciseEntity(
    id: 1,
    name: 'Goblet Squat',
    targetMuscle: 'Gambe',
  );
  const routineExercise = RoutineExerciseEntity(
    id: 1,
    routineId: 1,
    exercise: exercise,
    sets: 3,
    reps: 12,
    weight: 0,
    orderIndex: 0,
  );

  final systemRoutine = RoutineEntity(
    id: 1,
    title: 'Full Body – Principianti',
    createdAt: DateTime(2026),
    isSystem: true,
    exercises: const [routineExercise],
  );

  final userRoutine = RoutineEntity(
    id: 2,
    title: 'La mia routine',
    createdAt: DateTime(2026),
    exercises: const [routineExercise],
  );

  setUp(() {
    bloc = MockTrainingBloc();
    notificationsBloc = MockNotificationsBloc();
    whenListen(
      notificationsBloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsState(),
    );
  });

  Widget wrap(RoutineEntity routine, TrainingState state) {
    whenListen(bloc, const Stream<TrainingState>.empty(), initialState: state);
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: BlocProvider<NotificationsBloc>.value(
        value: notificationsBloc,
        child: MaterialApp(home: WorkoutDetailScreen(routine: routine)),
      ),
    );
  }

  testWidgets(
    'una routine di sistema nasconde il menu azioni e mostra il pulsante '
    'Copia',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          systemRoutine,
          TrainingLoaded(exercises: const [], routines: [systemRoutine]),
        ),
      );

      expect(find.text('DI SISTEMA'), findsOneWidget);
      expect(find.text('COPIA QUESTA ROUTINE'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
    },
  );

  testWidgets(
    'una routine utente mostra il menu azioni completo e nessun pulsante '
    'Copia',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          userRoutine,
          TrainingLoaded(exercises: const [], routines: [userRoutine]),
        ),
      );

      expect(find.text('DI SISTEMA'), findsNothing);
      expect(find.text('COPIA QUESTA ROUTINE'), findsNothing);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    },
  );

  testWidgets('toccare "Copia questa routine" invia CopyRoutineEvent', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        systemRoutine,
        TrainingLoaded(exercises: const [], routines: [systemRoutine]),
      ),
    );

    await tester.tap(find.text('COPIA QUESTA ROUTINE'));
    await tester.pump();

    // context.pop() dopo la copia lancia GoError (nessun GoRouter nel test,
    // stesso pattern gia' usato in custom_exercise_form_screen_test.dart):
    // e' l'errore atteso, non un fallimento.
    expect(tester.takeException(), isNotNull);

    verify(() => bloc.add(const CopyRoutineEvent(1))).called(1);
  });
}
