import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_progress_service.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

void main() {
  group('AthleteProgressService', () {
    test('ritorna uno stato vuoto senza dati utente', () {
      final progress = AthleteProgressService.calculate(
        workoutSessions: const [],
        workoutSets: const [],
        cardioSessions: const [],
        exercises: const [],
      );

      expect(progress.xp, 0);
      expect(progress.level, 1);
      expect(progress.levelTitle, 'Recluta');
      expect(progress.unlockedAchievements, 0);
      expect(progress.records, isNotEmpty);
    });

    test('calcola livello, trofei e record dai dati locali', () {
      final now = DateTime(2026, 4, 26);
      final progress = AthleteProgressService.calculate(
        workoutSessions: [
          WorkoutSessionEntity(
            id: 1,
            date: now,
            name: 'Upper',
            completedAt: now,
            durationSeconds: 3600,
          ),
        ],
        workoutSets: [
          WorkoutSetEntity(
            id: 1,
            workoutId: 1,
            exerciseId: 1,
            reps: 5,
            weight: 100,
            timestamp: now,
          ),
          WorkoutSetEntity(
            id: 2,
            workoutId: 1,
            exerciseId: 2,
            reps: 10,
            weight: 60,
            timestamp: now,
          ),
        ],
        cardioSessions: [
          CardioSessionEntity(
            id: 1,
            type: 'run',
            distance: 12,
            duration: 3600,
            avgSpeed: 12,
            pace: '05:00',
            calories: 650,
            date: now,
          ),
        ],
        exercises: const [
          ExerciseEntity(id: 1, name: 'Panca', targetMuscle: 'Petto'),
          ExerciseEntity(id: 2, name: 'Squat', targetMuscle: 'Gambe'),
        ],
      );

      expect(progress.xp, greaterThan(0));
      expect(progress.level, greaterThanOrEqualTo(1));
      expect(progress.unlockedAchievements, greaterThanOrEqualTo(2));
      expect(
        progress.records.map((record) => record.title),
        containsAll(['Set piu pesante', 'Distanza cardio']),
      );
    });

    test('conta gli allenamenti dai workoutId dei set quando mancano sessioni',
        () {
      final now = DateTime(2026, 4, 27);
      final progress = AthleteProgressService.calculate(
        workoutSessions: const [],
        workoutSets: [
          WorkoutSetEntity(
            id: 1,
            workoutId: 10,
            exerciseId: 1,
            reps: 5,
            weight: 80,
            timestamp: now,
          ),
          WorkoutSetEntity(
            id: 2,
            workoutId: 11,
            exerciseId: 1,
            reps: 5,
            weight: 85,
            timestamp: now,
          ),
        ],
        cardioSessions: const [],
        exercises: const [
          ExerciseEntity(id: 1, name: 'Panca', targetMuscle: 'Petto'),
        ],
      );

      final workoutsRecord = progress.records.firstWhere(
        (record) => record.title == 'Allenamenti completati',
      );

      expect(workoutsRecord.value, '2');
      expect(progress.xp, greaterThanOrEqualTo(200));
    });
  });
}
