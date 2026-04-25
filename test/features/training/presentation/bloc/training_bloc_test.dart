import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
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
    when(() => mockRepository.watchExercises())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchRoutines())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchWeightLogs())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchBodyWeightLogs())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchAllSettings())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchCardioSessions())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchBodyMeasurements())
        .thenAnswer((_) => const Stream.empty());
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
      (_) async => const Right(
        UserEntity(id: 'user-1', email: 'test@example.com'),
      ),
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

    blocTest<TrainingBloc, TrainingState>(
      'emette [TrainingLoaded] quando load event ha successo',
      build: () {
        when(() => mockRepository.watchExercises())
            .thenAnswer((_) => Stream.value(tExercises));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadExercisesEvent()),
      expect: () => [
        TrainingLoaded(exercises: tExercises),
      ],
    );

    blocTest<TrainingBloc, TrainingState>(
      'aggiorna il lastEstimated1RM quando aggiungi un Set con RPE > 8',
      build: () {
        when(() => mockRepository.watchExercises())
            .thenAnswer((_) => Stream.value(tExercises));
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
        when(() => mockRepository.addBodyWeightLogEntry(82))
            .thenAnswer((_) async => const Right(1));
        return bloc;
      },
      seed: () => const TrainingLoaded(exercises: []),
      act: (bloc) => bloc.add(const AddBodyWeightLogEvent(82)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(
            weight: 82,
          ),
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
      expect: () => [
        const TrainingError('Peso non valido'),
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
        when(() => mockRepository.updateBodyWeightLogEntry(2, 83))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(
            id: 2,
            weight: 82,
            date: DateTime(2026, 4, 25),
          ),
          BodyWeightLogEntity(
            id: 1,
            weight: 81,
            date: DateTime(2026, 4, 24),
          ),
        ],
      ),
      act: (bloc) => bloc.add(const UpdateBodyWeightLogEvent(2, 83)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(
            weight: 83,
          ),
        ).called(1);
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'non sincronizza il profilo quando modifichi un peso storico',
      build: () {
        when(() => mockRepository.updateBodyWeightLogEntry(1, 80))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(
            id: 2,
            weight: 82,
            date: DateTime(2026, 4, 25),
          ),
          BodyWeightLogEntity(
            id: 1,
            weight: 81,
            date: DateTime(2026, 4, 24),
          ),
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
        when(() => mockRepository.deleteBodyWeightLogEntry(2))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(
            id: 2,
            weight: 82,
            date: DateTime(2026, 4, 25),
          ),
          BodyWeightLogEntity(
            id: 1,
            weight: 81,
            date: DateTime(2026, 4, 24),
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteBodyWeightLogEvent(2)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(
            weight: 81,
          ),
        ).called(1);
      },
    );

    blocTest<TrainingBloc, TrainingState>(
      'cancella il peso profilo quando elimini ultimo log corporeo',
      build: () {
        when(() => mockRepository.deleteBodyWeightLogEntry(1))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(
        exercises: const [],
        bodyWeightLogs: [
          BodyWeightLogEntity(
            id: 1,
            weight: 81,
            date: DateTime(2026, 4, 24),
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteBodyWeightLogEvent(1)),
      expect: () => <TrainingState>[],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateProfileDetails(
            clearWeight: true,
          ),
        ).called(1);
      },
    );
  });
}
