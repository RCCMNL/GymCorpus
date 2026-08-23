import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Aggrega numero di sessioni, minuti totali e volume sollevato da una
/// lista di set di allenamento.
///
/// Prima questo calcolo viveva duplicato quasi verbatim in
/// analytics_screen.dart, una volta per il totale e una per il mese
/// corrente: le due copie andavano tenute sincronizzate a mano a ogni
/// modifica. Estratto qui come tipo puro, testabile senza montare un
/// widget.
class WorkoutStatsSummary {
  const WorkoutStatsSummary({
    required this.sessionsCount,
    required this.totalMinutes,
    required this.totalWeight,
  });

  factory WorkoutStatsSummary.fromLogs(List<WorkoutSetEntity> logs) {
    if (logs.isEmpty) return empty;

    final sessionsCount = logs.map((e) => e.workoutId).toSet().length;
    final totalWeight = logs.fold<double>(
      0,
      (sum, e) => sum + (e.weight * e.reps),
    );

    var totalSeconds = 0;
    final workoutIds = logs.map((e) => e.workoutId).toSet();
    for (final workoutId in workoutIds) {
      final sessionLogs = logs.where((e) => e.workoutId == workoutId).toList();
      totalSeconds += estimateSessionDurationSeconds(sessionLogs, workoutId);
    }

    return WorkoutStatsSummary(
      sessionsCount: sessionsCount,
      totalMinutes: (totalSeconds / 60).round(),
      totalWeight: totalWeight,
    );
  }

  static const empty = WorkoutStatsSummary(
    sessionsCount: 0,
    totalMinutes: 0,
    totalWeight: 0,
  );

  final int sessionsCount;
  final int totalMinutes;
  final double totalWeight;
}

/// Stima la durata in secondi di una sessione di allenamento dai suoi set.
///
/// L'RPE dell'ultimo set, quando presente, e' in realta' la durata reale
/// della sessione in secondi: e' la convenzione usata da
/// `TrainingScreen._completeSet` per salvare il tempo trascorso al
/// completamento, riusando il campo RPE invece di uno dedicato.
///
/// In assenza di quel valore si ricorre a un'euristica sull'id della
/// sessione: se [workoutId] supera 10^12 assomiglia a un timestamp in
/// millisecondi (oltre l'anno 2001), quindi viene trattato come l'istante
/// di inizio e la durata e' la differenza dal timestamp dell'ultimo set.
/// Altrimenti (id incrementale, il caso piu' comune) si usa la differenza
/// tra il set piu' vecchio e quello piu' recente. Un risultato negativo,
/// possibile con dati corrotti o un orologio di sistema spostato, ricade
/// su una stima fissa di 3 minuti per set.
int estimateSessionDurationSeconds(
  List<WorkoutSetEntity> sessionLogs,
  int workoutId,
) {
  final withRpe = sessionLogs.where((e) => e.rpe != null).toList();
  if (withRpe.isNotEmpty) {
    return withRpe.last.rpe!;
  }

  final timestamps = sessionLogs.map((e) => e.timestamp.millisecondsSinceEpoch);
  final maxTs = timestamps.reduce((a, b) => a > b ? a : b);

  int durationSec;
  if (workoutId > 1000000000000) {
    durationSec = ((maxTs - workoutId) / 1000).round();
  } else {
    final minTs = timestamps.reduce((a, b) => a < b ? a : b);
    durationSec = ((maxTs - minTs) / 1000).round();
  }

  return durationSec < 0 ? sessionLogs.length * 180 : durationSec;
}
