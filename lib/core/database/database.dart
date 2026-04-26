import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/seed_data.dart';

// Dopo aver runnato build_runner questo file verrà generato
part 'database.g.dart';

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text()();
  IntColumn get routineId => integer().nullable().references(Routines, #id)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get targetMuscle => text()();
  TextColumn get referenceVideoUrl => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get equipment => text().nullable()();
  TextColumn get focusArea => text().nullable()();
  TextColumn get preparation => text().nullable()();
  TextColumn get execution => text().nullable()();
  TextColumn get tips => text().nullable()();
  TextColumn get userNotes => text().nullable()();
  BoolColumn get isVector => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get estimatedDuration => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().references(Routines, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get sets => integer().withDefault(const Constant(3))();
  IntColumn get reps => integer().withDefault(const Constant(10))();
  RealColumn get weight => real().withDefault(const Constant(0))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  TextColumn get setsData =>
      text().nullable()(); // Nuova colonna per JSON serie
}

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().references(Workouts, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get reps => integer()();
  RealColumn get weight => real()();
  IntColumn get rpe => integer().nullable()();
  DateTimeColumn get timestamp => dateTime()();
}

class WeightLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get weight => real()();
  DateTimeColumn get date => dateTime()();
}

class BodyMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get part => text()(); // Chest, Waist, etc.
  RealColumn get value => real()();
  DateTimeColumn get date => dateTime()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class CardioSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type =>
      text().withDefault(const Constant('run'))(); // run, walk
  RealColumn get distance => real()(); // in km
  IntColumn get duration => integer()(); // in seconds
  RealColumn get avgSpeed => real()(); // km/h
  TextColumn get pace => text()(); // mm:ss per km
  IntColumn get calories => integer()();
  TextColumn get routeJson =>
      text().nullable()(); // JSON string of latlng coordinates
  DateTimeColumn get date => dateTime()();
}

class NotificationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant('general'))();
}

