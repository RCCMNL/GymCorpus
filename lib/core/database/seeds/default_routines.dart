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
    this.weight = 0,
  });

  final String exerciseName;
  final int sets;
  final int reps;

  /// Carico di partenza in kg, prudente e pensato per essere aggiustato
  /// subito dall'utente. Resta a 0 per gli esercizi a corpo libero.
  final double weight;
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
          weight: 10,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Distensioni su panca piana (Manubri)',
          sets: 3,
          reps: 10,
          weight: 8,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Lat Machine (presa larga)',
          sets: 3,
          reps: 12,
          weight: 25,
        ),
        DefaultRoutineExerciseSeed(exerciseName: 'Crunch', sets: 3, reps: 15),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Alzate laterali(Manubri)',
          sets: 3,
          reps: 12,
          weight: 4,
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
          weight: 40,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Rematore con bilanciere',
          sets: 4,
          reps: 8,
          weight: 40,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Overhead Press con manubri',
          sets: 3,
          reps: 10,
          weight: 12,
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
          weight: 20,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Pushdown ai cavi (Con corda)',
          sets: 3,
          reps: 12,
          weight: 15,
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
          weight: 40,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Affondi con manubri',
          sets: 3,
          reps: 10,
          weight: 10,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Leg Extension',
          sets: 3,
          reps: 12,
          weight: 30,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Leg Curl (sdraiato)',
          sets: 3,
          reps: 12,
          weight: 25,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Hip Thrust (Bilanciere)',
          sets: 3,
          reps: 10,
          weight: 40,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Calf Raises in piedi (Alla macchina)',
          sets: 4,
          reps: 15,
          weight: 40,
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
          weight: 80,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Front Squat',
          sets: 3,
          reps: 6,
          weight: 50,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Overhead Press con bilanciere',
          sets: 3,
          reps: 6,
          weight: 35,
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
          weight: 60,
        ),
        DefaultRoutineExerciseSeed(
          exerciseName: 'Rematore Pendlay',
          sets: 3,
          reps: 8,
          weight: 50,
        ),
      ],
    ),
  ];
}
