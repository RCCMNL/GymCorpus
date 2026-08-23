import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

/// Reps e peso previsti per una specifica serie di [re]. Se la routine ha
/// una configurazione per-serie in `setsData` la usa, altrimenti ricade sui
/// valori di default dell'esercizio nella routine.
({double weight, int reps}) getSetSpecs(RoutineExerciseEntity re, int setIdx) {
  if (re.setsData != null) {
    try {
      final list = jsonDecode(re.setsData!) as List<dynamic>;
      if (setIdx < list.length) {
        final s = list[setIdx] as Map<String, dynamic>;
        return (
          weight: (s['weight'] as num).toDouble(),
          reps: s['reps'] as int,
        );
      }
    } catch (e) {
      // setsData corrotto o con struttura inattesa: si ricade sui valori
      // di default dell'esercizio nella routine.
      debugPrint(
        'TrainingScreen: setsData non valido per esercizio '
        '${re.exercise.id}, set $setIdx: $e',
      );
    }
  }
  return (weight: re.weight, reps: re.reps);
}

/// Riassunto testuale di una serie, es. "12 x 40.0 kg" o "12 reps" per gli
/// esercizi a corpo libero.
String formatSetSummary(
  RoutineExerciseEntity exercise,
  ({double weight, int reps}) specs,
  WeightUnit unit,
) {
  if (exercise.exercise.isBodyweight) {
    return '${specs.reps} reps';
  }
  return '${specs.reps} x ${UnitConverter.formatWeight(specs.weight, unit)}';
}
