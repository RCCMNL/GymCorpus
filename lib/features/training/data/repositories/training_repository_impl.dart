import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';
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
              isBodyweight: e.isBodyweight,
              isVector: e.isVector,
              isFavorite: e.isFavorite,
              difficulty: e.difficulty,
              isCustom: e.isCustom,
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
  Future<Either<Failure, void>> updateExerciseNotes(
    int id,
    String notes,
  ) async {
    try {
      await database.updateExerciseNotes(id, notes);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> addCustomExercise({
    required String name,
    required String targetMuscle,
    required String difficulty,
    String? equipment,
    String? focusArea,
    String? preparation,
    String? execution,
    String? tips,
    bool isBodyweight = false,
  }) async {
    try {
      if (await _nameExistsInMuscleGroup(name, targetMuscle)) {
        return Left(
          DatabaseFailure(
            'Esiste già un esercizio chiamato "$name" in $targetMuscle.',
          ),
        );
      }

      final id = await database
          .into(database.exercises)
          .insert(
            ExercisesCompanion(
              name: Value(name),
              targetMuscle: Value(targetMuscle),
              difficulty: Value(difficulty),
              equipment: Value(equipment),
              focusArea: Value(focusArea),
              preparation: Value(preparation),
              execution: Value(execution),
              tips: Value(tips),
              isBodyweight: Value(isBodyweight),
              isCustom: const Value(true),
            ),
          );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomExercise({
    required int id,
    required String name,
    required String targetMuscle,
    required String difficulty,
    String? equipment,
    String? focusArea,
    String? preparation,
    String? execution,
    String? tips,
    bool isBodyweight = false,
  }) async {
    try {
      final guardFailure = await _requireCustomExercise(
        id,
        action: 'modificare',
      );
      if (guardFailure != null) return Left(guardFailure);

      if (await _nameExistsInMuscleGroup(name, targetMuscle, excludeId: id)) {
        return Left(
          DatabaseFailure(
            'Esiste già un esercizio chiamato "$name" in $targetMuscle.',
          ),
        );
      }

      await (database.update(
        database.exercises,
      )..where((e) => e.id.equals(id))).write(
        ExercisesCompanion(
          name: Value(name),
          targetMuscle: Value(targetMuscle),
          difficulty: Value(difficulty),
          equipment: Value(equipment),
          focusArea: Value(focusArea),
          preparation: Value(preparation),
          execution: Value(execution),
          tips: Value(tips),
          isBodyweight: Value(isBodyweight),
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomExercise(int id) async {
    try {
      final guardFailure = await _requireCustomExercise(
        id,
        action: 'eliminare',
      );
      if (guardFailure != null) return Left(guardFailure);

      final inRoutine = await (database.select(
        database.routineExercises,
      )..where((t) => t.exerciseId.equals(id))).get();
      final inHistory = await (database.select(
        database.workoutSets,
      )..where((t) => t.exerciseId.equals(id))).get();
      if (inRoutine.isNotEmpty || inHistory.isNotEmpty) {
        return const Left(
          DatabaseFailure(
            'Questo esercizio è usato in una routine o in un allenamento '
            'registrato. Rimuovilo da lì prima di eliminarlo.',
          ),
        );
      }

      await (database.delete(
        database.exercises,
      )..where((e) => e.id.equals(id))).go();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Controlla se un altro esercizio (predefinito o custom) ha già lo
  /// stesso nome nello stesso gruppo muscolare. Nomi uguali in gruppi
  /// diversi sono ammessi (succede anche nella libreria predefinita, es.
  /// "Face Pull" compare sia in Dorso che in Spalle come esercizio
  /// diverso), qui si evita solo la confusione di due voci identiche
  /// nella stessa sezione della lista esercizi.
  Future<bool> _nameExistsInMuscleGroup(
    String name,
    String targetMuscle, {
    int? excludeId,
  }) async {
    final normalized = name.trim().toLowerCase();
    final sameGroup = await (database.select(
      database.exercises,
    )..where((e) => e.targetMuscle.equals(targetMuscle))).get();
    return sameGroup.any(
      (e) => e.id != excludeId && e.name.trim().toLowerCase() == normalized,
    );
  }

  /// Verifica che l'esercizio [id] esista e sia stato creato dall'utente:
  /// gli esercizi della libreria predefinita non sono mai modificabili o
  /// eliminabili. Ritorna il fallimento da restituire, oppure `null` se il
  /// controllo passa.
  Future<DatabaseFailure?> _requireCustomExercise(
    int id, {
    required String action,
  }) async {
    final existing = await (database.select(
      database.exercises,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (existing == null || !existing.isCustom) {
      return DatabaseFailure('Impossibile $action un esercizio predefinito.');
    }
    return null;
  }

  @override
  Stream<List<RoutineEntity>> watchRoutines() {
    return database.select(database.routines).watch().asyncMap((
      routinesList,
    ) async {
      final routineEntities = <RoutineEntity>[];

      for (final routineData in routinesList) {
        // Get exercises for this routine
        final exercisesQuery = database.select(database.routineExercises).join([
          innerJoin(
            database.exercises,
            database.exercises.id.equalsExp(
              database.routineExercises.exerciseId,
            ),
          ),
        ])
          ..where(database.routineExercises.routineId.equals(routineData.id))
          // L'ordine e' un dato della routine, non l'ordine in cui il
          // database restituisce le righe: senza questo, l'ordine degli
          // esercizi dipendeva da come erano stati scritti.
          ..orderBy([
            OrderingTerm(expression: database.routineExercises.orderIndex),
          ]);

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
              isBodyweight: exData.isBodyweight,
              isVector: exData.isVector,
              isFavorite: exData.isFavorite,
              difficulty: exData.difficulty,
              isCustom: exData.isCustom,
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
            isSystem: routineData.isSystem,
            sourceRoutineId: routineData.sourceRoutineId,
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
        final routineId = await database
            .into(database.routines)
            .insert(
              RoutinesCompanion(
                title: Value(title),
                estimatedDuration: Value(estDuration),
                createdAt: Value(DateTime.now()),
              ),
            );

        for (final re in routineExercises) {
          await database
              .into(database.routineExercises)
              .insert(
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
      final guardFailure = await _requireNonSystemRoutine(
        id,
        action: 'modificare',
      );
      if (guardFailure != null) return Left(guardFailure);

      await database.transaction(() async {
        // Update routine metadata
        await (database.update(
          database.routines,
        )..where((t) => t.id.equals(id))).write(
          RoutinesCompanion(
            title: Value(title),
            estimatedDuration: Value(estDuration),
          ),
        );

        // Delete existing exercise associations
        await (database.delete(
          database.routineExercises,
        )..where((t) => t.routineId.equals(id))).go();

        // Re-insert current exercises
        for (final re in exercises) {
          await database
              .into(database.routineExercises)
              .insert(
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
      final guardFailure = await _requireNonSystemRoutine(
        id,
        action: 'eliminare',
      );
      if (guardFailure != null) return Left(guardFailure);

      await database.deleteRoutine(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> copyRoutine(int id) async {
    try {
      final original = await (database.select(
        database.routines,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (original == null) {
        return const Left(DatabaseFailure('Routine non trovata.'));
      }

      final originalExercises = await (database.select(
        database.routineExercises,
      )..where((t) => t.routineId.equals(id))).get();

      return await database.transaction(() async {
        final newRoutineId = await database
            .into(database.routines)
            .insert(
              RoutinesCompanion.insert(
                title: '${original.title} (copia)',
                estimatedDuration: Value(original.estimatedDuration),
                sourceRoutineId: original.isSystem
                    ? Value(original.id)
                    : const Value.absent(),
              ),
            );

        for (final re in originalExercises) {
          await database
              .into(database.routineExercises)
              .insert(
                RoutineExercisesCompanion.insert(
                  routineId: newRoutineId,
                  exerciseId: re.exerciseId,
                  sets: Value(re.sets),
                  reps: Value(re.reps),
                  weight: Value(re.weight),
                  orderIndex: Value(re.orderIndex),
                  setsData: Value(re.setsData),
                ),
              );
        }
        return Right(newRoutineId);
      });
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetRoutineToSource(int id) async {
    try {
      final target = await (database.select(
        database.routines,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (target == null) {
        return const Left(DatabaseFailure('Routine non trovata.'));
      }

      final sourceId = target.sourceRoutineId;
      if (sourceId == null) {
        return const Left(
          DatabaseFailure(
            "Questa routine non ha un'origine di sistema da ripristinare.",
          ),
        );
      }

      final source = await (database.select(
        database.routines,
      )..where((r) => r.id.equals(sourceId))).getSingleOrNull();
      if (source == null || !source.isSystem) {
        return const Left(
          DatabaseFailure('La routine originale non è più disponibile.'),
        );
      }

      final sourceExercises = await (database.select(
        database.routineExercises,
      )..where((t) => t.routineId.equals(sourceId))).get();

      await database.transaction(() async {
        await (database.delete(
          database.routineExercises,
        )..where((t) => t.routineId.equals(id))).go();

        for (final re in sourceExercises) {
          await database
              .into(database.routineExercises)
              .insert(
                RoutineExercisesCompanion.insert(
                  routineId: id,
                  exerciseId: re.exerciseId,
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

  /// Verifica che la routine [id] esista e non sia una routine di sistema:
  /// quelle sono uguali per tutti e non si possono modificare/eliminare
  /// direttamente, solo copiare. Ritorna il fallimento da restituire,
  /// oppure `null` se il controllo passa.
  Future<DatabaseFailure?> _requireNonSystemRoutine(
    int id, {
    required String action,
  }) async {
    final existing = await (database.select(
      database.routines,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (existing != null && existing.isSystem) {
      return DatabaseFailure(
        'Impossibile $action una routine di sistema. Copiala per '
        'personalizzarla.',
      );
    }
    return null;
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
  Stream<List<WorkoutSessionEntity>> watchWorkoutSessions() {
    return database.watchCompletedWorkouts().map((workouts) {
      return workouts
          .map(
            (w) => WorkoutSessionEntity(
              id: w.id,
              date: w.date,
              name: w.name,
              routineId: w.routineId,
              completedAt: w.completedAt,
              durationSeconds: w.durationSeconds,
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, int>> startWorkoutSession({
    required int id,
    required String name,
    int? routineId,
  }) async {
    try {
      final workoutId = await database.insertWorkoutSession(
        WorkoutsCompanion(
          id: Value(id),
          date: Value(DateTime.now()),
          name: Value(name),
          routineId: Value(routineId),
        ),
      );
      return Right(workoutId);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeWorkoutSession({
    required int workoutId,
    required int durationSeconds,
  }) async {
    try {
      await database.completeWorkoutSession(workoutId, durationSeconds);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
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
            (l) =>
                BodyWeightLogEntity(id: l.id, weight: l.weight, date: l.date),
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
        WeightLogsCompanion(weight: Value(weight), date: Value(DateTime.now())),
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
          WeightLogsCompanion(weight: Value(weight), date: Value(date)),
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
              goal: _goalFrom(s.goalType, s.goalValue),
              steps: s.steps,
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
    int? steps,
    String? routeJson,
    DateTime? date,
    CardioGoal? goal,
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
          steps: Value(steps),
          routeJson: Value(routeJson),
          goalType: Value(goal?.type.name),
          goalValue: Value(goal?.value),
          date: Value(date ?? DateTime.now()),
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

/// Ricostruisce l'obiettivo salvato con una sessione cardio.
///
/// Un tipo sconosciuto, per esempio scritto da una versione piu' recente,
/// viene ignorato: meglio nessun obiettivo che uno inventato.
CardioGoal? _goalFrom(String? type, double? value) {
  if (type == null || value == null) return null;

  for (final candidate in CardioGoalType.values) {
    if (candidate.name == type) {
      return CardioGoal(type: candidate, value: value);
    }
  }
  return null;
}
