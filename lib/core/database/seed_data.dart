import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/database/seeds/abs_exercises.dart';
import 'package:gym_corpus/core/database/seeds/back_exercises.dart';
import 'package:gym_corpus/core/database/seeds/biceps_exercises.dart';
import 'package:gym_corpus/core/database/seeds/calf_exercises.dart';
import 'package:gym_corpus/core/database/seeds/chest_exercises.dart';
import 'package:gym_corpus/core/database/seeds/forearm_exercises.dart';
import 'package:gym_corpus/core/database/seeds/leg_exercises.dart';
import 'package:gym_corpus/core/database/seeds/shoulder_exercises.dart';
import 'package:gym_corpus/core/database/seeds/triceps_exercises.dart';

/// Seed data for the drift database.
/// Combined from modularized muscle-group files in lib/core/database/seeds/
List<ExercisesCompanion> getSeedExercises() {
  return [
    ...chestExercises,
    ...backExercises,
    ...shoulderExercises,
    ...bicepsExercises,
    ...tricepsExercises,
    ...forearmExercises,
    ...legExercises,
    ...calfExercises,
    ...absExercises,
  ];
}
