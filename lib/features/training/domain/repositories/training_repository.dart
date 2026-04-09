import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

abstract class TrainingRepository {
  Stream<List<ExerciseEntity>> watchExercises();
  Future<Either<Failure, void>> toggleExerciseFavorite(int id,
      {required bool isFavorite});

  // Routines CRUD
  Stream<List<RoutineEntity>> watchRoutines();
  Future<Either<Failure, int>> addRoutine(
      String title, List<RoutineExerciseEntity> exercises, int? estDuration);
  Future<Either<Failure, void>> updateRoutine(int id, String title,
      List<RoutineExerciseEntity> exercises, int? estDuration);
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
  Future<Either<Failure, void>> deleteBodyWeightLogEntry(int id);
  Future<Either<Failure, void>> updateBodyWeightLogEntry(int id, double weight);
  Future<Either<Failure, void>> reseedWeightHistory();

  // Body measurements
  Stream<List<BodyMeasurementEntity>> watchBodyMeasurements();
  Future<Either<Failure, int>> addBodyMeasurement(String part, double value);
  Future<Either<Failure, void>> deleteBodyMeasurement(int id);
  Future<Either<Failure, void>> updateBodyMeasurement(int id, double value);

  // Cardio sessions
  Stream<List<CardioSessionEntity>> watchCardioSessions();
  Future<Either<Failure, int>> addCardioSession({
    required String type,
    required double distance,
    required int duration,
    required double avgSpeed,
    required String pace,
    required int calories,
    String? routeJson,
  });
  Future<Either<Failure, void>> deleteCardioSession(int id);

  // App preferences
  Stream<String?> watchPreference(String key);
  Stream<Map<String, String>> watchAllSettings();
  Future<Either<Failure, void>> updatePreference(String key, String value);
}
