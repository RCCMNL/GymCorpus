import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:mocktail/mocktail.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockTrainingRepository mockRepository;
  late MockAuthRepository mockAuthRepository;
  late TrainingBloc bloc;

  setUp(() {
    mockRepository = MockTrainingRepository();
    mockAuthRepository = MockAuthRepository();

    // Default stubs to prevent 'Null is not a subtype of Stream' errors
    when(
      () => mockRepository.watchExercises(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchRoutines(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchWeightLogs(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchWorkoutSessions(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchBodyWeightLogs(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchAllSettings(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchCardioSessions(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchBodyMeasurements(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAuthRepository.updateProfileDetails(
        firstName: any<String?>(named: 'firstName'),
        lastName: any<String?>(named: 'lastName'),
        username: any<String?>(named: 'username'),
        gender: any<String?>(named: 'gender'),
        weight: any<double?>(named: 'weight'),
        height: any<double?>(named: 'height'),
        birthDate: any<DateTime?>(named: 'birthDate'),
        trainingObjective: any<String?>(named: 'trainingObjective'),
        clearWeight: any<bool>(named: 'clearWeight'),
      ),
    ).thenAnswer(
      (_) async =>
          const Right(UserEntity(id: 'user-1', email: 'test@example.com')),
    );

    bloc = TrainingBloc(
      repository: mockRepository,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('TrainingBloc', () {
    final tExercises = [
      const ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Legs'),
      const ExerciseEntity(id: 2, name: 'Bench Press', targetMuscle: 'Chest'),
    ];

    test('lo stato iniziale è TrainingLoading', () {
      expect(bloc.state, isA<TrainingLoading>());
    });

    group('errori di scrittura', () {
      blocTest<TrainingBloc, TrainingState>(
        'una scrittura fallita non cancella i dati gia caricati',
        build: () {
          when(
            () => mockRepository.toggleExerciseFavorite(1, isFavorite: true),
          ).thenAnswer(
            (_) async => const Left(DatabaseFailure('database bloccato')),
          );
          return bloc;
        },
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) =>
            bloc.add(const ToggleExerciseFavoriteEvent(1, isFavorite: true)),
        expect: () => [
          TrainingLoaded(
            exercises: tExercises,
            actionError: 'database bloccato',
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as TrainingLoaded;
          expect(
            state.exercises,
            tExercises,
            reason: 'la lista esercizi deve sopravvivere al fallimento',
          );
        },
      );

      blocTest<TrainingBloc, TrainingState>(
        'senza dati caricati il fallimento emette ancora TrainingError',
        build: () {
          when(() => mockRepository.deleteRoutine(7)).thenAnswer(
            (_) async => const Left(DatabaseFailure('routine inesistente')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteRoutineEvent(7)),
        expect: () => [const TrainingError('routine inesistente')],
      );

      blocTest<TrainingBloc, TrainingState>(
        'ClearActionErrorEvent azzera solo l errore, non i dati',
        build: () => bloc,
        seed: () => TrainingLoaded(
          exercises: tExercises,
          actionError: 'database bloccato',
        ),
        act: (bloc) => bloc.add(const ClearActionErrorEvent()),
        expect: () => [TrainingLoaded(exercises: tExercises)],
      );

      blocTest<TrainingBloc, TrainingState>(
        'ClearActionErrorEvent non emette nulla se non ci sono errori',
        build: () => bloc,
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) => bloc.add(const ClearActionErrorEvent()),
        expect: () => <TrainingState>[],
      );
    });

    group('esercizi custom', () {
      blocTest<TrainingBloc, TrainingState>(
        'AddCustomExerciseEvent chiama il repository con i campi corretti',
        build: () {
          when(
            () => mockRepository.addCustomExercise(
              name: 'Curl con elastici corti',
              targetMuscle: 'Bicipiti',
              difficulty: 'Principiante',
              equipment: 'Elastici',
            ),
          ).thenAnswer((_) async => const Right(999));
          return bloc;
        },
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) => bloc.add(
          const AddCustomExerciseEvent(
            name: 'Curl con elastici corti',
            targetMuscle: 'Bicipiti',
            difficulty: 'Principiante',
            equipment: 'Elastici',
          ),
        ),
        verify: (_) {
          verify(
            () => mockRepository.addCustomExercise(
              name: 'Curl con elastici corti',
              targetMuscle: 'Bicipiti',
              difficulty: 'Principiante',
              equipment: 'Elastici',
            ),
          ).called(1);
        },
      );

      blocTest<TrainingBloc, TrainingState>(
        'AddCustomExerciseEvent fallito mostra actionError senza perdere i dati',
        build: () {
          when(
            () => mockRepository.addCustomExercise(
              name: any(named: 'name'),
              targetMuscle: any(named: 'targetMuscle'),
              difficulty: any(named: 'difficulty'),
              equipment: any(named: 'equipment'),
              focusArea: any(named: 'focusArea'),
              preparation: any(named: 'preparation'),
              execution: any(named: 'execution'),
              tips: any(named: 'tips'),
              isBodyweight: any(named: 'isBodyweight'),
            ),
          ).thenAnswer((_) async => const Left(DatabaseFailure('errore db')));
          return bloc;
        },
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) => bloc.add(
          const AddCustomExerciseEvent(
            name: 'Nuovo',
            targetMuscle: 'Petto',
            difficulty: 'Intermedio',
          ),
        ),
        expect: () => [
          TrainingLoaded(exercises: tExercises, actionError: 'errore db'),
        ],
      );

      blocTest<TrainingBloc, TrainingState>(
        'UpdateCustomExerciseEvent chiama il repository con id e campi corretti',
        build: () {
          when(
            () => mockRepository.updateCustomExercise(
              id: 5,
              name: 'Curl aggiornato',
              targetMuscle: 'Bicipiti',
              difficulty: 'Avanzato',
            ),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) => bloc.add(
          const UpdateCustomExerciseEvent(
            id: 5,
            name: 'Curl aggiornato',
            targetMuscle: 'Bicipiti',
            difficulty: 'Avanzato',
          ),
        ),
        verify: (_) {
          verify(
            () => mockRepository.updateCustomExercise(
              id: 5,
              name: 'Curl aggiornato',
              targetMuscle: 'Bicipiti',
              difficulty: 'Avanzato',
            ),
          ).called(1);
        },
      );

      blocTest<TrainingBloc, TrainingState>(
        'DeleteCustomExerciseEvent chiama il repository con l id corretto',
        build: () {
          when(
            () => mockRepository.deleteCustomExercise(5),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) => bloc.add(const DeleteCustomExerciseEvent(5)),
        verify: (_) {
          verify(() => mockRepository.deleteCustomExercise(5)).called(1);
        },
      );

      blocTest<TrainingBloc, TrainingState>(
        'DeleteCustomExerciseEvent bloccato mostra il messaggio del repository',
        build: () {
          when(() => mockRepository.deleteCustomExercise(5)).thenAnswer(
            (_) async => const Left(
              DatabaseFailure(
                'Questo esercizio è usato in una routine o in un allenamento registrato.',
              ),
            ),
          );
          return bloc;
        },
        seed: () => TrainingLoaded(exercises: tExercises),
        act: (bloc) => bloc.add(const DeleteCustomExerciseEvent(5)),
        expect: () => [
          TrainingLoaded(
            exercises: tExercises,
            actionError:
                'Questo esercizio è usato in una routine o in un allenamento registrato.',
          ),
        ],
      );
    });

    blocTest<TrainingBloc, TrainingState>(
      'emette [TrainingLoaded] quando load event ha successo',
      build: () {
        when(
          () => mockRepository.watchExercises(),
        ).thenAnswer((_) => Stream.value(tExercises));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadExercisesEvent()),
      expect: () => [TrainingLoaded(exercises: tExercises)],
    );

    blocTest<TrainingBloc, TrainingState>(
      'aggiorna le sessioni workout completate dallo stream repository',
      build: () {
        final sessions = [
          WorkoutSessionEntity(
            id: 1,
            date: DateTime(2026, 4, 26),
            name: 'Push',
            completedAt: DateTime(2026, 4, 26, 11),
            durationSeconds: 3600,
          ),
        ];
        when(
          () => mockRepository.watchWorkoutSessions(),
        ).thenAnswer((_) => Stream.value(sessions));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadWorkoutSessionsEvent()),
      expect: () => [
        isA<TrainingLoaded>().having(
          (state) => state.workoutSessions.single.name,
          'session name',
          'Push',
        ),
      ],
    );

    blocTest<TrainingBloc, TrainingState>(
      'inoltra start e complete della workout session al repository',
      build: () {
        when(
          () => mockRepository.startWorkoutSession(
            id: 100,
            name: 'Push',
            routineId: 7,
          ),
        ).thenAnswer((_) async => const Right(100));
        when(
          () => mockRepository.completeWorkoutSession(
            workoutId: 100,
            durationSeconds: 1800,
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => const TrainingLoaded(exercises: []),
      act: (bloc) {
        bloc
          ..add(
            const StartWorkoutSessionEvent(id: 100, name: 'Push', routineId: 7),
          )
          ..add(
            const CompleteWorkoutSessionEvent(
              workoutId: 100,
              durationSeconds: 1800,
            ),
          );
      },
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockRepository.startWorkoutSession(
            id: 100,
            name: 'Push',
            routineId: 7,
          ),
        ).called(1);
        verify(
          () => mockRepository.completeWorkoutSession(
            workoutId: 100,
            durationSeconds: 1800,
          ),
        ).called(1);
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'aggiorna il lastEstimated1RM quando aggiungi un Set con RPE > 8',
      build: () {
        when(
          () => mockRepository.watchExercises(),
        ).thenAnswer((_) => Stream.value(tExercises));
        when(
          () => mockRepository.addSetToExercise(
            workoutId: 1,
            exerciseId: 1,
            reps: 5,
            weight: 100,
            rpe: 9,
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(exercises: tExercises), // Start State Ready
      act: (bloc) => bloc.add(
        const AddSetToExercise(
          workoutId: 1,
          exerciseId: 1,
          reps: 5,
          weight: 100,
          rpe: 9,
        ),
      ),
      expect: () => [
        // La formula stima ~112.5 per 100kgx5 reps
        isA<TrainingLoaded>().having(
          (s) => s.lastEstimated1RM,
          'last estimated',
          closeTo(112.5, 0.1),
        ),
      ],
    );

    blocTest<TrainingBloc, TrainingState>(
      'sincronizza il profilo quando aggiungi un peso corporeo',
      build: () {
        when(
          () => mockRepository.addBodyWeightLogEntry(82),
        ).thenAnswer((_) async => const Right(1));
        return bloc;
      },
      seed: () => const TrainingLoaded(exercises: []),
      act: (bloc) => bloc.add(const AddBodyWeightLogEvent(82)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(weight: 82),
        ).called(1);
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'non sincronizza il profilo se il salvataggio peso fallisce',
      build: () {
        when(() => mockRepository.addBodyWeightLogEntry(-1)).thenAnswer(
          (_) async => const Left(DatabaseFailure('Peso non valido')),
        );
        return bloc;
      },
      seed: () => const TrainingLoaded(exercises: []),
      act: (bloc) => bloc.add(const AddBodyWeightLogEvent(-1)),
      // Il fallimento di una singola scrittura non deve distruggere lo stato
      // gia' caricato: viaggia come errore transitorio dentro TrainingLoaded.
      expect: () => [
        const TrainingLoaded(exercises: [], actionError: 'Peso non valido'),
      ],
      verify: (_) {
        verifyNever(
          () => mockAuthRepository.updateProfileDetails(
            weight: any<double?>(named: 'weight'),
            clearWeight: any<bool>(named: 'clearWeight'),
          ),
        );
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'sincronizza il profilo quando modifichi il peso piu recente',
      build: () {
        when(
          () => mockRepository.updateBodyWeightLogEntry(2, 83),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(id: 2, weight: 82, date: DateTime(2026, 4, 25)),
          BodyWeightLogEntity(id: 1, weight: 81, date: DateTime(2026, 4, 24)),
        ],
      ),
      act: (bloc) => bloc.add(const UpdateBodyWeightLogEvent(2, 83)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(weight: 83),
        ).called(1);
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'non sincronizza il profilo quando modifichi un peso storico',
      build: () {
        when(
          () => mockRepository.updateBodyWeightLogEntry(1, 80),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(id: 2, weight: 82, date: DateTime(2026, 4, 25)),
          BodyWeightLogEntity(id: 1, weight: 81, date: DateTime(2026, 4, 24)),
        ],
      ),
      act: (bloc) => bloc.add(const UpdateBodyWeightLogEvent(1, 80)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verifyNever(
          () => mockAuthRepository.updateProfileDetails(
            weight: any<double?>(named: 'weight'),
            clearWeight: any<bool>(named: 'clearWeight'),
          ),
        );
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'sincronizza il profilo con il peso precedente quando elimini il piu recente',
      build: () {
        when(
          () => mockRepository.deleteBodyWeightLogEntry(2),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(id: 2, weight: 82, date: DateTime(2026, 4, 25)),
          BodyWeightLogEntity(id: 1, weight: 81, date: DateTime(2026, 4, 24)),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteBodyWeightLogEvent(2)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(weight: 81),
        ).called(1);
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'cancella il peso profilo quando elimini ultimo log corporeo',
      build: () {
        when(
          () => mockRepository.deleteBodyWeightLogEntry(1),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(id: 1, weight: 81, date: DateTime(2026, 4, 24)),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteBodyWeightLogEvent(1)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(clearWeight: true),
        ).called(1);
      },
    );
  });
}
