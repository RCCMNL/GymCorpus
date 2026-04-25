import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
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
    when(() => mockRepository.watchExercises()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchRoutines()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchWeightLogs()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchBodyWeightLogs()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchAllSettings()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchCardioSessions()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchBodyMeasurements()).thenAnswer((_) => const Stream.empty());

    bloc = TrainingBloc(repository: mockRepository, authRepository: mockAuthRepository);
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
        isA<TrainingLoaded>().having((s) => s.lastEstimated1RM, 'last estimated', closeTo(112.5, 0.1)),
      ],
    );
  });
}
