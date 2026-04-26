import 'dart:math' as math;

import 'package:gym_corpus/core/utils/training_calculations.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

enum AchievementCategory { consistency, performance, cardio, variety }

enum AchievementRarity { bronze, silver, gold, platinum }

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.target,
  });

  final String id;
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
    AchievementDefinition(
      id: 'veterano_10',
      title: 'Veterano I',
      description: 'Completa 10 allenamenti.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'weekend_warrior_5',
      title: 'Weekend Warrior',
      description: 'Completa 5 allenamenti nel weekend.',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.silver,
      target: 5,
    ),
    AchievementDefinition(
      id: 'volume_king_10000',
      title: 'Volume King',
      description: 'Raggiungi 10.000 kg di volume in una sessione.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.gold,
      target: 10000,
    ),
    AchievementDefinition(
      id: 'heavy_set_100',
      title: 'Carico a Tre Cifre',
      description: 'Registra un set da almeno 100 kg.',
      category: AchievementCategory.performance,
      rarity: AchievementRarity.silver,
      target: 100,
    ),
    AchievementDefinition(
      id: 'calorie_burner_600',
      title: 'Calorie Burner',
      description: 'Brucia 600 kcal in una sessione cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.silver,
      target: 600,
    ),
    AchievementDefinition(
      id: 'globetrotter_100',
      title: 'Globetrotter',
      description: 'Percorri 100 km totali nelle sessioni cardio.',
      category: AchievementCategory.cardio,
      rarity: AchievementRarity.gold,
      target: 100,
    ),
    AchievementDefinition(
      id: 'sperimentatore_10',
      title: 'Sperimentatore',
      description: 'Prova 10 esercizi diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.bronze,
      target: 10,
    ),
    AchievementDefinition(
      id: 'tuttofare_6',
      title: 'Tuttofare',
      description: 'Allena 6 gruppi muscolari diversi.',
      category: AchievementCategory.variety,
      rarity: AchievementRarity.platinum,
      target: 6,
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

    final achievements = definitions.map((definition) {
      return AchievementProgress(
        definition: definition,
        current: switch (definition.id) {
          'veterano_10' => completedWorkoutCount.toDouble(),
          'weekend_warrior_5' => weekendWorkoutCount.toDouble(),
          'volume_king_10000' => maxVolume,
          'heavy_set_100' => maxWeight,
          'calorie_burner_600' => maxCalories.toDouble(),
          'globetrotter_100' => totalCardioKm,
          'sperimentatore_10' => triedExerciseIds.length.toDouble(),
          'tuttofare_6' => trainedMuscles.length.toDouble(),
          _ => 0,
        },
      );
    }).toList();

    final unlockedCount =
        achievements.where((achievement) => achievement.isUnlocked).length;
    final xp = (completedWorkoutCount * 100) +
        (workoutSets.length * 5) +
        cardioSessions.length * 40 +
        totalCardioMinutes +
        (totalCardioKm * 10).round() +
        (unlockedCount * 75);
    final level = (xp ~/ 500) + 1;
    final currentLevelXp = xp % 500;

    return AthleteProgress(
      xp: xp,
      level: level,
      levelTitle: _levelTitle(level),
      currentLevelXp: currentLevelXp,
      nextLevelXp: 500,
      achievements: achievements,
      records: _buildRecords(
        completedWorkoutCount: completedWorkoutCount,
        workoutSets: workoutSets,
        cardioSessions: cardioSessions,
        exerciseById: exerciseById,
        triedExerciseCount: triedExerciseIds.length,
        maxVolume: maxVolume,
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
    ];
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
}

class _OneRepMaxRecord {
  const _OneRepMaxRecord({
    required this.set,
    required this.value,
  });

  final WorkoutSetEntity set;
  final double value;
}
