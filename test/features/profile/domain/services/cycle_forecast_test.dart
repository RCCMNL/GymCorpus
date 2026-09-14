import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';

/// Il calendario ciclo mostrava un giorno fisso inventato. Queste prove
/// fissano il comportamento opposto: ogni numero mostrato deve venire dalle
/// date registrate, e quando le date non bastano lo stato deve dirlo invece
/// di riempire i buchi con una media plausibile.
void main() {
  CycleLogEntity log(int id, DateTime start, [DateTime? end]) =>
      CycleLogEntity(id: id, startDate: start, endDate: end);

  group('senza dati sufficienti', () {
    test('senza registrazioni non esiste un giorno del ciclo', () {
      final summary = CycleForecast.calculate(
        logs: const [],
        today: DateTime(2026, 9, 5),
      );

      expect(summary.state, CycleDataState.empty);
      expect(summary.dayOfCycle, isNull);
      expect(summary.phase, isNull);
      expect(summary.nextPeriodStart, isNull);
    });

    test('con un solo ciclo la durata resta una stima dichiarata', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 9))],
        today: DateTime(2026, 9, 5),
      );

      expect(summary.cycleLength, 28);
      expect(summary.isEstimatedLength, isTrue);
    });
  });

  group('giorno del ciclo e fase', () {
    test('il giorno del ciclo si conta dall ultimo inizio registrato', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 9, 3))],
        today: DateTime(2026, 9, 5),
      );

      expect(summary.dayOfCycle, 3);
    });

    test('un ciclo ancora aperto risulta in corso', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 9, 3))],
        today: DateTime(2026, 9, 5),
      );

      expect(summary.state, CycleDataState.ongoing);
      expect(summary.hasOpenLog, isTrue);
      expect(summary.phase, CyclePhase.menstrual);
    });

    test('un ciclo chiuso lascia lo stato tra un ciclo e l altro', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 9), DateTime(2026, 9, 5))],
        today: DateTime(2026, 9, 10),
      );

      expect(summary.state, CycleDataState.betweenCycles);
      expect(summary.hasOpenLog, isFalse);
      expect(summary.phase, CyclePhase.follicular);
    });

    test('le fasi seguono la durata reale, non i 28 giorni di default', () {
      // Tre inizi a 34 giorni di distanza: l ovulazione attesa cade al
      // giorno 20 (34 - 14), non al 14 come nella versione a numeri fissi.
      final logs = [
        log(1, DateTime(2026, 6), DateTime(2026, 6, 5)),
        log(2, DateTime(2026, 7, 5), DateTime(2026, 7, 9)),
        log(3, DateTime(2026, 8, 8), DateTime(2026, 8, 12)),
      ];

      final atDay14 = CycleForecast.calculate(
        logs: logs,
        today: DateTime(2026, 8, 21),
      );
      final atDay20 = CycleForecast.calculate(
        logs: logs,
        today: DateTime(2026, 8, 27),
      );

      expect(atDay14.dayOfCycle, 14);
      expect(atDay14.phase, CyclePhase.follicular);
      expect(atDay20.dayOfCycle, 20);
      expect(atDay20.phase, CyclePhase.ovulatory);
    });

    test('dopo la finestra ovulatoria la fase e luteale', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 9), DateTime(2026, 9, 5))],
        today: DateTime(2026, 9, 20),
      );

      expect(summary.dayOfCycle, 20);
      expect(summary.phase, CyclePhase.luteal);
    });
  });

  group('medie e previsione', () {
    test('la durata media viene dagli intervalli tra inizi consecutivi', () {
      final summary = CycleForecast.calculate(
        logs: [
          log(1, DateTime(2026, 6)),
          log(2, DateTime(2026, 7)),
          log(3, DateTime(2026, 7, 31)),
        ],
        today: DateTime(2026, 8, 5),
      );

      expect(summary.cycleLength, 30);
      expect(summary.isEstimatedLength, isFalse);
    });

    test('gli intervalli assurdi non entrano nella media', () {
      // Un anno di silenzio tra due registrazioni non e un ciclo di 365
      // giorni: e una lacuna, e non deve spostare la media.
      final summary = CycleForecast.calculate(
        logs: [
          log(1, DateTime(2025, 6)),
          log(2, DateTime(2026, 6)),
          log(3, DateTime(2026, 7)),
        ],
        today: DateTime(2026, 7, 5),
      );

      expect(summary.cycleLength, 30);
    });

    test('la durata delle mestruazioni viene dai cicli chiusi', () {
      final summary = CycleForecast.calculate(
        logs: [
          log(1, DateTime(2026, 7), DateTime(2026, 7, 6)),
          log(2, DateTime(2026, 7, 29), DateTime(2026, 8, 2)),
        ],
        today: DateTime(2026, 8, 5),
      );

      // 6 giorni e 5 giorni: media 5.5, arrotondata a 6.
      expect(summary.periodLength, 6);
    });

    test('il prossimo ciclo e previsto a una durata media dall ultimo', () {
      final summary = CycleForecast.calculate(
        logs: [
          log(1, DateTime(2026, 7)),
          log(2, DateTime(2026, 7, 31), DateTime(2026, 8, 4)),
        ],
        today: DateTime(2026, 8, 10),
      );

      expect(summary.nextPeriodStart, DateTime(2026, 8, 30));
      expect(summary.daysLate, isNull);
    });

    test('oltre la data prevista il ritardo viene contato', () {
      final summary = CycleForecast.calculate(
        logs: [
          log(1, DateTime(2026, 7)),
          log(2, DateTime(2026, 7, 31), DateTime(2026, 8, 4)),
        ],
        today: DateTime(2026, 9, 2),
      );

      expect(summary.daysLate, 3);
    });
  });

  group('dati non piu attendibili', () {
    test('un ultimo inizio troppo lontano non produce un giorno del ciclo', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 3), DateTime(2026, 3, 5))],
        today: DateTime(2026, 9, 5),
      );

      expect(summary.state, CycleDataState.stale);
      expect(summary.dayOfCycle, isNull);
      expect(summary.phase, isNull);
    });

    test('un ciclo aperto e dimenticato resta chiudibile', () {
      final summary = CycleForecast.calculate(
        logs: [log(1, DateTime(2026, 3))],
        today: DateTime(2026, 9, 5),
      );

      expect(summary.state, CycleDataState.stale);
      expect(summary.hasOpenLog, isTrue);
    });
  });

  test('i log arrivano in ordine qualsiasi', () {
    final summary = CycleForecast.calculate(
      logs: [
        CycleLogEntity(
          id: 2,
          startDate: DateTime(2026, 8, 30),
          endDate: DateTime(2026, 9, 3),
        ),
        CycleLogEntity(
          id: 1,
          startDate: DateTime(2026, 8),
          endDate: DateTime(2026, 8, 5),
        ),
      ],
      today: DateTime(2026, 9, 5),
    );

    expect(summary.dayOfCycle, 7);
    expect(summary.cycleLength, 29);
  });

  test('l ora del giorno non sposta il conteggio', () {
    final summary = CycleForecast.calculate(
      logs: [log(1, DateTime(2026, 9, 3, 23, 30))],
      today: DateTime(2026, 9, 5, 0, 15),
    );

    expect(summary.dayOfCycle, 3);
  });
}
