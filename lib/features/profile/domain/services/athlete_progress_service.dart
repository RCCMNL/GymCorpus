import 'dart:math' as math;

import 'package:gym_corpus/core/utils/training_calculations.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

enum AchievementCategory { consistency, performance, cardio, variety, specialization, streak }

enum AchievementRarity { bronze, silver, gold, platinum }

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.groupId,
    required this.tier,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.target,
  });

  final String id;
  final String groupId;
  final int tier;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final double target;
}

class AchievementProgress {
  const AchievementProgress({
    required this.definition,
    required this.current,
  });

  final AchievementDefinition definition;
  final double current;

  bool get isUnlocked => current >= definition.target;
  double get ratio => (current / definition.target).clamp(0, 1).toDouble();
}

class PersonalRecord {
  const PersonalRecord({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.category,
  });

  final String title;
  final String value;
  final String subtitle;
  final AchievementCategory category;
}

class AthleteProgress {
  const AthleteProgress({
    required this.xp,
    required this.level,
    required this.levelTitle,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.achievements,
    required this.records,
  });

  factory AthleteProgress.empty() => const AthleteProgress(
        xp: 0,
        level: 1,
        levelTitle: 'Recluta',
        currentLevelXp: 0,
        nextLevelXp: 500,
        achievements: [],
        records: [],
      );

  final int xp;
  final int level;
  final String levelTitle;
  final int currentLevelXp;
  final int nextLevelXp;
  final List<AchievementProgress> achievements;
  final List<PersonalRecord> records;

  int get unlockedAchievements =>
      achievements.where((achievement) => achievement.isUnlocked).length;

  double get levelRatio => nextLevelXp == 0
      ? 1
      : (currentLevelXp / nextLevelXp).clamp(0, 1).toDouble();
}

class AthleteProgressService {
  const AthleteProgressService._();