@DriftDatabase(tables: [
  Workouts,
  Exercises,
  WorkoutSets,
  Routines,
  RoutineExercises,
  WeightLogs,
  AppSettings,
  CardioSessions,
  BodyMeasurements,
  NotificationLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        await _runSafeMigrations(m, from: from, to: to);
      },
      beforeOpen: (details) async {
        final m = createMigrator();
        await _ensureCurrentTables(m);
        await _ensureCurrentColumns(m);

        final exercisesExist = await select(exercises).get();

        if (exercisesExist.isEmpty) {
          // Se la tabella è vuota, inseriamo il seeding iniziale
          await _seedInitialData();
        }
      },
    );
  }

  Future<void> _runSafeMigrations(
    Migrator m, {
    required int from,
    required int to,
  }) async {
    if (from == to) return;

    await _ensureCurrentTables(m);
    await _ensureCurrentColumns(m);
  }

  Future<void> _ensureCurrentTables(Migrator m) async {
    await _ensureTable(m, workouts);
    await _ensureTable(m, exercises);
    await _ensureTable(m, workoutSets);
    await _ensureTable(m, routines);
    await _ensureTable(m, routineExercises);
    await _ensureTable(m, weightLogs);
    await _ensureTable(m, appSettings);
    await _ensureTable(m, cardioSessions);
    await _ensureTable(m, bodyMeasurements);
    await _ensureTable(m, notificationLogs);
  }

  Future<void> _ensureCurrentColumns(Migrator m) async {
    await _ensureColumn(m, workouts, workouts.routineId, 'routine_id');
    await _ensureColumn(m, workouts, workouts.completedAt, 'completed_at');
    await _ensureColumn(
        m, workouts, workouts.durationSeconds, 'duration_seconds');

    await _ensureColumn(
        m, exercises, exercises.referenceVideoUrl, 'reference_video_url');
    await _ensureColumn(m, exercises, exercises.imageUrl, 'image_url');
    await _ensureColumn(m, exercises, exercises.equipment, 'equipment');
    await _ensureColumn(m, exercises, exercises.focusArea, 'focus_area');
    await _ensureColumn(m, exercises, exercises.preparation, 'preparation');
    await _ensureColumn(m, exercises, exercises.execution, 'execution');
    await _ensureColumn(m, exercises, exercises.tips, 'tips');
    await _ensureColumn(m, exercises, exercises.userNotes, 'user_notes');
    await _ensureColumn(m, exercises, exercises.isVector, 'is_vector');
    await _ensureColumn(m, exercises, exercises.isFavorite, 'is_favorite');

    await _ensureColumn(
        m, routines, routines.estimatedDuration, 'estimated_duration');
    await _ensureColumn(m, routines, routines.createdAt, 'created_at');

    await _ensureColumn(
        m, routineExercises, routineExercises.orderIndex, 'order_index');
    await _ensureColumn(
        m, routineExercises, routineExercises.setsData, 'sets_data');

    await _ensureColumn(m, workoutSets, workoutSets.rpe, 'rpe');

    await _ensureColumn(m, cardioSessions, cardioSessions.type, 'type');
    await _ensureColumn(m, cardioSessions, cardioSessions.distance, 'distance');
    await _ensureColumn(m, cardioSessions, cardioSessions.duration, 'duration');
    await _ensureColumn(
        m, cardioSessions, cardioSessions.avgSpeed, 'avg_speed');
    await _ensureColumn(m, cardioSessions, cardioSessions.pace, 'pace');
    await _ensureColumn(m, cardioSessions, cardioSessions.calories, 'calories');
    await _ensureColumn(
        m, cardioSessions, cardioSessions.routeJson, 'route_json');
    await _ensureColumn(m, cardioSessions, cardioSessions.date, 'date');

    await _ensureColumn(m, bodyMeasurements, bodyMeasurements.part, 'part');
    await _ensureColumn(m, bodyMeasurements, bodyMeasurements.value, 'value');
    await _ensureColumn(m, bodyMeasurements, bodyMeasurements.date, 'date');

    await _ensureColumn(
        m, notificationLogs, notificationLogs.title, 'title');
    await _ensureColumn(
        m, notificationLogs, notificationLogs.body, 'body');
    await _ensureColumn(
        m, notificationLogs, notificationLogs.timestamp, 'timestamp');
    await _ensureColumn(
        m, notificationLogs, notificationLogs.isRead, 'is_read');
    await _ensureColumn(
        m, notificationLogs, notificationLogs.type, 'type');
  }

  Future<void> _ensureTable(Migrator m, TableInfo<Table, dynamic> table) async {
    if (!await _tableExists(table.actualTableName)) {
      await m.createTable(table);
    }
  }

  Future<void> _ensureColumn(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn column,
    String columnName,
  ) async {
    if (!await _columnExists(table.actualTableName, columnName)) {
      await m.addColumn(table, column);
    }
  }

  Future<bool> _tableExists(String tableName) async {
    final result = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND (name = ? OR name = ?)",
      variables: [
        Variable.withString(tableName),
        Variable.withString(tableName.toLowerCase()),
      ],
    ).getSingleOrNull();
    return result != null;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();

    return rows.any((row) => row.data['name'] == columnName);
  }

  Future<void> _seedInitialData() async {
    // 157 esercizi importati dal database legacy (Stitch Design)
    final initialExercises = getSeedExercises();

    for (final exercise in initialExercises) {
      final id = await into(exercises).insert(exercise);

      // Crea una routine di esempio con Distensioni su panca piana
      if (exercise.name.value == 'Distensioni su panca piana (Bilanciere)') {
        final routineId = await into(routines).insert(
          const RoutinesCompanion(
            title: Value('Powerbuilding A'),
            estimatedDuration: Value(60),
          ),
        );

        await into(routineExercises).insert(
          RoutineExercisesCompanion(
            routineId: Value(routineId),
            exerciseId: Value(id),
            sets: const Value(5),
            reps: const Value(5),
            weight: const Value(80),
            orderIndex: const Value(0),
          ),
        );
      }
    }

    // Seed default settings
    await into(appSettings).insert(const AppSettingsCompanion(
        key: Value('rest_timer'), value: Value('90')));
    await into(appSettings).insert(const AppSettingsCompanion(
        key: Value('units'), value: Value('metric')));

    // Simple weight seed for analytics
    await into(weightLogs).insert(WeightLogsCompanion(
        weight: const Value(78.5),
        date: Value(DateTime.now().subtract(const Duration(days: 7)))));
    await into(weightLogs).insert(WeightLogsCompanion(
        weight: const Value(78.2),
        date: Value(DateTime.now().subtract(const Duration(days: 6)))));
  }

  // Metodi access point base
  Stream<List<Exercise>> watchAllExercises() => select(exercises).watch();
  Future<int> insertSet(WorkoutSetsCompanion set) =>
      into(workoutSets).insert(set);
  Future<int> insertWorkoutSession(WorkoutsCompanion workout) =>
      into(workouts).insert(workout, mode: InsertMode.insertOrIgnore);

  Future<void> completeWorkoutSession(int id, int durationSeconds) =>
      (update(workouts)..where((t) => t.id.equals(id))).write(
        WorkoutsCompanion(
          completedAt: Value(DateTime.now()),
          durationSeconds: Value(durationSeconds),
        ),
      );

  // Routines access
  Stream<List<Routine>> watchAllRoutines() => select(routines).watch();
  Future<int> insertRoutine(RoutinesCompanion routine) =>
      into(routines).insert(routine);
  Future<void> deleteRoutine(int id) => transaction(() async {
        await (delete(routineExercises)..where((t) => t.routineId.equals(id)))
            .go();
        await (delete(routines)..where((t) => t.id.equals(id))).go();
      });

  // Performed sets stats
  Stream<List<Workout>> watchCompletedWorkouts() => (select(workouts)
        ..where((t) => t.completedAt.isNotNull())
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.completedAt,
                mode: OrderingMode.desc,
              ),
        ]))
      .watch();

  Stream<List<WorkoutSet>> watchLatestWeightLogs() => (select(workoutSets)
        ..orderBy([
          (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
        ]))
      .watch();

  // Body weight tracking
  Stream<List<WeightLog>> watchLatestWeightEntries() => (select(weightLogs)
        ..orderBy(
            [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .watch();
  Future<int> insertWeightLog(WeightLogsCompanion entry) =>
      into(weightLogs).insert(entry);
  Future<void> deleteWeightLog(int id) =>
      (delete(weightLogs)..where((t) => t.id.equals(id))).go();
  Future<void> updateWeightLog(int id, double weight) =>
      (update(weightLogs)..where((t) => t.id.equals(id)))
          .write(WeightLogsCompanion(weight: Value(weight)));
  Future<void> deleteAllWeightLogs() => delete(weightLogs).go();

  // Body measurements
  Stream<List<BodyMeasurement>> watchAllMeasurements() =>
      (select(bodyMeasurements)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
            ]))
          .watch();
  Future<int> insertMeasurement(BodyMeasurementsCompanion entry) =>
      into(bodyMeasurements).insert(entry);
  Future<void> deleteMeasurement(int id) =>
      (delete(bodyMeasurements)..where((t) => t.id.equals(id))).go();
  Future<void> updateMeasurement(int id, double value) =>
      (update(bodyMeasurements)..where((t) => t.id.equals(id)))
          .write(BodyMeasurementsCompanion(value: Value(value)));

  // Settings management
  Stream<String?> watchSetting(String key) =>
      (select(appSettings)..where((t) => t.key.equals(key)))
          .map((row) => row.value)
          .watchSingleOrNull();

  Stream<List<AppSetting>> watchAllSettings() => select(appSettings).watch();

  Future<void> updateSetting(String key, String value) =>
      (update(appSettings)..where((t) => t.key.equals(key)))
          .write(AppSettingsCompanion(value: Value(value)));

  // Favorites & Notes
  Future<void> toggleExerciseFavorite(int id, {required bool isFavorite}) =>
      (update(exercises)..where((e) => e.id.equals(id)))
          .write(ExercisesCompanion(isFavorite: Value(isFavorite)));

  Future<void> updateExerciseNotes(int id, String notes) =>
      (update(exercises)..where((e) => e.id.equals(id)))
          .write(ExercisesCompanion(userNotes: Value(notes)));

  // Cardio Sessions
  Stream<List<CardioSession>> watchAllCardioSessions() =>
      (select(cardioSessions)
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
            ]))
          .watch();
  Future<int> insertCardioSession(CardioSessionsCompanion session) =>
      into(cardioSessions).insert(session);
  Future<void> deleteCardioSession(int id) =>
      (delete(cardioSessions)..where((t) => t.id.equals(id))).go();

  // Notification logs
  Stream<List<NotificationLog>> watchAllNotificationLogs() =>
      (select(notificationLogs)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<int> insertNotificationLog(NotificationLogsCompanion log) =>
      into(notificationLogs).insert(log);

  Future<void> markNotificationRead(int id) =>
      (update(notificationLogs)..where((t) => t.id.equals(id)))
          .write(const NotificationLogsCompanion(isRead: Value(true)));

  Future<void> markAllNotificationsRead() =>
      update(notificationLogs)
          .write(const NotificationLogsCompanion(isRead: Value(true)));

  Future<void> deleteNotificationLog(int id) =>
      (delete(notificationLogs)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllNotificationLogs() => delete(notificationLogs).go();
}
