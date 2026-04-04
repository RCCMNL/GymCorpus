import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class TrainingRepository {
  Stream<List<ExerciseEntity>> watchExercises();
  Future<Either<Failure, void>> toggleExerciseFavorite(int id, bool isFavorite);
  
  // Routines CRUD
  Stream<List<RoutineEntity>> watchRoutines();
  Future<Either<Failure, int>> addRoutine(String title, List<RoutineExerciseEntity> exercises, int? estDuration);
  Future<Either<Failure, void>> updateRoutine(int id, String title, List<RoutineExerciseEntity> exercises, int? estDuration);
  Future<Either<Failure, void>> deleteRoutine(int id);

  Stream<List<WorkoutSetEntity>> watchWeightLogs();

  Future<Either<Failure, void>> addSetToExercise({
    required int workoutId,
    required int exerciseId,
    required int reps,
    required double weight,
    int? rpe,
  });

  // Body weight entries
  Stream<List<BodyWeightLogEntity>> watchBodyWeightLogs();
  Future<Either<Failure, int>> addBodyWeightLogEntry(double weight);

  // App preferences
  Stream<String?> watchPreference(String key);
  Stream<Map<String, String>> watchAllSettings();
  Future<Either<Failure, void>> updatePreference(String key, String value);
}
