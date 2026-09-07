import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

/// Cosa manca a una bozza di routine per poter essere salvata.
enum RoutineDraftProblem { missingName, noExercises }

/// La routine cosi' come l'utente l'ha compilata, prima di finire nel
/// database.
///
/// Prima queste regole vivevano dentro `WorkoutPage._saveRoutine`, in mezzo
/// a due SnackBar costruite a mano: nessuna di esse era verificabile senza
/// montare la schermata, e le conversioni di unita' erano il punto in cui un
/// errore sarebbe passato inosservato piu' a lungo.
@immutable
class RoutineDraft {
  const RoutineDraft({
    required this.name,
    required this.exercises,
    required this.useImperialUnits,
  });

  /// Il nome scritto dall'utente, non ancora ripulito.
  final String name;
  final List<RoutineExerciseEntity> exercises;

  /// Se l'utente lavora in libbre, i pesi vanno riportati in chili.
  final bool useImperialUnits;

  /// Il primo motivo per cui non si puo' salvare, o `null` se si puo'.
  RoutineDraftProblem? get problem {
    if (name.trim().isEmpty) return RoutineDraftProblem.missingName;
    if (exercises.isEmpty) return RoutineDraftProblem.noExercises;
    return null;
  }

  /// Il nome ripulito, con l'iniziale maiuscola.
  String get normalizedName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  /// Gli esercizi pronti per il database: pesi sempre in chili, corpo libero
  /// sempre a zero.
  List<RoutineExerciseEntity> exercisesToSave() {
    return [
      for (final exercise in exercises)
        if (exercise.exercise.isBodyweight)
          _withoutWeight(exercise)
        else if (useImperialUnits)
          _convertedToKg(exercise)
        else
          exercise,
    ];
  }

  /// A corpo libero il peso non ha senso: restano solo le ripetizioni.
  static RoutineExerciseEntity _withoutWeight(RoutineExerciseEntity exercise) {
    final sets = _decodeSets(exercise);
    final sanitized = sets.isEmpty
        ? const [
            {'weight': 0, 'reps': 0},
          ]
        : [
            for (final set in sets) {'weight': 0, 'reps': set['reps'] ?? 0},
          ];

    return exercise.copyWith(weight: 0, setsData: jsonEncode(sanitized));
  }

  /// Un `setsData` illeggibile lascia l'esercizio com'e': meglio un peso in
  /// libbre salvato per sbaglio che un salvataggio che fallisce.
  static RoutineExerciseEntity _convertedToKg(RoutineExerciseEntity exercise) {
    final sets = _decodeSets(exercise);
    if (sets.isEmpty) return exercise;

    try {
      final converted = [
        for (final set in sets)
          {
            'weight': UnitConverter.lbToKg((set['weight']! as num).toDouble()),
            'reps': set['reps'],
          },
      ];

      return exercise.copyWith(
        weight: UnitConverter.lbToKg(exercise.weight),
        setsData: jsonEncode(converted),
      );
    } catch (error) {
      debugPrint(
        'RoutineDraft: serie non convertibili per '
        '${exercise.exercise.name} (id ${exercise.exercise.id}): $error',
      );
      return exercise;
    }
  }

  /// Le serie salvate, o una lista vuota se il JSON manca o e' rotto.
  static List<Map<String, dynamic>> _decodeSets(
    RoutineExerciseEntity exercise,
  ) {
    final raw = exercise.setsData;
    if (raw == null || raw.isEmpty) return const [];

    try {
      return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (error) {
      // Non blocchiamo il salvataggio per un JSON corrotto, ma l'anomalia
      // va tracciata: significa che qualcosa ha scritto male quel campo.
      debugPrint(
        'RoutineDraft: setsData non valido per '
        '${exercise.exercise.name} (id ${exercise.exercise.id}): $error',
      );
      return const [];
    }
  }
}
