import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

WorkoutSetEntity _set({
  int id = 1,
  int workoutId = 1,
  int exerciseId = 1,
  int reps = 10,
  double weight = 50,
  DateTime? timestamp,
}) {
  return WorkoutSetEntity(
    id: id,
    workoutId: workoutId,
    exerciseId: exerciseId,
    reps: reps,
    weight: weight,
    timestamp: timestamp ?? DateTime(2026, 5, 4),
  );
}

WorkoutSessionEntity _session({
  int id = 1,
  DateTime? date,
  int? durationSeconds,
}) {
  final day = date ?? DateTime(2026, 5, 4, 18);
  return WorkoutSessionEntity(
    id: id,
    date: day,
    name: 'Sessione',
    completedAt: day,
    durationSeconds: durationSeconds,
  );
}

CardioSessionEntity _cardio({
  int id = 1,
  double distance = 5,
  int duration = 1800,
  double avgSpeed = 10,
  int calories = 300,
}) {
  return CardioSessionEntity(
    id: id,
    type: 'run',
    distance: distance,
    duration: duration,
    avgSpeed: avgSpeed,
    pace: '06:00',
    calories: calories,
    date: DateTime(2026, 5, 4),
  );
}

AthleteMetrics _metrics({
  List<WorkoutSessionEntity> sessions = const [],
  List<WorkoutSetEntity> sets = const [],
  List<CardioSessionEntity> cardio = const [],
  List<ExerciseEntity> exercises = const [],
}) {
  return AthleteMetrics.from(
    workoutSessions: sessions,
    workoutSets: sets,
    cardioSessions: cardio,
    exercises: exercises,
  );
}