  static const definitions = [
    // --- CONSISTENZA ---
    AchievementDefinition(
      id: 'veterano_10',
      groupId: 'veterano',
      tier: 1,
      title: 'Veterano I',
      description: 'Completa 10 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'veterano_50',
      groupId: 'veterano',
      tier: 2,
      title: 'Veterano II',
      description: 'Completa 50 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 50,
    ),
    AchievementDefinition(
      id: 'veterano_100',
      groupId: 'veterano',
      tier: 3,
      title: 'Veterano III',
      description: 'Completa 100 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.gold,
      target: 100,
    ),
    AchievementDefinition(
      id: 'veterano_500',
      groupId: 'veterano',
      tier: 4,
      title: 'Veterano IV',
      description: 'Completa 500 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.platinum,
      target: 500,
    ),

    // --- VOLUME ---
    AchievementDefinition(
      id: 'volume_5k',
      groupId: 'volume',
      tier: 1,
      title: 'Peso Piuma',
      description: 'Raggiungi 5.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.bronze,
      target: 5000,
    ),
    AchievementDefinition(
      id: 'volume_15k',
      groupId: 'volume',
      tier: 2,
      title: 'Volume King',
      description: 'Raggiungi 15.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.silver,
      target: 15000,
    ),
    AchievementDefinition(
      id: 'volume_30k',
      groupId: 'volume',
      tier: 3,
      title: 'Titano del Volume',
      description: 'Raggiungi 30.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 30000,
    ),
    AchievementDefinition(
      id: 'volume_50k',
      groupId: 'volume',
      tier: 4,
      title: 'Divinità del Volume',
      description: 'Raggiungi 50.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.platinum,
      target: 50000,
    ),

    // --- PESO MASSIMO ---
    AchievementDefinition(
      id: 'heavy_80',
      groupId: 'heavy',
      tier: 1,
      title: 'Carico Serio',
      description: 'Registra un set da almeno 80 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.bronze,
      target: 80,
    ),
    AchievementDefinition(
      id: 'heavy_120',
      groupId: 'heavy',
      tier: 2,
      title: 'Carico a Tre Cifre',
      description: 'Registra un set da almeno 120 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.silver,
      target: 120,
    ),
    AchievementDefinition(
      id: 'heavy_180',
      groupId: 'heavy',
      tier: 3,
      title: 'Forza Bruta',
      description: 'Registra un set da almeno 180 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 180,
    ),
    AchievementDefinition(
      id: 'heavy_250',
      groupId: 'heavy',
      tier: 4,
      title: 'Inarrestabile',
      description: 'Registra un set da almeno 250 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.platinum,
      target: 250,
    ),

    // --- CARDIO DISTANZA ---
    AchievementDefinition(
      id: 'dist_10',
      groupId: 'distance',
      tier: 1,
      title: 'Maratoneta Jr',
      description: 'Percorri 10 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'dist_50',
      groupId: 'distance',
      tier: 2,
      title: 'Globetrotter',
      description: 'Percorri 50 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.silver,
      target: 50,
    ),
    AchievementDefinition(
      id: 'dist_200',
      groupId: 'distance',
      tier: 3,
      title: 'Viaggiatore',
      description: 'Percorri 200 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.gold,
      target: 200,
    ),
    AchievementDefinition(
      id: 'dist_1000',
      groupId: 'distance',
      tier: 4,
      title: 'Odissea Cardio',
      description: 'Percorri 1000 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.platinum,
      target: 1000,
    ),

    // --- VARIETÀ ---
    AchievementDefinition(
      id: 'variety_10',
      groupId: 'variety',
      tier: 1,
      title: 'Sperimentatore',
      description: 'Prova 10 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'variety_30',
      groupId: 'variety',
      tier: 2,
      title: 'Esploratore',
      description: 'Prova 30 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.silver,
      target: 30,
    ),
    AchievementDefinition(
      id: 'variety_60',
      groupId: 'variety',
      tier: 3,
      title: 'Collezionista',
      description: 'Prova 60 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.gold,
      target: 60,
    ),
    AchievementDefinition(
      id: 'variety_100',
      groupId: 'variety',
      tier: 4,
      title: 'Maestro del Catalogo',
      description: 'Prova 100 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.platinum,
      target: 100,
    ),

    // --- STREAKS ---
    AchievementDefinition(
      id: 'streak_4w',
      groupId: 'streak',
      tier: 1,
      title: 'Mese di Fuoco',
      description: 'Allenati per 4 settimane consecutive.',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.silver,
      target: 4,
    ),
    AchievementDefinition(
      id: 'streak_12w',
      groupId: 'streak',
      tier: 2,
      title: 'Inarrestabile',
      description: 'Allenati per 12 settimane consecutive.',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.gold,
      target: 12,
    ),

    // --- SPECIALIZZAZIONE ---
    AchievementDefinition(
      id: 'specialist_legs',
      groupId: 'specialist',
      tier: 1,
      title: 'Leg Day Lover',
      description: 'Completa 20 sessioni focalizzate sulle gambe.',
      category: AchievementCategory.specialization,
      rarity: AchievementRarity.silver,
      target: 20,
    ),
    AchievementDefinition(
      id: 'specialist_push',
      groupId: 'specialist',
      tier: 2,
      title: 'Push Master',
      description: 'Completa 20 sessioni con focus Petto/Spalle/Tricipiti.',
      category: AchievementCategory.specialization,
      rarity: AchievementRarity.silver,
      target: 20,
    ),

    // --- LIFESTYLE ---
    AchievementDefinition(
      id: 'early_bird_10',
      groupId: 'lifestyle',
      tier: 1,
      title: 'Early Bird',
      description: 'Completa 10 allenamenti prima delle 8:00 del mattino.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 10,
    ),
    AchievementDefinition(
      id: 'night_owl_10',
      groupId: 'lifestyle',
      tier: 2,
      title: 'Night Owl',
      description: 'Completa 10 allenamenti dopo le 21:00.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 10,
    ),

    // --- MAESTRIA ---
    AchievementDefinition(
      id: 'bench_king_10k',
      groupId: 'mastery',
      tier: 1,
      title: 'King of the Bench',
      description: 'Solleva 10.000 kg totali di Panca Piana.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 10000,
    ),
    AchievementDefinition(
      id: 'squat_legend_20k',
      groupId: 'mastery',
      tier: 2,
      title: 'Squat Legend',
      description: 'Solleva 20.000 kg totali di Squat.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 20000,
    ),
    AchievementDefinition(
      id: 'reps_1000_club',
      groupId: 'mastery',
      tier: 3,
      title: '1000 Reps Club',
      description: 'Raggiungi 1000 ripetizioni totali per un singolo esercizio.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.silver,
      target: 1000,
    ),

    // --- INTENSITÀ ---
    AchievementDefinition(
      id: 'speed_demon',
      groupId: 'speed',
      tier: 1,
      title: 'Speed Demon',
      description: 'Corri con un passo medio inferiore a 5:00 min/km.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.gold,
      target: 1, // Flag: 1 if achieved
    ),
    AchievementDefinition(
      id: 'calorie_crusher',
      groupId: 'performance_session',
      tier: 1,
      title: 'Calorie Crusher',
      description: 'Brucia più di 1000 kcal in una singola sessione cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.platinum,
      target: 1000,
    ),
    AchievementDefinition(
      id: 'iron_marathon',
      groupId: 'performance_session',
      tier: 2,
      title: 'Maratoneta di Ferro',
      description: 'Completa una sessione di allenamento di oltre 2 ore.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 120, // Minuti
    ),
  ];

