import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/workout_report.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

void main() {
  const exercises = [
    ExerciseEntity(id: 1, name: 'Back Squat', targetMuscle: 'Gambe'),
    ExerciseEntity(id: 2, name: 'Panca piana', targetMuscle: 'Petto'),
  ];

  WorkoutSetEntity set({
    required int exerciseId,
    required double weight,
    required int reps,
    required DateTime timestamp,
  }) => WorkoutSetEntity(
    id: timestamp.microsecondsSinceEpoch,
    workoutId: 1,
    exerciseId: exerciseId,
    reps: reps,
    weight: weight,
    timestamp: timestamp,
  );

  final generatedAt = DateTime(2026, 8, 30, 16, 5);

  group('buildWorkoutReport', () {
    test('risolve il nome dell esercizio, non solo l id', () {
      // Regressione: la tabella mostrava data/peso/ripetizioni senza dire
      // quale esercizio fosse, rendendo il report inutile.
      final report = buildWorkoutReport(
        sessions: const [],
        sets: [
          set(
            exerciseId: 1,
            weight: 100,
            reps: 5,
            timestamp: DateTime(2026, 8, 29),
          ),
        ],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      expect(report.rows.single.exercise, 'Back Squat');
    });

    test('un esercizio eliminato non lascia la cella vuota', () {
      final report = buildWorkoutReport(
        sessions: const [],
        sets: [
          set(
            exerciseId: 999,
            weight: 60,
            reps: 8,
            timestamp: DateTime(2026, 8, 29),
          ),
        ],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      expect(report.rows.single.exercise, isNotEmpty);
    });

    test('rispetta l unita di misura scelta dall utente', () {
      // Regressione: il PDF scriveva "kg" fisso, quindi per chi usa le
      // libbre riportava numeri corretti con l'unita' sbagliata.
      final sets = [
        set(
          exerciseId: 1,
          weight: 100,
          reps: 10,
          timestamp: DateTime(2026, 8, 29),
        ),
      ];

      final metric = buildWorkoutReport(
        sessions: const [],
        sets: sets,
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );
      expect(metric.rows.single.load, contains('kg'));
      expect(metric.rows.single.load, contains('100'));
      expect(metric.totalVolume, contains('kg'));

      final imperial = buildWorkoutReport(
        sessions: const [],
        sets: sets,
        exercises: exercises,
        isImperial: true,
        generatedAt: generatedAt,
      );
      expect(imperial.rows.single.load, contains('lb'));
      expect(imperial.rows.single.load, contains('220'));
      expect(imperial.totalVolume, contains('lb'));
    });

    test('il volume totale e peso per ripetizioni su tutte le serie', () {
      final report = buildWorkoutReport(
        sessions: const [],
        sets: [
          set(
            exerciseId: 1,
            weight: 100,
            reps: 5,
            timestamp: DateTime(2026, 8, 29),
          ),
          set(
            exerciseId: 2,
            weight: 50,
            reps: 10,
            timestamp: DateTime(2026, 8, 28),
          ),
        ],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      // 100*5 + 50*10 = 1000
      expect(report.totalVolume, contains('1.000'));
      expect(report.loggedSets, 2);
    });

    test('conta solo gli allenamenti completati', () {
      final report = buildWorkoutReport(
        sessions: [
          WorkoutSessionEntity(
            id: 1,
            date: DateTime(2026, 8, 29),
            name: 'A',
            completedAt: DateTime(2026, 8, 29, 18),
          ),
          WorkoutSessionEntity(id: 2, date: DateTime(2026, 8, 30), name: 'B'),
        ],
        sets: const [],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      expect(report.completedWorkouts, 1);
    });

    test('le serie sono ordinate dalla piu recente', () {
      final report = buildWorkoutReport(
        sessions: const [],
        sets: [
          set(
            exerciseId: 1,
            weight: 10,
            reps: 1,
            timestamp: DateTime(2026, 8, 20),
          ),
          set(
            exerciseId: 2,
            weight: 20,
            reps: 2,
            timestamp: DateTime(2026, 8, 29),
          ),
        ],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      expect(report.rows.first.exercise, 'Panca piana');
      expect(report.rows.last.exercise, 'Back Squat');
    });

    test('limita le righe ma tiene le statistiche su tutto lo storico', () {
      final report = buildWorkoutReport(
        sessions: const [],
        sets: [
          for (var i = 0; i < 60; i++)
            set(
              exerciseId: 1,
              weight: 10,
              reps: 1,
              timestamp: DateTime(2026, 8, 2).add(Duration(hours: i * 5)),
            ),
        ],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
        maxRows: 25,
      );

      expect(report.rows.length, 25);
      expect(report.loggedSets, 60, reason: 'il totale non va troncato');
    });

    test('senza serie il report si dichiara vuoto invece di mentire', () {
      final report = buildWorkoutReport(
        sessions: const [],
        sets: const [],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      expect(report.hasData, isFalse);
      expect(report.loggedSets, 0);
    });

    test('la data di generazione e leggibile, non un DateTime grezzo', () {
      // Regressione: il PDF stampava "Report generato il
      // 2026-08-30 16:05:42.123456".
      final report = buildWorkoutReport(
        sessions: const [],
        sets: const [],
        exercises: exercises,
        isImperial: false,
        generatedAt: generatedAt,
      );

      expect(report.generatedAt, '30 AGO 2026, 16:05');
    });
  });
}
