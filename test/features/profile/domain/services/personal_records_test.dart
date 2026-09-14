import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_metrics.dart';
import 'package:gym_corpus/features/profile/domain/services/personal_records.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

List<PersonalRecord> _records({
  List<WorkoutSessionEntity> sessions = const [],
  List<WorkoutSetEntity> sets = const [],
  List<CardioSessionEntity> cardio = const [],
  List<ExerciseEntity> exercises = const [],
}) {
  return PersonalRecords.from(
    AthleteMetrics.from(
      workoutSessions: sessions,
      workoutSets: sets,
      cardioSessions: cardio,
      exercises: exercises,
    ),
  );
}

String _value(List<PersonalRecord> records, String title) =>
    records.firstWhere((record) => record.title == title).value;

String _subtitle(List<PersonalRecord> records, String title) =>
    records.firstWhere((record) => record.title == title).subtitle;

WorkoutSetEntity _set({
  int id = 1,
  int exerciseId = 1,
  int reps = 10,
  double weight = 50,
}) {
  return WorkoutSetEntity(
    id: id,
    workoutId: 1,
    exerciseId: exerciseId,
    reps: reps,
    weight: weight,
    timestamp: DateTime(2026, 5, 4),
  );
}

void main() {
  group('PersonalRecords.from', () {
    test('senza dati i record restano un trattino', () {
      final records = _records();

      expect(_value(records, 'Set piu pesante'), '-');
      expect(_value(records, '1RM stimato'), '-');
      expect(_value(records, 'Distanza cardio'), '-');
      expect(_value(records, 'Velocita media'), '-');
      expect(_subtitle(records, 'Set piu pesante'), 'Nessun set registrato');
      expect(_subtitle(records, 'Distanza cardio'), 'Nessuna sessione');
    });

    test('il set piu pesante mostra il nome del suo esercizio', () {
      final records = _records(
        sets: [_set(weight: 80), _set(id: 2, exerciseId: 2, weight: 122.5)],
        exercises: const [
          ExerciseEntity(id: 1, name: 'Panca', targetMuscle: 'Petto'),
          ExerciseEntity(id: 2, name: 'Stacco', targetMuscle: 'Schiena'),
        ],
      );

      expect(_value(records, 'Set piu pesante'), '122.5 kg');
      expect(_subtitle(records, 'Set piu pesante'), 'Stacco');
    });

    test('un esercizio fuori catalogo resta senza nome ma col suo record', () {
      final records = _records(sets: [_set(weight: 90)]);

      expect(_value(records, 'Set piu pesante'), '90.0 kg');
      expect(_subtitle(records, 'Set piu pesante'), 'Esercizio registrato');
    });

    test('l esercizio preferito e nessuno finche non ci sono set', () {
      expect(_value(_records(), 'Esercizio Preferito'), 'Nessuno');
    });

    test('i numeri grandi sono abbreviati in k e in M', () {
      final grande = _records(
        sets: [_set(weight: 100, reps: 200)], // 20.000 kg
      );
      final enorme = _records(
        sets: [_set(weight: 1000, reps: 2000)], // 2.000.000 kg
      );

      expect(_value(grande, 'Volume Totale'), '20.0k kg');
      expect(_value(enorme, 'Volume Totale'), '2.00M kg');
    });

    test('sotto i diecimila il volume totale resta per intero', () {
      final records = _records(sets: [_set(weight: 100)]);

      expect(_value(records, 'Volume Totale'), '1000 kg');
    });

    test('il tempo di allenamento e in ore con un decimale', () {
      final records = _records(
        sessions: [
          WorkoutSessionEntity(
            id: 1,
            date: DateTime(2026, 5, 4),
            name: 'Upper',
            completedAt: DateTime(2026, 5, 4),
            durationSeconds: 5400,
          ),
        ],
      );

      expect(_value(records, 'Tempo allenamento'), '1.5 h');
    });

    test('la sessione cardio piu lunga e in ore e minuti', () {
      final records = _records(
        cardio: [
          CardioSessionEntity(
            id: 1,
            type: 'run',
            distance: 12.345,
            duration: 4500,
            avgSpeed: 9.87,
            pace: '06:05',
            calories: 700,
            date: DateTime(2026, 5, 4),
          ),
        ],
      );

      expect(_value(records, 'Cardio Record (Tempo)'), '1h 15m');
      expect(_value(records, 'Distanza cardio'), '12.35 km');
      expect(_value(records, 'Velocita media'), '9.9 km/h');
      expect(_value(records, 'Calorie Record'), '700 kcal');
    });
  });
}