  static AthleteProgress calculate({
    required List<WorkoutSessionEntity> workoutSessions,
    required List<WorkoutSetEntity> workoutSets,
    required List<CardioSessionEntity> cardioSessions,
    required List<ExerciseEntity> exercises,
  }) {
    final exerciseById = {
      for (final exercise in exercises) exercise.id: exercise
    };
    final workoutIdsFromSets = workoutSets.map((set) => set.workoutId).toSet();
    final completedWorkoutCount =
        math.max(workoutSessions.length, workoutIdsFromSets.length);
    final weekendWorkoutCount = _countWeekendWorkouts(
      workoutSessions: workoutSessions,
      workoutSets: workoutSets,
    );
    final volumeByWorkout = <int, double>{};
    final triedExerciseIds = <int>{};
    final trainedMuscles = <String>{};

    for (final set in workoutSets) {
      volumeByWorkout.update(
        set.workoutId,
        (value) => value + (set.weight * set.reps),
        ifAbsent: () => set.weight * set.reps,
      );
      triedExerciseIds.add(set.exerciseId);

      final muscle = exerciseById[set.exerciseId]?.targetMuscle.trim();
      if (muscle != null && muscle.isNotEmpty) {
        trainedMuscles.add(muscle.toLowerCase());
      }
    }

    final totalCardioKm = cardioSessions.fold<double>(
      0,
      (total, session) => total + session.distance,
    );
    final totalCardioMinutes = cardioSessions.fold<int>(
      0,
      (total, session) => total + (session.duration ~/ 60),
    );
    final maxCalories = cardioSessions.fold<int>(
      0,
      (maxValue, session) => math.max(maxValue, session.calories),
    );
    final maxVolume = volumeByWorkout.values.fold<double>(
      0,
      (maxValue, volume) => math.max(maxValue, volume),
    );
    final maxWeight = workoutSets.fold<double>(
      0,
      (maxValue, set) => math.max(maxValue, set.weight),
    );

    final totalVolumeLifetime = volumeByWorkout.values.fold<double>(
      0,
      (total, volume) => total + volume,
    );
    final totalRepsLifetime = workoutSets.fold<int>(
      0,
      (total, set) => total + set.reps,
    );
    final totalSetsLifetime = workoutSets.length;

    final maxConsecutiveWeeks = _calculateMaxConsecutiveWeeks(workoutSessions);
    final maxWeeklyWorkouts = _calculateMaxWeeklyWorkouts(workoutSessions);

    // Favorite Exercise (most sets)
    final setsPerExercise = <int, int>{};
    for (final set in workoutSets) {
      setsPerExercise.update(set.exerciseId, (v) => v + 1, ifAbsent: () => 1);
    }
    int? favoriteExerciseId;
    int maxSets = 0;
    setsPerExercise.forEach((id, count) {
      if (count > maxSets) {
        maxSets = count;
        favoriteExerciseId = id;
      }
    });
    final favoriteExerciseName = favoriteExerciseId != null 
        ? (exerciseById[favoriteExerciseId]?.name ?? 'Nessuno')
        : 'Nessuno';

    final maxCardioDurationSeconds = cardioSessions.fold<int>(
      0,
      (maxValue, session) => math.max(maxValue, session.duration),
    );

    final specializationLegs = _calculateMuscleFocusCount(
      workoutSets: workoutSets,
      exerciseById: exerciseById,
      targetMuscles: {'gambe', 'quadricipiti', 'femorali', 'glutei', 'polpacci'},
    );

    final specializationPush = _calculateMuscleFocusCount(
      workoutSets: workoutSets,
      exerciseById: exerciseById,
      targetMuscles: {'petto', 'spalle', 'tricipiti'},
    );

    // Lifestyle & Mastery Metrics
    int earlyBirdCount = 0;
    int nightOwlCount = 0;
    int maxDurationMinutes = 0;
    final exerciseVolume = <int, double>{};
    final exerciseReps = <int, int>{};

    for (final session in workoutSessions) {
      final hour = (session.completedAt ?? session.date).hour;
      if (hour < 8) earlyBirdCount++;
      if (hour >= 21) nightOwlCount++;
      maxDurationMinutes = math.max(
        maxDurationMinutes,
        (session.durationSeconds ?? 0) ~/ 60,
      );
    }

    for (final set in workoutSets) {
      final volume = set.weight * set.reps;
      exerciseVolume.update(set.exerciseId, (v) => v + volume, ifAbsent: () => volume);
      exerciseReps.update(set.exerciseId, (v) => v + set.reps, ifAbsent: () => set.reps);
    }

    final benchId = exercises.where((e) => e.name.toLowerCase().contains('panca piana')).firstOrNull?.id;
    final squatId = exercises.where((e) => e.name.toLowerCase().contains('squat')).firstOrNull?.id;
    
    final benchVolume = benchId != null ? (exerciseVolume[benchId] ?? 0.0) : 0.0;
    final squatVolume = squatId != null ? (exerciseVolume[squatId] ?? 0.0) : 0.0;
    final maxSingleExerciseReps = exerciseReps.isEmpty ? 0 : exerciseReps.values.reduce(math.max);

    // Cardio Metrics
    bool hasSpeedDemon = false;
    for (final session in cardioSessions) {
      if (session.avgSpeed > 0) {
        final paceInSeconds = 3600 / session.avgSpeed;
        if (paceInSeconds <= 300) hasSpeedDemon = true; // 300s = 5:00 min/km
      }
    }

    final achievements = definitions.map((definition) {
      return AchievementProgress(
        definition: definition,
        current: switch (definition.id) {
          'veterano_10' ||
          'veterano_50' ||
          'veterano_100' ||
          'veterano_500' =>
            completedWorkoutCount.toDouble(),
          'volume_5k' ||
          'volume_15k' ||
          'volume_30k' ||
          'volume_50k' =>
            maxVolume,
          'heavy_80' || 'heavy_120' || 'heavy_180' || 'heavy_250' => maxWeight,
          'dist_10' || 'dist_50' || 'dist_200' || 'dist_1000' => totalCardioKm,
          'variety_10' ||
          'variety_30' ||
          'variety_60' ||
          'variety_100' =>
            triedExerciseIds.length.toDouble(),
          'streak_4w' || 'streak_12w' => maxConsecutiveWeeks.toDouble(),
          'specialist_legs' => specializationLegs.toDouble(),
          'specialist_push' => specializationPush.toDouble(),
          'early_bird_10' => earlyBirdCount.toDouble(),
          'night_owl_10' => nightOwlCount.toDouble(),
          'bench_king_10k' => benchVolume,
          'squat_legend_20k' => squatVolume,
          'reps_1000_club' => maxSingleExerciseReps.toDouble(),
          'speed_demon' => hasSpeedDemon ? 1.0 : 0.0,
          'calorie_crusher' => maxCalories.toDouble(),
          'iron_marathon' => maxDurationMinutes.toDouble(),
          _ => 0,
        },
      );
    }).toList();

    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
    
    // 1. XP di Base dalle Attività
    double totalXp = (completedWorkoutCount * 100) +
        (workoutSets.length * 5) +
        (cardioSessions.length * 50) +
        (totalCardioMinutes * 1) +
        (totalCardioKm * 10) +
        (totalVolumeLifetime / 200); // 1 XP ogni 200kg totali

    // 2. XP Bonus dai Badge (Rarità)
    for (final achievement in unlockedAchievements) {
      totalXp += switch (achievement.definition.rarity) {
        AchievementRarity.bronze => 50,
        AchievementRarity.silver => 150,
        AchievementRarity.gold => 400,
        AchievementRarity.platinum => 1000,
      };
    }

    // 3. Bonus Completamento Gruppi (Serie di Badge)
    final groups = <String, List<AchievementProgress>>{};
    for (final a in achievements) {
      groups.putIfAbsent(a.definition.groupId, () => []).add(a);
    }
    
    for (final group in groups.values) {
      if (group.every((a) => a.isUnlocked) && group.length > 1) {
        totalXp += 500; // Bonus "Mastery" per aver completato la serie
      }
    }

    final finalXp = totalXp.round();

    // 4. Calcolo Livello Dinamico
    // XP per livello N = 500 + (N-1) * 250
    int currentLevel = 1;
    int remainingXp = finalXp;
    int xpForNextLevel = 500;

    while (remainingXp >= xpForNextLevel) {
      remainingXp -= xpForNextLevel;
      currentLevel++;
      xpForNextLevel = 500 + (currentLevel - 1) * 250;
    }

    return AthleteProgress(
      xp: finalXp,
      level: currentLevel,
      levelTitle: _levelTitle(currentLevel),
      currentLevelXp: remainingXp,
      nextLevelXp: xpForNextLevel,
      achievements: achievements,
      records: _buildRecords(
        completedWorkoutCount: completedWorkoutCount,
        workoutSets: workoutSets,
        cardioSessions: cardioSessions,
        exerciseById: exerciseById,
        triedExerciseCount: triedExerciseIds.length,
        maxVolume: maxVolume,
        totalVolumeLifetime: totalVolumeLifetime,
        totalRepsLifetime: totalRepsLifetime,
        totalSetsLifetime: totalSetsLifetime,
        totalWorkoutTime: workoutSessions.fold<int>(
          0,
          (total, s) => total + (s.durationSeconds ?? 0),
        ),
        maxWeeklyWorkouts: maxWeeklyWorkouts,
        favoriteExerciseName: favoriteExerciseName,
        maxCardioDurationSeconds: maxCardioDurationSeconds,
        maxCalories: maxCalories,
      ),
    );
  }

