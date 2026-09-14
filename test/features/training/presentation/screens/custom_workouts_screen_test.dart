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
import 'package:gym_corpus/features/training/presentation/screens/custom_workouts_screen.dart';
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

  final systemRoutine = RoutineEntity(
    id: 1,
    title: 'Full Body – Principianti',
    createdAt: DateTime(2026),
    isSystem: true,
    exercises: const [
      RoutineExerciseEntity(
        id: 1,
        routineId: 1,
        exercise: exercise,
        sets: 3,
        reps: 12,
        weight: 0,
        orderIndex: 0,
      ),
    ],
  );

  final userRoutine = RoutineEntity(
    id: 2,
    title: 'La mia routine',
    createdAt: DateTime(2026),
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

  Widget wrap(TrainingState state) {
    whenListen(bloc, const Stream<TrainingState>.empty(), initialState: state);
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: BlocProvider<NotificationsBloc>.value(
        value: notificationsBloc,
        child: const MaterialApp(home: CustomWorkoutsScreen()),
      ),
    );
  }

  testWidgets(
    'mostra "Routine consigliate" sopra "I tuoi workout" quando ci sono '
    'routine di sistema',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          TrainingLoaded(
            exercises: const [],
            routines: [systemRoutine, userRoutine],
          ),
        ),
      );

      expect(find.text('Routine consigliate'), findsOneWidget);
      expect(find.text('I tuoi workout'), findsOneWidget);
      expect(find.text(systemRoutine.title), findsOneWidget);
      expect(find.text(userRoutine.title), findsOneWidget);
    },
  );

  testWidgets(
    'non mostra "Routine consigliate" se non ci sono routine di sistema',
    (tester) async {
      await tester.pumpWidget(
        wrap(TrainingLoaded(exercises: const [], routines: [userRoutine])),
      );

      expect(find.text('Routine consigliate'), findsNothing);
    },
  );

  testWidgets(
    'la card di una routine di sistema mostra solo l azione copia, non '
    'modifica/elimina',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          TrainingLoaded(
            exercises: const [],
            routines: [systemRoutine, userRoutine],
          ),
        ),
      );

      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget); // solo utente
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget); // solo utente
    },
  );

  testWidgets('toccare "Copia" invia CopyRoutineEvent e mostra la conferma', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TrainingLoaded(exercises: const [], routines: [systemRoutine])),
    );

    await tester.tap(find.byIcon(Icons.content_copy_rounded));
    await tester.pump();

    verify(() => bloc.add(const CopyRoutineEvent(1))).called(1);
    expect(find.text('Routine copiata in "I tuoi workout"'), findsOneWidget);
  });
}
