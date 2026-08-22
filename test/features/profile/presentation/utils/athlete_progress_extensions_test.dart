import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/profile/domain/services/athlete_progress_service.dart';
import 'package:gym_corpus/features/profile/presentation/utils/athlete_progress_extensions.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// ProfileScreen, RecordsScreen, TrophyBoardScreen e RootScreen leggevano
/// tutte AthleteProgress ripetendo la stessa estrazione di campi da
/// TrainingLoaded. Questi test coprono l'unico punto che ora la fa: il
/// fallback a AthleteProgress.empty() per stati non ancora caricati, e la
/// delega alla stessa AthleteProgressService.calculate usata prima.
///
/// AthleteProgress non estende Equatable, quindi due chiamate a
/// AthleteProgressService.calculate producono istanze diverse anche con
/// argomenti identici: i confronti sono sui campi rilevanti, non
/// sull'oggetto intero (che AthleteProgress.empty() invece puo' permettersi,
/// essendo un const canonicalizzato dal compilatore).
void main() {
  group('TrainingStateAthleteProgress', () {
    test('TrainingLoading restituisce AthleteProgress.empty()', () {
      const state = TrainingState.loading();

      expect(state.athleteProgress, AthleteProgress.empty());
    });

    test('TrainingError restituisce AthleteProgress.empty()', () {
      const state = TrainingState.error('errore');

      expect(state.athleteProgress, AthleteProgress.empty());
    });

    test('TrainingLoaded calcola i progressi dai dati caricati', () {
      const exercises = [
        ExerciseEntity(id: 1, name: 'Squat', targetMuscle: 'Legs'),
      ];
      // Tipizzato esplicitamente TrainingState, non TrainingLoaded: e' il
      // tipo statico reale in BlocBuilder<TrainingBloc, TrainingState>, e
      // sceglie l'estensione TrainingStateAthleteProgress invece della piu'
      // specifica TrainingLoadedAthleteProgress (Dart risolve le extension
      // sul tipo statico, non su quello a runtime).
      const TrainingState state = TrainingLoaded(exercises: exercises);
      const loaded = TrainingLoaded(exercises: exercises);

      final expected = AthleteProgressService.calculate(
        workoutSessions: loaded.workoutSessions,
        workoutSets: loaded.weightLogs,
        cardioSessions: loaded.cardioSessions,
        exercises: loaded.exercises,
      );
      final actual = state.athleteProgress;

      expect(actual.xp, expected.xp);
      expect(actual.level, expected.level);
      expect(actual.records.length, expected.records.length);
      expect(actual.achievements.length, expected.achievements.length);
    });
  });

  group('TrainingLoadedAthleteProgress', () {
    test('coincide con la chiamata diretta a AthleteProgressService', () {
      const state = TrainingLoaded(exercises: []);

      final viaExtension = state.athleteProgress;
      final viaService = AthleteProgressService.calculate(
        workoutSessions: state.workoutSessions,
        workoutSets: state.weightLogs,
        cardioSessions: state.cardioSessions,
        exercises: state.exercises,
      );

      expect(viaExtension.xp, viaService.xp);
      expect(viaExtension.level, viaService.level);
      expect(viaExtension.records.length, viaService.records.length);
      expect(viaExtension.achievements.length, viaService.achievements.length);
    });
  });
}
