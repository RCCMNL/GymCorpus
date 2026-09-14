import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

/// Una riga della tabella del report: gia' formattata, cosi' il layout
/// PDF non deve sapere nulla di unita' di misura o date.
class WorkoutReportRow {
  const WorkoutReportRow({
    required this.exercise,
    required this.date,
    required this.load,
    required this.reps,
  });

  final String exercise;
  final String date;
  final String load;
  final String reps;

  List<String> get cells => [date, exercise, load, reps];
}

/// Contenuto del report allenamenti, pronto da impaginare.
class WorkoutReportData {
  const WorkoutReportData({
    required this.generatedAt,
    required this.completedWorkouts,
    required this.loggedSets,
    required this.totalVolume,
    required this.rows,
  });

  final String generatedAt;
  final int completedWorkouts;
  final int loggedSets;

  /// Volume totale sollevato (peso x ripetizioni), nell'unita' scelta
  /// dall'utente.
  final String totalVolume;

  final List<WorkoutReportRow> rows;

  bool get hasData => rows.isNotEmpty;

  static const List<String> columns = [
    'Data',
    'Esercizio',
    'Carico',
    'Ripetizioni',
  ];
}

/// Costruisce il contenuto del report.
///
/// Risolve il nome dell'esercizio per id: prima la tabella mostrava data,
/// peso e ripetizioni senza dire *quale* esercizio fosse, il che rendeva
/// il report praticamente inutile. Rispetta anche l'unita' di misura
/// scelta dall'utente, invece di scrivere "kg" fisso come prima.
WorkoutReportData buildWorkoutReport({
  required List<WorkoutSessionEntity> sessions,
  required List<WorkoutSetEntity> sets,
  required List<ExerciseEntity> exercises,
  required bool isImperial,
  required DateTime generatedAt,
  int maxRows = 40,
}) {
  final unit = isImperial ? WeightUnit.lb : WeightUnit.kg;
  final nameById = {for (final e in exercises) e.id: e.name};

  final sorted = List<WorkoutSetEntity>.from(sets)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  final rows = [
    for (final s in sorted.take(maxRows))
      WorkoutReportRow(
        exercise: nameById[s.exerciseId] ?? 'Esercizio non più disponibile',
        date: _formatDate(s.timestamp),
        load: UnitConverter.formatWeight(s.weight, unit),
        reps: '${s.reps}',
      ),
  ];

  final volumeKg = sets.fold<double>(0, (sum, s) => sum + s.weight * s.reps);
  final volume = isImperial ? UnitConverter.kgToLb(volumeKg) : volumeKg;

  return WorkoutReportData(
    generatedAt:
        '${_formatDate(generatedAt)}, '
        '${generatedAt.hour.toString().padLeft(2, '0')}:'
        '${generatedAt.minute.toString().padLeft(2, '0')}',
    completedWorkouts: sessions.where((s) => s.isCompleted).length,
    loggedSets: sets.length,
    totalVolume: '${_groupThousands(volume)} ${isImperial ? 'lb' : 'kg'}',
    rows: rows,
  );
}

/// Separatore delle migliaia all'italiana (13.295, non 13,295).
/// Scritto a mano invece di usare NumberFormat con locale 'it_IT', che
/// richiederebbe di inizializzare i dati di localizzazione anche nei
/// test e in ogni punto che generi il report.
String _groupThousands(double value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formato compatto e senza dipendenza dai dati di localizzazione, che
/// altrimenti andrebbero inizializzati anche nei test.
String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} '
    '${UnitConverter.monthName(date.month)} ${date.year}';
