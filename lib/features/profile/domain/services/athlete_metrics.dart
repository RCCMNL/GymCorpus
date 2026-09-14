import 'dart:math' as math;

import 'package:gym_corpus/core/utils/training_calculations.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

/// Le grandezze che un trofeo puo' misurare.
///
/// Ogni badge del catalogo ne dichiara una: e' cosi' che la definizione del
/// trofeo resta separata dal calcolo, senza il vecchio `switch` su trenta
/// stringhe che andava tenuto allineato a mano all'elenco dei badge.
enum AthleteMetric {
  completedWorkouts,
  bestSessionVolume,
  heaviestWeight,
  cardioKilometers,
  exercisesTried,
  consecutiveWeeks,
  legDaySessions,
  pushDaySessions,
  earlyMorningSessions,
  lateEveningSessions,
  benchVolume,
  squatVolume,
  repsOnBestExercise,
  fastPaceReached,
  bestSessionCalories,
  longestSessionMinutes,
}

/// Tutti i numeri che si possono estrarre dallo storico di un atleta.
///
/// E' l'unico punto che scorre sessioni, set e cardio: trofei, livello e
/// record leggono solo da qui. Prima ognuno di quei tre calcoli rifaceva i
/// propri giri sulle stesse liste, dentro un metodo di 275 righe.
class AthleteMetrics {
  const AthleteMetrics({
    required this.completedWorkouts,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.bestSessionVolume,
    required this.heaviestWeight,
    required this.heaviestSetExerciseId,
    required this.bestOneRepMax,
    required this.bestOneRepMaxExerciseId,
    required this.exercisesTried,
    required this.favoriteExerciseId,
    required this.repsOnBestExercise,
    required this.benchVolume,
    required this.squatVolume,
    required this.consecutiveWeeks,
    required this.bestWeeklyWorkouts,
    required this.totalWorkoutSeconds,
    required this.longestSessionMinutes,
    required this.earlyMorningSessions,
    required this.lateEveningSessions,
    required this.legDaySessions,
    required this.pushDaySessions,
    required this.cardioSessions,
    required this.cardioKilometers,
    required this.cardioMinutes,
    required this.longestCardioSeconds,
    required this.longestCardioDistance,
    required this.fastestCardioSpeed,
    required this.bestSessionCalories,
    required this.fastPaceReached,
    required this.exerciseNames,
  });

