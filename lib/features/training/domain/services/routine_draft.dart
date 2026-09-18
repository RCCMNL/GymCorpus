import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  const RoutineDraft({required this.name, required this.exercises});

  /// Il nome scritto dall'utente, non ancora ripulito.
  final String name;

  /// Gli esercizi compilati. I pesi sono in chili: chi raccoglie l'input
  /// converte dalle libbre prima di consegnarli, perche' un'unita' che
  /// dipende da chi guarda non e' un dato del modello.
  final List<RoutineExerciseEntity> exercises;

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

  /// Gli esercizi pronti per il database: corpo libero sempre senza peso e
  /// ordine preso dalla lista.
  ///
  /// L'ordine viene rinumerato qui perche' dopo un riordino ogni esercizio
  /// porta ancora l'indice della posizione da cui viene: salvarlo com'e'
  /// significava scrivere nel database un ordine che nessuno aveva scelto.
  List<RoutineExerciseEntity> exercisesToSave() {
    return [
      for (final (index, exercise) in exercises.indexed)
        (exercise.exercise.isBodyweight ? _withoutWeight(exercise) : exercise)
            .copyWith(orderIndex: index),
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
