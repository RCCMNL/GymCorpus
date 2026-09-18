import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_page.dart';

import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

/// La scheda di un esercizio tiene uno stato suo - aperta o chiusa, le
/// serie in corso di modifica - che deve restare attaccato a quell'
/// esercizio anche quando la lista cambia sotto.
void main() {
  late MockTrainingBloc bloc;
  late MockNotificationsBloc notificationsBloc;

  RoutineExerciseEntity exercise(int id, String name) {
    return RoutineExerciseEntity(
      id: id,
      routineId: 1,
      exercise: ExerciseEntity(id: id, name: name, targetMuscle: 'Gambe'),
      sets: 1,
      reps: 8,
      weight: 50,
      orderIndex: id - 1,
      setsData: jsonEncode([
        {'weight': 50.0, 'reps': 8},
      ]),
    );
  }

  setUp(() {
    bloc = MockTrainingBloc();
    notificationsBloc = MockNotificationsBloc();
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

  Widget wrap(RoutineEntity routine) {
    return BlocProvider<TrainingBloc>.value(
      value: bloc,
      child: BlocProvider<NotificationsBloc>.value(
        value: notificationsBloc,
        child: MaterialApp(home: WorkoutPage(routineToEdit: routine)),
      ),
    );
  }

  testWidgets('la scheda aperta resta aperta se ne viene rimossa un altra', (
    tester,
  ) async {
    final routine = RoutineEntity(
      id: 1,
      title: 'Gambe',
      createdAt: DateTime(2026),
      exercises: [exercise(1, 'Squat'), exercise(2, 'Affondi')],
    );

    await tester.pumpWidget(wrap(routine));

    // Si apre la scheda degli affondi, la seconda della lista.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).last);
    await tester.pump();
    expect(find.text('AGGIUNGI UNA SERIE'), findsOneWidget);

    // Si elimina lo squat: gli affondi salgono di una posizione.
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Affondi'), findsOneWidget);
    expect(find.text('Squat'), findsNothing);
    expect(
      find.text('AGGIUNGI UNA SERIE'),
      findsOneWidget,
      reason: 'la scheda degli affondi non deve richiudersi da sola',
    );
  });
}
