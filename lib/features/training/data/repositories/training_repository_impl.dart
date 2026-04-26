import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TrainingRepository)
class TrainingRepositoryImpl implements TrainingRepository {
  TrainingRepositoryImpl({required this.database});

  final AppDatabase database;

  @override
  Stream<List<ExerciseEntity>> watchExercises() {
    return database.watchAllExercises().map((exercises) {
      return exercises
          .map(
            (e) => ExerciseEntity(
              id: e.id,
              name: e.name,
              targetMuscle: e.targetMuscle,
              referenceVideoUrl: e.referenceVideoUrl,
              imageUrl: e.imageUrl,
              equipment: e.equipment,
              focusArea: e.focusArea,
              preparation: e.preparation,
              execution: e.execution,
              tips: e.tips,
              userNotes: e.userNotes,
              isVector: e.isVector,
              isFavorite: e.isFavorite,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> toggleExerciseFavorite(
    int id, {
    required bool isFavorite,
  }) async {
    try {
      await database.toggleExerciseFavorite(id, isFavorite: isFavorite);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateExerciseNotes(int id, String notes) async {
    try {
      await database.updateExerciseNotes(id, notes);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<RoutineEntity>> watchRoutines() {
    return database
        .select(database.routines)
        .watch()
        .asyncMap((routinesList) async {
      final routineEntities = <RoutineEntity>[];

      for (final routineData in routinesList) {
        // Get exercises for this routine
        final exercisesQuery = database.select(database.routineExercises).join([
          innerJoin(
            database.exercises,
            database.exercises.id
                .equalsExp(database.routineExercises.exerciseId),
          ),
        ])
          ..where(database.routineExercises.routineId.equals(routineData.id));

        final rows = await exercisesQuery.get();

        final routineExercises = rows.map((row) {
          final reData = row.readTable(database.routineExercises);
          final exData = row.readTable(database.exercises);

          return RoutineExerciseEntity(
            id: reData.id,
            routineId: reData.routineId,
            sets: reData.sets,
            reps: reData.reps,
            weight: reData.weight,
            orderIndex: reData.orderIndex,
            setsData: reData.setsData, // Mapping per JSON serie
            exercise: ExerciseEntity(
              id: exData.id,
              name: exData.name,
              targetMuscle: exData.targetMuscle,
              referenceVideoUrl: exData.referenceVideoUrl,
              imageUrl: exData.imageUrl,
              equipment: exData.equipment,
              focusArea: exData.focusArea,
              preparation: exData.preparation,
              execution: exData.execution,
              tips: exData.tips,
              userNotes: exData.userNotes,
              isVector: exData.isVector,
              isFavorite: exData.isFavorite,
            ),
          );
        }).toList();

        routineEntities.add(
          RoutineEntity(
            id: routineData.id,
            title: routineData.title,
            estimatedDuration: routineData.estimatedDuration,
            createdAt: routineData.createdAt,
            exercises: routineExercises,
          ),
        );
      }

      return routineEntities;
    });
  }

  @override
  Future<Either<Failure, int>> addRoutine(
    String title,
    List<RoutineExerciseEntity> routineExercises,
    int? estDuration,
  ) async {
    try {
      return await database.transaction(() async {
        final routineId = await database.into(database.routines).insert(
              RoutinesCompanion(
                title: Value(title),
                estimatedDuration: Value(estDuration),
                createdAt: Value(DateTime.now()),
              ),
            );

        for (final re in routineExercises) {
          await database.into(database.routineExercises).insert(
                RoutineExercisesCompanion(
                  routineId: Value(routineId),
                  exerciseId: Value(re.exercise.id),
                  sets: Value(re.sets),
                  reps: Value(re.reps),
                  weight: Value(re.weight),
                  orderIndex: Value(re.orderIndex),
                  setsData: Value(re.setsData), // Salvataggio JSON serie
                ),
              );
        }
        return Right(routineId);
      });
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRoutine(
    int id,
    String title,
    List<RoutineExerciseEntity> exercises,
    int? estDuration,
  ) async {
    try {
      await database.transaction(() async {
        // Update routine metadata
        await (database.update(database.routines)
              ..where((t) => t.id.equals(id)))
            .write(
          RoutinesCompanion(
            title: Value(title),
            estimatedDuration: Value(estDuration),
          ),
        );

        // Delete existing exercise associations
        await (database.delete(database.routineExercises)
              ..where((t) => t.routineId.equals(id)))
            .go();

        // Re-insert current exercises
        for (final re in exercises) {
          await database.into(database.routineExercises).insert(
                RoutineExercisesCompanion(
                  routineId: Value(id),
                  exerciseId: Value(re.exercise.id),
                  sets: Value(re.sets),
                  reps: Value(re.reps),
                  weight: Value(re.weight),
                  orderIndex: Value(re.orderIndex),
                  setsData: Value(re.setsData),
                ),
              );
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoutine(int id) async {
    try {
      await database.deleteRoutine(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<WorkoutSetEntity>> watchWeightLogs() {
    return database.watchLatestWeightLogs().map((sets) {
      return sets
          .map(
            (s) => WorkoutSetEntity(
              id: s.id,
              workoutId: s.workoutId,
              exerciseId: s.exerciseId,
              reps: s.reps,
              weight: s.weight,
              rpe: s.rpe,
              timestamp: s.timestamp,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> addSetToExercise({
    required int workoutId,
    required int exerciseId,
    required int reps,
    required double weight,
    int? rpe,
  }) async {
    try {
      if (reps < 0 || weight < 0) {
        return const Left(
          DatabaseFailure('Negative weight or reps are invalid.'),
        );
      }

      await database.insertSet(
        WorkoutSetsCompanion(
          workoutId: Value(workoutId),
          exerciseId: Value(exerciseId),
          reps: Value(reps),
          weight: Value(weight),
          rpe: Value(rpe),
          timestamp: Value(DateTime.now()),
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<BodyWeightLogEntity>> watchBodyWeightLogs() {
    return database.watchLatestWeightEntries().map((logs) {
      return logs
          .map(
            (l) => BodyWeightLogEntity(
              id: l.id,
              weight: l.weight,
              date: l.date,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, int>> addBodyWeightLogEntry(double weight) async {
    try {
      if (!_isValidBodyWeight(weight)) {
        return const Left(
          DatabaseFailure('Il peso deve essere maggiore di 0 e realistico.'),
        );
      }

      final id = await database.insertWeightLog(
        WeightLogsCompanion(
          weight: Value(weight),
          date: Value(DateTime.now()),
        ),
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBodyWeightLogEntry(int id) async {
    try {
      await database.deleteWeightLog(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBodyWeightLogEntry(
    int id,
    double weight,
  ) async {
    try {
      if (!_isValidBodyWeight(weight)) {
        return const Left(
          DatabaseFailure('Il peso deve essere maggiore di 0 e realistico.'),
        );
      }

      await database.updateWeightLog(id, weight);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double?>> reseedWeightHistory() async {
    try {
      await database.deleteAllWeightLogs();

      final now = DateTime.now();
      const baseWeight = 80.0;
      final variations = [
        0.2,
        -0.5,
        0.8,
        -0.3,
        0.1,
        -0.7,
        0.4,
        -0.2,
        0.6,
        -0.1,
      ];

      double? latestWeight;
      for (var i = 0; i < 10; i++) {
        final date = now.subtract(Duration(days: 9 - i));
        final weight = baseWeight + variations[i];
        latestWeight = weight;
        await database.insertWeightLog(
          WeightLogsCompanion(
            weight: Value(weight),
            date: Value(date),
          ),
        );
      }
      return Right(latestWeight);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  bool _isValidBodyWeight(double weight) {
    return weight.isFinite && weight > 0 && weight <= 500;
  }

  @override
  Stream<List<BodyMeasurementEntity>> watchBodyMeasurements() {
    return database.watchAllMeasurements().map((logs) {
      return logs
          .map(
            (l) => BodyMeasurementEntity(
              id: l.id,
              part: l.part,
              value: l.value,
              date: l.date,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, int>> addBodyMeasurement(
    String part,
    double value,
  ) async {
    try {
      final id = await database.insertMeasurement(
        BodyMeasurementsCompanion(
          part: Value(part),
          value: Value(value),
          date: Value(DateTime.now()),
        ),
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBodyMeasurement(int id) async {
    try {
      await database.deleteMeasurement(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBodyMeasurement(
    int id,
    double value,
  ) async {
    try {
      await database.updateMeasurement(id, value);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<String?> watchPreference(String key) {
    return database.watchSetting(key);
  }

  @override
  Stream<Map<String, String>> watchAllSettings() {
    return database.watchAllSettings().map((settings) {
      return {for (final s in settings) s.key: s.value};
    });
  }

  @override
  Future<Either<Failure, void>> updatePreference(
    String key,
    String value,
  ) async {
    try {
      await database.updateSetting(key, value);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // --- Cardio Sessions ---
  @override
  Stream<List<CardioSessionEntity>> watchCardioSessions() {
    return database.watchAllCardioSessions().map((sessions) {
      return sessions
          .map(
            (s) => CardioSessionEntity(
              id: s.id,
              type: s.type,
              distance: s.distance,
              duration: s.duration,
              avgSpeed: s.avgSpeed,
              pace: s.pace,
              calories: s.calories,
              routeJson: s.routeJson,
              date: s.date,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, int>> addCardioSession({
    required String type,
    required double distance,
    required int duration,
    required double avgSpeed,
    required String pace,
    required int calories,
    String? routeJson,
  }) async {
    try {
      final id = await database.insertCardioSession(
        CardioSessionsCompanion(
          type: Value(type),
          distance: Value(distance),
          duration: Value(duration),
          avgSpeed: Value(avgSpeed),
          pace: Value(pace),
          calories: Value(calories),
          routeJson: Value(routeJson),
          date: Value(DateTime.now()),
        ),
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCardioSession(int id) async {
    try {
      await database.deleteCardioSession(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