  static int _countWeekendWorkouts({
    required List<WorkoutSessionEntity> workoutSessions,
    required List<WorkoutSetEntity> workoutSets,
  }) {
    if (workoutSessions.isNotEmpty) {
      return workoutSessions.where((session) {
        final date = session.completedAt ?? session.date;
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
      }).length;
    }

    final datesByWorkout = <int, DateTime>{};
    for (final set in workoutSets) {
      datesByWorkout.putIfAbsent(set.workoutId, () => set.timestamp);
    }

    return datesByWorkout.values.where((date) {
      return date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
    }).length;
  }

  static List<PersonalRecord> _buildRecords({
    required int completedWorkoutCount,
    required List<WorkoutSetEntity> workoutSets,
    required List<CardioSessionEntity> cardioSessions,
    required Map<int, ExerciseEntity> exerciseById,
    required int triedExerciseCount,
    required double maxVolume,
    required double totalVolumeLifetime,
    required int totalRepsLifetime,
    required int totalSetsLifetime,
    required int totalWorkoutTime,
    required int maxWeeklyWorkouts,
    required String favoriteExerciseName,
    required int maxCardioDurationSeconds,
    required int maxCalories,
  }) {
    final heaviestSet = workoutSets.fold<WorkoutSetEntity?>(
      null,
      (best, set) => best == null || set.weight > best.weight ? set : best,
    );
    final bestOneRepMax = workoutSets.fold<_OneRepMaxRecord?>(
      null,
      (best, set) {
        if (set.reps <= 0 || set.weight <= 0) return best;
        final estimated = TrainingCalculations.calculateBrzycki1RM(
          weight: set.weight,
          reps: set.reps,
        );
        if (estimated <= 0) return best;
        if (best == null || estimated > best.value) {
          return _OneRepMaxRecord(set: set, value: estimated);
        }
        return best;
      },
    );
    final longestCardio = cardioSessions.fold<CardioSessionEntity?>(
      null,
      (best, session) =>
          best == null || session.distance > best.distance ? session : best,
    );
    final fastestCardio = cardioSessions.fold<CardioSessionEntity?>(
      null,
      (best, session) =>
          best == null || session.avgSpeed > best.avgSpeed ? session : best,
    );

    return [
      PersonalRecord(
        title: 'Allenamenti completati',
        value: completedWorkoutCount.toString(),
        subtitle: 'Sessioni registrate',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Volume massimo',
        value: '${maxVolume.round()} kg',
        subtitle: 'Miglior sessione',
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Set piu pesante',
        value: heaviestSet == null
            ? '-'
            : '${heaviestSet.weight.toStringAsFixed(1)} kg',
        subtitle: _exerciseName(heaviestSet, exerciseById),
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: '1RM stimato',
        value: bestOneRepMax == null
            ? '-'
            : '${bestOneRepMax.value.toStringAsFixed(1)} kg',
        subtitle: _exerciseName(bestOneRepMax?.set, exerciseById),
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Distanza cardio',
        value: longestCardio == null
            ? '-'
            : '${longestCardio.distance.toStringAsFixed(2)} km',
        subtitle:
            longestCardio == null ? 'Nessuna sessione' : 'Sessione piu lunga',
        category: AchievementCategory.cardio,
      ),
      PersonalRecord(
        title: 'Velocita media',
        value: fastestCardio == null
            ? '-'
            : '${fastestCardio.avgSpeed.toStringAsFixed(1)} km/h',
        subtitle: fastestCardio == null ? 'Nessuna sessione' : 'Miglior media',
        category: AchievementCategory.cardio,
      ),
      PersonalRecord(
        title: 'Esercizi provati',
        value: triedExerciseCount.toString(),
        subtitle: 'Varieta nel catalogo',
        category: AchievementCategory.variety,
      ),
      PersonalRecord(
        title: 'Volume Totale',
        value: '${_formatLargeNumber(totalVolumeLifetime)} kg',
        subtitle: 'Lifetime record',
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Ripetizioni Totali',
        value: _formatLargeNumber(totalRepsLifetime.toDouble()),
        subtitle: 'Ogni ripetizione conta',
        category: AchievementCategory.performance,
      ),
      PersonalRecord(
        title: 'Set Totali',
        value: _formatLargeNumber(totalSetsLifetime.toDouble()),
        subtitle: 'Serie completate',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Tempo allenamento',
        value: '${(totalWorkoutTime / 3600).toStringAsFixed(1)} h',
        subtitle: 'Tempo totale sotto sforzo',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Settimana Record',
        value: '$maxWeeklyWorkouts sessioni',
        subtitle: 'Massimo in 7 giorni',
        category: AchievementCategory.consistency,
      ),
      PersonalRecord(
        title: 'Esercizio Preferito',
        value: favoriteExerciseName,
        subtitle: 'Piu serie eseguite',
        category: AchievementCategory.variety,
      ),
      PersonalRecord(
        title: 'Cardio Record (Tempo)',
        value: _formatDuration(maxCardioDurationSeconds),
        subtitle: 'Sessione piu lunga',
        category: AchievementCategory.cardio,
      ),
      PersonalRecord(
        title: 'Calorie Record',
        value: '$maxCalories kcal',
        subtitle: 'Massimo bruciato',
        category: AchievementCategory.cardio,
      ),
    ];
  }

