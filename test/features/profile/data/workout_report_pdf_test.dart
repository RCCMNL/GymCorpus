import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/data/workout_report_pdf.dart';
import 'package:gym_corpus/features/profile/domain/workout_report.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/workout_session.dart';

/// L'impaginazione PDF non ha un widget test che la copra: se una
/// composizione e' invalida (nidificazioni non ammesse da MultiPage,
/// tabelle senza larghezze) l'errore salta fuori solo al momento
/// dell'esportazione, cioe' in mano all'utente. Qui il documento viene
/// generato davvero, cosi' un errore del genere fa fallire la suite.
void main() {
  WorkoutReportData reportWith(int setCount) {
    return buildWorkoutReport(
      sessions: [
        WorkoutSessionEntity(
          id: 1,
          date: DateTime(2026, 8, 29),
          name: 'Full Body',
          completedAt: DateTime(2026, 8, 29, 19),
        ),
      ],
      sets: [
        for (var i = 0; i < setCount; i++)
          WorkoutSetEntity(
            id: i,
            workoutId: 1,
            exerciseId: 1,
            reps: 8,
            weight: 80,
            timestamp: DateTime(2026, 8, 20).add(Duration(hours: i)),
          ),
      ],
      exercises: const [
        ExerciseEntity(id: 1, name: 'Back Squat', targetMuscle: 'Gambe'),
      ],
      isImperial: false,
      generatedAt: DateTime(2026, 8, 30, 16, 5),
    );
  }

  test('genera un PDF valido con dati', () async {
    final bytes = await buildWorkoutReportPdf(data: reportWith(12));

    expect(bytes, isNotEmpty);
    expect(
      String.fromCharCodes(bytes.take(5)),
      '%PDF-',
      reason: 'intestazione PDF attesa',
    );
  });

  test('genera un PDF valido anche senza nessuna serie', () async {
    final bytes = await buildWorkoutReportPdf(data: reportWith(0));

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('impagina su piu pagine senza errori', () async {
    // Il footer usa pagesCount: con una sola pagina il caso limite non
    // verrebbe mai esercitato.
    final bytes = await buildWorkoutReportPdf(data: reportWith(40));

    expect(bytes, isNotEmpty);
  });
}