  /// Aggrega in una sola passata per lista.
  factory AthleteMetrics.from({
    required List<WorkoutSessionEntity> workoutSessions,
    required List<WorkoutSetEntity> workoutSets,
    required List<CardioSessionEntity> cardioSessions,
    required List<ExerciseEntity> exercises,
  }) {
    final exerciseNames = <int, String>{};
    final muscleByExercise = <int, String>{};
    for (final exercise in exercises) {
      exerciseNames[exercise.id] = exercise.name;
      muscleByExercise[exercise.id] = exercise.targetMuscle
          .toLowerCase()
          .trim();
    }

    final benchId = _firstExerciseNamed(exercises, 'panca piana');
    final squatId = _firstExerciseNamed(exercises, 'squat');

    final volumeByWorkout = <int, double>{};
    final setsByExercise = <int, int>{};
    final repsByExercise = <int, int>{};
    final volumeByExercise = <int, double>{};
    final legWorkoutIds = <int>{};
    final pushWorkoutIds = <int>{};
    final triedExerciseIds = <int>{};
    final workoutIdsFromSets = <int>{};

    var totalReps = 0;
    var heaviestWeight = 0.0;
    var heaviestSetWeight = 0.0;
    int? heaviestSetExerciseId;
    var bestOneRepMax = 0.0;
    int? bestOneRepMaxExerciseId;

    for (final set in workoutSets) {
      final volume = set.weight * set.reps;
      workoutIdsFromSets.add(set.workoutId);
      triedExerciseIds.add(set.exerciseId);
      totalReps += set.reps;

      volumeByWorkout.update(
        set.workoutId,
        (value) => value + volume,
        ifAbsent: () => volume,
      );
      setsByExercise.update(
        set.exerciseId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      repsByExercise.update(
        set.exerciseId,
        (value) => value + set.reps,
        ifAbsent: () => set.reps,
      );
      volumeByExercise.update(
        set.exerciseId,
        (value) => value + volume,
        ifAbsent: () => volume,
      );

      heaviestWeight = math.max(heaviestWeight, set.weight);
      if (heaviestSetExerciseId == null || set.weight > heaviestSetWeight) {
        heaviestSetWeight = set.weight;
        heaviestSetExerciseId = set.exerciseId;
      }

      if (set.reps > 0 && set.weight > 0) {
        final estimated = TrainingCalculations.calculateBrzycki1RM(
          weight: set.weight,
          reps: set.reps,
        );
        if (estimated > 0 && estimated > bestOneRepMax) {
          bestOneRepMax = estimated;
          bestOneRepMaxExerciseId = set.exerciseId;
        }
      }

      final muscle = muscleByExercise[set.exerciseId];
      if (muscle != null) {
        if (_legMuscles.any(muscle.contains)) {
          legWorkoutIds.add(set.workoutId);
        }
        if (_pushMuscles.any(muscle.contains)) {
          pushWorkoutIds.add(set.workoutId);
        }
      }
    }

    var totalWorkoutSeconds = 0;
    var longestSessionMinutes = 0;
    var earlyMorningSessions = 0;
    var lateEveningSessions = 0;
    final sessionsByWeek = <int, int>{};

    for (final session in workoutSessions) {
      final moment = session.completedAt ?? session.date;
      if (moment.hour < _earlyMorningHour) earlyMorningSessions++;
      if (moment.hour >= _lateEveningHour) lateEveningSessions++;

      final seconds = session.durationSeconds ?? 0;
      totalWorkoutSeconds += seconds;
      longestSessionMinutes = math.max(longestSessionMinutes, seconds ~/ 60);

      sessionsByWeek.update(
        weekKey(moment),
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    var cardioKilometers = 0.0;
    var cardioMinutes = 0;
    var longestCardioSeconds = 0;
    var longestCardioDistance = 0.0;
    var fastestCardioSpeed = 0.0;
    var bestSessionCalories = 0;
    var fastPaceReached = false;

    for (final session in cardioSessions) {
      cardioKilometers += session.distance;
      cardioMinutes += session.duration ~/ 60;
      longestCardioSeconds = math.max(longestCardioSeconds, session.duration);
      longestCardioDistance = math.max(longestCardioDistance, session.distance);
      fastestCardioSpeed = math.max(fastestCardioSpeed, session.avgSpeed);
      bestSessionCalories = math.max(bestSessionCalories, session.calories);
      if (session.avgSpeed > 0 &&
          3600 / session.avgSpeed <= _fastPaceSecondsPerKm) {
        fastPaceReached = true;
      }
    }

    int? favoriteExerciseId;
    var mostSets = 0;
    setsByExercise.forEach((exerciseId, count) {
      if (count > mostSets) {
        mostSets = count;
        favoriteExerciseId = exerciseId;
      }
    });

    return AthleteMetrics(
      completedWorkouts: math.max(
        workoutSessions.length,
        workoutIdsFromSets.length,
      ),
      totalSets: workoutSets.length,
      totalReps: totalReps,
      totalVolume: volumeByWorkout.values.fold<double>(
        0,
        (total, volume) => total + volume,
      ),
      bestSessionVolume: volumeByWorkout.values.fold<double>(0, math.max),
      heaviestWeight: heaviestWeight,
      heaviestSetExerciseId: heaviestSetExerciseId,
      bestOneRepMax: bestOneRepMax,
      bestOneRepMaxExerciseId: bestOneRepMaxExerciseId,
      exercisesTried: triedExerciseIds.length,
      favoriteExerciseId: favoriteExerciseId,
      repsOnBestExercise: repsByExercise.values.fold<int>(0, math.max),
      benchVolume: benchId == null ? 0 : (volumeByExercise[benchId] ?? 0),
      squatVolume: squatId == null ? 0 : (volumeByExercise[squatId] ?? 0),
      consecutiveWeeks: _maxConsecutiveWeeks(sessionsByWeek.keys),
      bestWeeklyWorkouts: sessionsByWeek.values.fold<int>(0, math.max),
      totalWorkoutSeconds: totalWorkoutSeconds,
      longestSessionMinutes: longestSessionMinutes,
      earlyMorningSessions: earlyMorningSessions,
      lateEveningSessions: lateEveningSessions,
      legDaySessions: legWorkoutIds.length,
      pushDaySessions: pushWorkoutIds.length,
      cardioSessions: cardioSessions.length,
      cardioKilometers: cardioKilometers,
      cardioMinutes: cardioMinutes,
      longestCardioSeconds: longestCardioSeconds,
      longestCardioDistance: longestCardioDistance,
      fastestCardioSpeed: fastestCardioSpeed,
      bestSessionCalories: bestSessionCalories,
      fastPaceReached: fastPaceReached,
      exerciseNames: exerciseNames,
    );
  }

  static const empty = AthleteMetrics(
    completedWorkouts: 0,
    totalSets: 0,
    totalReps: 0,
    totalVolume: 0,
    bestSessionVolume: 0,
    heaviestWeight: 0,
    heaviestSetExerciseId: null,
    bestOneRepMax: 0,
    bestOneRepMaxExerciseId: null,
    exercisesTried: 0,
    favoriteExerciseId: null,
    repsOnBestExercise: 0,
    benchVolume: 0,
    squatVolume: 0,
    consecutiveWeeks: 0,
    bestWeeklyWorkouts: 0,
    totalWorkoutSeconds: 0,
    longestSessionMinutes: 0,
    earlyMorningSessions: 0,
    lateEveningSessions: 0,
    legDaySessions: 0,
    pushDaySessions: 0,
    cardioSessions: 0,
    cardioKilometers: 0,
    cardioMinutes: 0,
    longestCardioSeconds: 0,
    longestCardioDistance: 0,
    fastestCardioSpeed: 0,
    bestSessionCalories: 0,
    fastPaceReached: false,
    exerciseNames: {},
  );

  static const _earlyMorningHour = 8;
  static const _lateEveningHour = 21;
  static const _fastPaceSecondsPerKm = 300; // 5:00 al chilometro
  static const _legMuscles = {
    'gambe',
    'quadricipiti',
    'femorali',
    'glutei',
    'polpacci',
  };
  static const _pushMuscles = {'petto', 'spalle', 'tricipiti'};

  final int completedWorkouts;
  final int totalSets;
  final int totalReps;
  final double totalVolume;

  /// Volume della singola sessione piu' pesante, non il totale.
  final double bestSessionVolume;
  final double heaviestWeight;
  final int? heaviestSetExerciseId;
  final double bestOneRepMax;
  final int? bestOneRepMaxExerciseId;
  final int exercisesTried;
  final int? favoriteExerciseId;

  /// Ripetizioni accumulate sull'esercizio piu' ripetuto.
  final int repsOnBestExercise;
  final double benchVolume;
  final double squatVolume;
  final int consecutiveWeeks;
  final int bestWeeklyWorkouts;
  final int totalWorkoutSeconds;
  final int longestSessionMinutes;
  final int earlyMorningSessions;
  final int lateEveningSessions;

  /// Sessioni in cui si e' allenato almeno un muscolo del gruppo.
  final int legDaySessions;
  final int pushDaySessions;
  final int cardioSessions;
  final double cardioKilometers;
  final int cardioMinutes;
  final int longestCardioSeconds;
  final double longestCardioDistance;
  final double fastestCardioSpeed;
  final int bestSessionCalories;

  /// Vero se almeno una sessione cardio e' andata sotto i 5:00/km.
  final bool fastPaceReached;

  /// Nome per id, per le schede che devono scrivere l'esercizio.
  final Map<int, String> exerciseNames;

  /// Il valore che il badge legato a [metric] deve confrontare col target.
  double valueOf(AthleteMetric metric) => switch (metric) {
    AthleteMetric.completedWorkouts => completedWorkouts.toDouble(),
    AthleteMetric.bestSessionVolume => bestSessionVolume,
    AthleteMetric.heaviestWeight => heaviestWeight,
    AthleteMetric.cardioKilometers => cardioKilometers,
    AthleteMetric.exercisesTried => exercisesTried.toDouble(),
    AthleteMetric.consecutiveWeeks => consecutiveWeeks.toDouble(),
    AthleteMetric.legDaySessions => legDaySessions.toDouble(),
    AthleteMetric.pushDaySessions => pushDaySessions.toDouble(),
    AthleteMetric.earlyMorningSessions => earlyMorningSessions.toDouble(),
    AthleteMetric.lateEveningSessions => lateEveningSessions.toDouble(),
    AthleteMetric.benchVolume => benchVolume,
    AthleteMetric.squatVolume => squatVolume,
    AthleteMetric.repsOnBestExercise => repsOnBestExercise.toDouble(),
    AthleteMetric.fastPaceReached => fastPaceReached ? 1 : 0,
    AthleteMetric.bestSessionCalories => bestSessionCalories.toDouble(),
    AthleteMetric.longestSessionMinutes => longestSessionMinutes.toDouble(),
  };

  /// Numero progressivo della settimana, unico anche fra anni diversi.
  ///
  /// Non e' la settimana ISO: conta i giorni dal primo gennaio spostati del
  /// giorno della settimana in cui l'anno e' cominciato. Basta perche' serve
  /// solo a dire se due allenamenti cadono nella stessa settimana o in due
  /// consecutive.
  static int weekKey(DateTime date) {
    final firstDayOfYear = DateTime(date.year);
    final week =
        ((date.difference(firstDayOfYear).inDays + firstDayOfYear.weekday) / 7)
            .ceil();
    return date.year * 100 + week;
  }

  static int? _firstExerciseNamed(
    List<ExerciseEntity> exercises,
    String needle,
  ) {
    for (final exercise in exercises) {
      if (exercise.name.toLowerCase().contains(needle)) return exercise.id;
    }
    return null;
  }

  static int _maxConsecutiveWeeks(Iterable<int> weekKeys) {
    if (weekKeys.isEmpty) return 0;

    final sorted = weekKeys.toSet().toList()..sort();
    var maxStreak = 0;
    var currentStreak = 0;
    int? previous;

    for (final week in sorted) {
      if (previous == null || !_areConsecutive(previous, week)) {
        currentStreak = 1;
      } else {
        currentStreak++;
      }
      previous = week;
      maxStreak = math.max(maxStreak, currentStreak);
    }

    return maxStreak;
  }

  static bool _areConsecutive(int previous, int current) {
    final previousYear = previous ~/ 100;
    final previousWeek = previous % 100;
    final currentYear = current ~/ 100;
    final currentWeek = current % 100;

    if (currentYear == previousYear) return currentWeek == previousWeek + 1;
    return currentYear == previousYear + 1 &&
        previousWeek >= 52 &&
        currentWeek == 1;
  }
}