  static String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String _exerciseName(
    WorkoutSetEntity? set,
    Map<int, ExerciseEntity> exerciseById,
  ) {
    if (set == null) return 'Nessun set registrato';
    return exerciseById[set.exerciseId]?.name ?? 'Esercizio registrato';
  }

  static String _levelTitle(int level) {
    if (level >= 61) return 'Leggenda';
    if (level >= 31) return 'Elite';
    if (level >= 11) return 'Atleta';
    return 'Recluta';
  }

  static int _calculateMaxConsecutiveWeeks(List<WorkoutSessionEntity> sessions) {
    if (sessions.isEmpty) return 0;

    final dates = sessions
        .map((s) => s.completedAt ?? s.date)
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) return 0;

    final weeks = <int>{};
    for (final date in dates) {
      // Calcolo settimana ISO o simile
      final firstDayOfYear = DateTime(date.year, 1, 1);
      final weekNumber =
          ((date.difference(firstDayOfYear).inDays + firstDayOfYear.weekday) / 7)
              .ceil();
      weeks.add(date.year * 100 + weekNumber);
    }

    final sortedWeeks = weeks.toList()..sort();
    int maxStreak = 0;
    int currentStreak = 0;
    int? lastWeek;

    for (final week in sortedWeeks) {
      if (lastWeek == null) {
        currentStreak = 1;
      } else {
        // Verifica se è la settimana successiva
        final lastYear = lastWeek ~/ 100;
        final lastWk = lastWeek % 100;
        final currYear = week ~/ 100;
        final currWk = week % 100;

        bool isNext = false;
        if (currYear == lastYear && currWk == lastWk + 1) {
          isNext = true;
        } else if (currYear == lastYear + 1 && lastWk >= 52 && currWk == 1) {
          isNext = true;
        }

        if (isNext) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }
      lastWeek = week;
      maxStreak = math.max(maxStreak, currentStreak);
    }

