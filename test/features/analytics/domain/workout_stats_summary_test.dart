import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/analytics/domain/analytics_formatters.dart';
import 'package:gym_corpus/features/analytics/domain/workout_stats_summary.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

WorkoutSetEntity _set({
  required int id,
  required int workoutId,
  required DateTime timestamp,
  int? rpe,
  double weight = 80,
  int reps = 5,
}) {
  return WorkoutSetEntity(
    id: id,
    workoutId: workoutId,
    exerciseId: 1,
    reps: reps,
    weight: weight,
    timestamp: timestamp,
    rpe: rpe,
  );
}

void main() {
  group('estimateSessionDurationSeconds', () {
    test('usa l RPE dell ultimo set quando presente, come durata reale', () {
      // Convenzione di TrainingScreen._completeSet: il campo RPE dell'ultimo
      // set salvato non e' un RPE, e' la durata della sessione in secondi.
      final logs = [
        _set(id: 1, workoutId: 1, timestamp: DateTime(2026, 4, 26, 10)),
        _set(
          id: 2,
          workoutId: 1,
          timestamp: DateTime(2026, 4, 26, 10, 5),
          rpe: 1800,
        ),
      ];

      expect(estimateSessionDurationSeconds(logs, 1), 1800);
    });

    test(
      'un workoutId che sembra un timestamp usa la differenza dall ultimo set',
      () {
        // 1_777_000_000_000 e' oltre l'anno 2001: trattato come istante di
        // inizio sessione in millisecondi.
        const workoutId = 1777000000000;
        final start = DateTime.fromMillisecondsSinceEpoch(workoutId);
        final logs = [
          _set(id: 1, workoutId: workoutId, timestamp: start),
          _set(
            id: 2,
            workoutId: workoutId,
            timestamp: start.add(const Duration(seconds: 900)),
          ),
        ];

        expect(estimateSessionDurationSeconds(logs, workoutId), 900);
      },
    );

    test(
      'un workoutId incrementale usa la differenza tra il primo e l ultimo set',
      () {
        final logs = [
          _set(id: 1, workoutId: 42, timestamp: DateTime(2026, 4, 26, 10)),
          _set(id: 2, workoutId: 42, timestamp: DateTime(2026, 4, 26, 10, 12)),
          _set(id: 3, workoutId: 42, timestamp: DateTime(2026, 4, 26, 10, 20)),
        ];

        expect(estimateSessionDurationSeconds(logs, 42), 20 * 60);
      },
    );

    test('una durata negativa ricade su 3 minuti per set', () {
      // Nel ramo con id incrementale la durata e' sempre max-min, quindi non
      // puo' mai essere negativa: il fallback scatta solo nel ramo
      // id-come-timestamp, quando il workoutId (trattato come istante di
      // inizio) e' successivo ai timestamp reali dei set, per esempio con
      // dati corrotti o un orologio di sistema desincronizzato.
      final start = DateTime(2026, 4, 26, 10, 30);
      final workoutId = start.millisecondsSinceEpoch;
      final logs = [
        _set(id: 1, workoutId: workoutId, timestamp: DateTime(2026, 4, 26, 10)),
        _set(
          id: 2,
          workoutId: workoutId,
          timestamp: DateTime(2026, 4, 26, 10, 5),
        ),
        _set(
          id: 3,
          workoutId: workoutId,
          timestamp: DateTime(2026, 4, 26, 10, 10),
        ),
      ];

      expect(estimateSessionDurationSeconds(logs, workoutId), 3 * 180);
    });
  });

  group('WorkoutStatsSummary.fromLogs', () {
    test('una lista vuota restituisce WorkoutStatsSummary.empty', () {
      expect(WorkoutStatsSummary.fromLogs(const []), WorkoutStatsSummary.empty);
    });

    test('WorkoutStatsSummary.empty ha tutti i campi a zero', () {
      expect(WorkoutStatsSummary.empty.sessionsCount, 0);
      expect(WorkoutStatsSummary.empty.totalMinutes, 0);
      expect(WorkoutStatsSummary.empty.totalWeight, 0);
    });

    test('conta le sessioni come workoutId distinti', () {
      final logs = [
        _set(id: 1, workoutId: 1, timestamp: DateTime(2026, 4, 26), rpe: 600),
        _set(id: 2, workoutId: 1, timestamp: DateTime(2026, 4, 26)),
        _set(id: 3, workoutId: 2, timestamp: DateTime(2026, 4, 27), rpe: 600),
      ];

      final summary = WorkoutStatsSummary.fromLogs(logs);

      expect(summary.sessionsCount, 2);
    });

    test('somma peso per ripetizioni su tutti i set', () {
      final logs = [
        _set(
          id: 1,
          workoutId: 1,
          timestamp: DateTime(2026, 4, 26),
          weight: 100,
          rpe: 600,
        ),
        _set(
          id: 2,
          workoutId: 1,
          timestamp: DateTime(2026, 4, 26),
          weight: 50,
          reps: 10,
        ),
      ];

      final summary = WorkoutStatsSummary.fromLogs(logs);

      // 100*5 + 50*10 = 1000
      expect(summary.totalWeight, 1000);
    });

    test('somma la durata stimata di ogni sessione distinta', () {
      final logs = [
        _set(
          id: 1,
          workoutId: 1,
          timestamp: DateTime(2026, 4, 26, 10),
          rpe: 600, // 10 minuti
        ),
        _set(
          id: 2,
          workoutId: 2,
          timestamp: DateTime(2026, 4, 27, 10),
          rpe: 1200, // 20 minuti
        ),
      ];

      final summary = WorkoutStatsSummary.fromLogs(logs);

      expect(summary.totalMinutes, 30);
    });
  });

  group('formatWorkoutDuration', () {
    test('minuti sotto l ora', () {
      expect(formatWorkoutDuration(45), '45m');
    });

    test('ore esatte senza minuti', () {
      expect(formatWorkoutDuration(120), '2h');
    });

    test('ore e minuti', () {
      expect(formatWorkoutDuration(90), '1h 30m');
    });
  });

  group('formatVolumeKg', () {
    test('sotto i 1000 kg mostra il valore intero', () {
      expect(formatVolumeKg(850), '850 kg');
    });

    test('da 1000 kg in su mostra le migliaia con un decimale', () {
      expect(formatVolumeKg(12345), '12.3k kg');
    });
  });

  group('formatVolumeLb', () {
    test('converte in libbre prima di formattare', () {
      // 100 kg ~= 220.5 lb
      expect(formatVolumeLb(100), '220 lb');
    });

    test('da 1000 lb in su mostra le migliaia con un decimale', () {
      expect(formatVolumeLb(1000), '2.2k lb');
    });
  });

  group('durata reale della sessione', () {
    /// La durata delle sessioni completate sta nella colonna dedicata da
    /// quando esiste: leggerla dal campo rpe era un ripiego dei tempi in cui
    /// quella colonna non c'era, e costringeva a scriverci dentro un numero
    /// di secondi al posto di uno sforzo da 1 a 10.
    WorkoutSessionEntity session(int id, {int? durationSeconds}) =>
        WorkoutSessionEntity(
          id: id,
          date: DateTime(2026, 4, 26),
          name: 'Sessione',
          completedAt: DateTime(2026, 4, 26),
          durationSeconds: durationSeconds,
        );

    test('usa la durata salvata con la sessione', () {
      final logs = [
        _set(id: 1, workoutId: 7, timestamp: DateTime(2026, 4, 26)),
        _set(id: 2, workoutId: 7, timestamp: DateTime(2026, 4, 26)),
      ];

      final summary = WorkoutStatsSummary.fromLogs(
        logs,
        sessions: [session(7, durationSeconds: 1800)],
      );

      expect(summary.totalMinutes, 30);
    });

    test('somma le durate di piu sessioni', () {
      final logs = [
        _set(id: 1, workoutId: 7, timestamp: DateTime(2026, 4, 26)),
        _set(id: 2, workoutId: 8, timestamp: DateTime(2026, 4, 27)),
      ];

      final summary = WorkoutStatsSummary.fromLogs(
        logs,
        sessions: [
          session(7, durationSeconds: 1800),
          session(8, durationSeconds: 600),
        ],
      );

      expect(summary.totalMinutes, 40);
    });

    test('senza durata salvata ricade sulla stima, per i dati vecchi', () {
      // Le sessioni registrate prima della colonna durata portano i secondi
      // nel campo rpe: continuano a contare.
      final logs = [
        _set(id: 1, workoutId: 7, timestamp: DateTime(2026, 4, 26), rpe: 1200),
      ];

      final summary = WorkoutStatsSummary.fromLogs(
        logs,
        sessions: [session(7)],
      );

      expect(summary.totalMinutes, 20);
    });

    test('senza sessioni note resta la stima', () {
      final logs = [
        _set(id: 1, workoutId: 7, timestamp: DateTime(2026, 4, 26), rpe: 600),
      ];

      expect(WorkoutStatsSummary.fromLogs(logs).totalMinutes, 10);
    });
  });
}
