import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

void main() {
  late MockTrainingRepository mockRepository;
  late TrainingBloc bloc;

  setUp(() {
    mockRepository = MockTrainingRepository();
    bloc = TrainingBloc(repository: mockRepository);
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
      'emette [TrainingLoading, TrainingLoaded] quando load event ha successo',
      build: () {
        when(() => mockRepository.watchExercises())
            .thenAnswer((_) => Stream.value(tExercises));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadExercisesEvent()),
      expect: () => [
        isA<TrainingLoading>(),
        TrainingLoaded(exercises: tExercises),
      ],
    );

    blocTest<TrainingBloc, TrainingState>(
      'aggiorna il lastEstimated1RM quando aggiungi un Set con RPE > 8',
      build: () {
        when(() => mockRepository.watchExercises())
            .thenAnswer((_) => Stream.value(tExercises));
        when(() => mockRepository.addSetToExercise(
              workoutId: 1,
              exerciseId: 1,
              reps: 5,
              weight: 100,
              rpe: 9,
            )).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TrainingLoaded(exercises: tExercises), // Start State Ready
      act: (bloc) => bloc.add(const AddSetToExercise(
        workoutId: 1, exerciseId: 1, reps: 5, weight: 100, rpe: 9,
      )),
      expect: () => [
        // La formula stima ~112.5 per 100kgx5 reps
        isA<TrainingLoaded>().having((s) => s.lastEstimated1RM, 'last estimated', closeTo(112.5, 0.1)),
      ],
    );
  });
}