    return maxStreak;
  }

  static int _calculateMuscleFocusCount({
    required List<WorkoutSetEntity> workoutSets,
    required Map<int, ExerciseEntity> exerciseById,
    required Set<String> targetMuscles,
  }) {
    final workoutIds = <int>{};
    for (final set in workoutSets) {
      final exercise = exerciseById[set.exerciseId];
      if (exercise != null) {
        final muscle = exercise.targetMuscle.toLowerCase().trim();
        if (targetMuscles.any((m) => muscle.contains(m))) {
          workoutIds.add(set.workoutId);
        }
      }
    }
    return workoutIds.length;
  }

  static int _calculateMaxWeeklyWorkouts(List<WorkoutSessionEntity> sessions) {
    if (sessions.isEmpty) return 0;
    final workoutsByWeek = <String, int>{};
    for (final s in sessions) {
      final date = s.completedAt ?? s.date;
      final weekKey = '${date.year}-W${((date.difference(DateTime(date.year, 1, 1)).inDays + DateTime(date.year, 1, 1).weekday) / 7).ceil()}';
      workoutsByWeek.update(weekKey, (v) => v + 1, ifAbsent: () => 1);
    }
    return workoutsByWeek.values.isEmpty ? 0 : workoutsByWeek.values.reduce(math.max);
  }

  static String _formatLargeNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 10000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.round().toString();
  }
}

class _OneRepMaxRecord {
  const _OneRepMaxRecord({
    required this.set,
    required this.value,
  });

  final WorkoutSetEntity set;
  final double value;
}