void main() {
  group('AthleteMetrics.from', () {
    test('senza dati ogni metrica vale zero', () {
      final metrics = _metrics();

      for (final metric in AthleteMetric.values) {
        expect(metrics.valueOf(metric), 0, reason: metric.name);
      }
      expect(metrics.favoriteExerciseId, isNull);
      expect(metrics.heaviestSetExerciseId, isNull);
    });

    test('conta gli allenamenti dai set quando mancano le sessioni', () {
      final metrics = _metrics(
        sets: [_set(workoutId: 10), _set(id: 2, workoutId: 11)],
      );

      expect(metrics.completedWorkouts, 2);
    });

    test('il volume migliore e quello della sessione piu pesante', () {
      final metrics = _metrics(
        sets: [
          _set(weight: 100), // 1000 kg
          _set(id: 2, workoutId: 2, weight: 60), // 600 kg
        ],
      );

      expect(metrics.bestSessionVolume, 1000);
      expect(metrics.totalVolume, 1600);
    });

    test('somma ripetizioni e serie di tutti i set', () {
      final metrics = _metrics(sets: [_set(reps: 8), _set(id: 2, reps: 12)]);

      expect(metrics.totalReps, 20);
      expect(metrics.totalSets, 2);
    });

    test('il set piu pesante porta con se il proprio esercizio', () {
      final metrics = _metrics(
        sets: [_set(weight: 80), _set(id: 2, weight: 120, exerciseId: 7)],
      );

      expect(metrics.heaviestWeight, 120);
      expect(metrics.heaviestSetExerciseId, 7);
    });

    test('il massimale stimato ignora i set senza peso o ripetizioni', () {
      final metrics = _metrics(
        sets: [
          _set(weight: 0, reps: 20, exerciseId: 3),
          _set(id: 2, weight: 100, reps: 5, exerciseId: 4),
        ],
      );

      expect(metrics.bestOneRepMaxExerciseId, 4);
      expect(metrics.bestOneRepMax, greaterThan(100));
    });

    test('l esercizio preferito e quello con piu serie', () {
      final metrics = _metrics(
        sets: [_set(), _set(id: 2, exerciseId: 2), _set(id: 3, exerciseId: 2)],
      );

      expect(metrics.favoriteExerciseId, 2);
    });

    test('le ripetizioni del badge guardano il singolo esercizio', () {
      final metrics = _metrics(
        sets: [
          _set(reps: 30),
          _set(id: 2, exerciseId: 2),
          _set(id: 3, exerciseId: 2),
        ],
      );

      expect(metrics.repsOnBestExercise, 30);
    });

    test('prima delle 8 e mattiniera, dalle 21 e serale', () {
      final metrics = _metrics(
        sessions: [
          _session(date: DateTime(2026, 5, 4, 7, 30)),
          _session(id: 2, date: DateTime(2026, 5, 5, 21, 10)),
          _session(id: 3, date: DateTime(2026, 5, 6, 18)),
        ],
      );

      expect(metrics.earlyMorningSessions, 1);
      expect(metrics.lateEveningSessions, 1);
    });

    test('una sessione conta una volta sola come giornata gambe', () {
      final metrics = _metrics(
        sets: [_set(), _set(id: 2, exerciseId: 2)],
        exercises: const [
          ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Quadricipiti'),
          ExerciseEntity(id: 2, name: 'Stacco', targetMuscle: 'Femorali'),
        ],
      );

      expect(metrics.legDaySessions, 1);
      expect(metrics.pushDaySessions, 0);
    });

    test('la striscia di settimane si interrompe quando ne salta una', () {
      final metrics = _metrics(
        sessions: [
          _session(date: DateTime(2026, 5, 4)),
          _session(id: 2, date: DateTime(2026, 5, 11)),
          _session(id: 3, date: DateTime(2026, 5, 25)),
        ],
      );

      expect(metrics.consecutiveWeeks, 2);
    });

    test('la settimana record e quella con piu sessioni', () {
      final metrics = _metrics(
        sessions: [
          _session(date: DateTime(2026, 5, 4)),
          _session(id: 2, date: DateTime(2026, 5, 6)),
          _session(id: 3, date: DateTime(2026, 5, 8)),
          _session(id: 4, date: DateTime(2026, 5, 11)),
        ],
      );

      expect(metrics.bestWeeklyWorkouts, 3);
    });

    test('la sessione piu lunga e in minuti interi', () {
      final metrics = _metrics(
        sessions: [
          _session(durationSeconds: 3600),
          _session(id: 2, durationSeconds: 7250),
        ],
      );

      expect(metrics.longestSessionMinutes, 120);
      expect(metrics.totalWorkoutSeconds, 10850);
    });

    test('il ritmo veloce scatta a cinque minuti al chilometro', () {
      final lento = _metrics(cardio: [_cardio(avgSpeed: 11)]);
      final veloce = _metrics(cardio: [_cardio(avgSpeed: 12)]);

      expect(lento.fastPaceReached, isFalse);
      expect(veloce.fastPaceReached, isTrue);
    });

    test('il cardio somma i chilometri e tiene i massimi', () {
      final metrics = _metrics(
        cardio: [
          _cardio(),
          _cardio(
            id: 2,
            distance: 12,
            duration: 3600,
            calories: 800,
            avgSpeed: 12,
          ),
        ],
      );

      expect(metrics.cardioKilometers, 17);
      expect(metrics.cardioMinutes, 90);
      expect(metrics.cardioSessions, 2);
      expect(metrics.bestSessionCalories, 800);
      expect(metrics.longestCardioSeconds, 3600);
      expect(metrics.longestCardioDistance, 12);
      expect(metrics.fastestCardioSpeed, 12);
    });

    test('panca e squat sono riconosciuti dal nome dell esercizio', () {
      final metrics = _metrics(
        sets: [
          _set(weight: 100),
          _set(id: 2, exerciseId: 2, weight: 120),
          _set(id: 3, exerciseId: 3),
        ],
        exercises: const [
          ExerciseEntity(id: 1, name: 'Panca piana', targetMuscle: 'Petto'),
          ExerciseEntity(id: 2, name: 'Squat', targetMuscle: 'Gambe'),
          ExerciseEntity(id: 3, name: 'Curl', targetMuscle: 'Bicipiti'),
        ],
      );

      expect(metrics.benchVolume, 1000);
      expect(metrics.squatVolume, 1200);
    });

    test('i nomi degli esercizi restano consultabili per id', () {
      final metrics = _metrics(
        sets: [_set()],
        exercises: const [
          ExerciseEntity(id: 1, name: 'Panca piana', targetMuscle: 'Petto'),
        ],
      );

      expect(metrics.exerciseNames[1], 'Panca piana');
    });
  });
}
