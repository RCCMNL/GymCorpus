/// Routine di sistema incluse con l'app: uguali per tutti gli utenti,
/// avviabili subito, copiabili ma non modificabili nella loro forma
/// originale (vedi isSystem su Routines in database.dart).
///
/// Gli esercizi sono referenziati per nome esatto dal catalogo seed
/// (getSeedExercises() in seed_data.dart): il seeding li risolve in
/// exerciseId al momento dell'inserimento, così non serve duplicare id.
class DefaultRoutineExerciseSeed {
  const DefaultRoutineExerciseSeed({
    required this.exerciseName,
    required this.sets,
    required this.reps,
  });

  final String exerciseName;
  final int sets;
  final int reps;
}

class DefaultRoutineSeed {
  const DefaultRoutineSeed({required this.title, required this.exercises});

  final String title;
  final List<DefaultRoutineExerciseSeed> exercises;
}

List<DefaultRoutineSeed> getDefaultRoutines() {
  return const [
    DefaultRoutineSeed(
      title: 'Full Body – Principianti',
      exercises: [
        DefaultRoutineExerciseSeed(
          exerciseName: 'Goblet Squat',
          sets: 3,
          reps: 12,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Distensioni su panca piana (Manubri)',
          sets: 3,
          reps: 10,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Lat Machine (presa larga)',
          sets: 3,
          reps: 12,
        ),
        DefaultRoutineExerciseSeed(exerciseName: 'Crunch', sets: 3, reps: 15),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Alzate laterali(Manubri)',
          sets: 3,
          reps: 12,
        ),
      ],
    ),
    DefaultRoutineSeed(
      title: 'Upper Body – Intermedio',
      exercises: [
        DefaultRoutineExerciseSeed(
          exerciseName: 'Distensioni su panca inclinata (Bilanciere)',
          sets: 4,
          reps: 8,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Rematore con bilanciere',
          sets: 4,
          reps: 8,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Overhead Press con manubri',
          sets: 3,
          reps: 10,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Trazioni alla sbarra (presa neutra)',
          sets: 3,
          reps: 8,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Curl con bilanciere',
          sets: 3,
          reps: 12,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Pushdown ai cavi (Con corda)',
          sets: 3,
          reps: 12,
        ),
      ],
    ),
    DefaultRoutineSeed(
      title: 'Lower Body – Intermedio',
      exercises: [
        DefaultRoutineExerciseSeed(
          exerciseName: 'Back Squat',
          sets: 4,
          reps: 8,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Affondi con manubri',
          sets: 3,
          reps: 10,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Leg Extension',
          sets: 3,
          reps: 12,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Leg Curl (sdraiato)',
          sets: 3,
          reps: 12,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Hip Thrust (Bilanciere)',
          sets: 3,
          reps: 10,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Calf Raises in piedi (Alla macchina)',
          sets: 4,
          reps: 15,
        ),
      ],
    ),
    DefaultRoutineSeed(
      title: 'Total Body – Avanzato',
      exercises: [
        DefaultRoutineExerciseSeed(
          exerciseName: 'Stacco da terra (Deadlift)',
          sets: 4,
          reps: 5,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Front Squat',
          sets: 3,
          reps: 6,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Overhead Press con bilanciere',
          sets: 3,
          reps: 6,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Pull-ups (presa prona larga)',
          sets: 4,
          reps: 8,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Distensioni su panca piana (Bilanciere)',
          sets: 4,
          reps: 6,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Rematore Pendlay',
          sets: 3,
          reps: 8,
        ),
      ],
    ),
  ];
}
