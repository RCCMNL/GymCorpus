import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';

/// Fasi del ciclo mostrate in app.
enum CyclePhase { menstrual, follicular, ovulatory, luteal }

/// Quanto sono utilizzabili le registrazioni dell'utente.
///
/// Serve a non mostrare mai un numero inventato: senza dati, o con dati
/// troppo vecchi, la schermata deve chiedere una registrazione invece di
/// esibire un giorno del ciclo qualsiasi.
enum CycleDataState {
  /// Nessuna mestruazione registrata.
  empty,

  /// Mestruazione in corso: esiste un log senza data di fine.
  ongoing,

  /// Ultimo ciclo concluso, si e' nella parte centrale del ciclo.
  betweenCycles,

  /// L'ultimo inizio e' cosi' lontano che contare i giorni non significa piu' nulla.
  stale,
}

/// Riepilogo derivato dalle registrazioni: tutto qui dentro viene calcolato,
/// niente viene memorizzato.
class CycleSummary extends Equatable {
  const CycleSummary({
    required this.state,
    required this.cycleLength,
    required this.periodLength,
    required this.isEstimatedLength,
    required this.hasOpenLog,
    this.dayOfCycle,
    this.phase,
    this.nextPeriodStart,
    this.daysLate,
  });

  final CycleDataState state;

  /// Durata media del ciclo in giorni.
  final int cycleLength;

  /// Durata media delle mestruazioni in giorni.
  final int periodLength;

  /// `true` finche' non ci sono abbastanza cicli per una media reale.
  final bool isEstimatedLength;

  /// Esiste una mestruazione registrata e non ancora conclusa.
  final bool hasOpenLog;

  /// Giorno corrente del ciclo, `null` quando i dati non lo consentono.
  final int? dayOfCycle;

  final CyclePhase? phase;

  /// Inizio previsto della prossima mestruazione.
  final DateTime? nextPeriodStart;

  /// Giorni di ritardo rispetto alla previsione, `null` se non in ritardo.
  final int? daysLate;

  @override
  List<Object?> get props => [
    state,
    cycleLength,
    periodLength,
    isEstimatedLength,
    hasOpenLog,
    dayOfCycle,
    phase,
    nextPeriodStart,
    daysLate,
  ];
}

/// Calcola giorno, fase e previsioni a partire dalle sole date registrate.
class CycleForecast {
  const CycleForecast._();

  /// Valori usati finche' l'utente non ha registrato abbastanza cicli.
  static const defaultCycleLength = 28;
  static const defaultPeriodLength = 5;

  /// Intervalli fuori da questa finestra sono lacune di registrazione, non
  /// cicli: includerli nella media la falserebbe di mesi.
  static const _minPlausibleInterval = 15;
  static const _maxPlausibleInterval = 60;

  static CycleSummary calculate({
    required List<CycleLogEntity> logs,
    required DateTime today,
  }) {
    final sorted = logs.map(_normalize).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final now = _dateOnly(today);

    final cycleLength = _averageCycleLength(sorted);
    final periodLength = _averagePeriodLength(sorted);

    if (sorted.isEmpty) {
      return CycleSummary(
        state: CycleDataState.empty,
        cycleLength: cycleLength.value,
        periodLength: periodLength,
        isEstimatedLength: cycleLength.isEstimated,
        hasOpenLog: false,
      );
    }

    final last = sorted.last;
    // Solo l'ultima registrazione puo' essere "in corso": una vecchia
    // rimasta senza data di fine e' storia incompleta, non una mestruazione
    // di oggi, e non deve nascondere il ritardo del ciclo attuale.
    final hasOpenLog = last.isOngoing;
    final dayOfCycle = now.difference(last.startDate).inDays + 1;

    // Oltre questa distanza il conteggio direbbe "giorno 190": un numero
    // formalmente esatto e praticamente inutile.
    final staleAfter = math.max(60, cycleLength.value * 2);
    if (dayOfCycle > staleAfter) {
      return CycleSummary(
        state: CycleDataState.stale,
        cycleLength: cycleLength.value,
        periodLength: periodLength,
        isEstimatedLength: cycleLength.isEstimated,
        hasOpenLog: hasOpenLog,
      );
    }

    final nextPeriodStart = last.startDate.add(
      Duration(days: cycleLength.value),
    );
    final lateDays = now.difference(nextPeriodStart).inDays;

    return CycleSummary(
      state: hasOpenLog ? CycleDataState.ongoing : CycleDataState.betweenCycles,
      cycleLength: cycleLength.value,
      periodLength: periodLength,
      isEstimatedLength: cycleLength.isEstimated,
      hasOpenLog: hasOpenLog,
      dayOfCycle: dayOfCycle,
      phase: _phaseFor(
        dayOfCycle: dayOfCycle,
        cycleLength: cycleLength.value,
        periodLength: periodLength,
      ),
      nextPeriodStart: nextPeriodStart,
      daysLate: !hasOpenLog && lateDays > 0 ? lateDays : null,
    );
  }

  /// Fasi ancorate all'ovulazione, che cade circa 14 giorni prima del ciclo
  /// successivo: a variare da persona a persona e' la lunghezza della fase
  /// follicolare, non quella luteale.
  static CyclePhase _phaseFor({
    required int dayOfCycle,
    required int cycleLength,
    required int periodLength,
  }) {
    final ovulationDay = math.max(cycleLength - 14, periodLength + 2);

    if (dayOfCycle <= periodLength) return CyclePhase.menstrual;
    if (dayOfCycle < ovulationDay - 1) return CyclePhase.follicular;
    if (dayOfCycle <= ovulationDay + 1) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  static _AverageLength _averageCycleLength(List<CycleLogEntity> sorted) {
    final intervals = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final days = sorted[i].startDate
          .difference(sorted[i - 1].startDate)
          .inDays;
      if (days >= _minPlausibleInterval && days <= _maxPlausibleInterval) {
        intervals.add(days);
      }
    }

    if (intervals.isEmpty) {
      return const _AverageLength(defaultCycleLength, isEstimated: true);
    }

    final average = intervals.reduce((a, b) => a + b) / intervals.length;
    return _AverageLength(
      average.round().clamp(21, 35),
      isEstimated: false,
    );
  }

  static int _averagePeriodLength(List<CycleLogEntity> sorted) {
    final durations = <int>[];
    for (final log in sorted) {
      final end = log.endDate;
      if (end == null) continue;
      final days = end.difference(log.startDate).inDays + 1;
      if (days >= 1 && days <= 15) durations.add(days);
    }

    if (durations.isEmpty) return defaultPeriodLength;

    final average = durations.reduce((a, b) => a + b) / durations.length;
    return average.round().clamp(2, 10);
  }

  /// L'ora di registrazione non deve spostare il conteggio dei giorni: una
  /// mestruazione segnata alle 23:30 e una alle 00:15 sono lo stesso giorno.
  static CycleLogEntity _normalize(CycleLogEntity log) => CycleLogEntity(
    id: log.id,
    startDate: _dateOnly(log.startDate),
    endDate: log.endDate == null ? null : _dateOnly(log.endDate!),
  );

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _AverageLength {
  const _AverageLength(this.value, {required this.isEstimated});

  final int value;
  final bool isEstimated;
}
