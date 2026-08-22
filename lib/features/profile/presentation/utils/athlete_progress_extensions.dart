import 'package:gym_corpus/features/profile/domain/services/athlete_progress_service.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Deriva [AthleteProgress] dallo stato gia' caricato di `TrainingBloc`.
///
/// ProfileScreen, RecordsScreen, TrophyBoardScreen e RootScreen ripetevano
/// tutte la stessa chiamata a `AthleteProgressService.calculate`,
/// estraendo a mano gli stessi quattro campi da `TrainingLoaded`.
/// Centralizzato qui: un futuro campo aggiuntivo si aggiorna in un punto
/// solo invece che in quattro.
extension TrainingLoadedAthleteProgress on TrainingLoaded {
  AthleteProgress get athleteProgress => AthleteProgressService.calculate(
    workoutSessions: workoutSessions,
    workoutSets: weightLogs,
    cardioSessions: cardioSessions,
    exercises: exercises,
  );
}

extension TrainingStateAthleteProgress on TrainingState {
  /// [AthleteProgress.empty] se lo stato non e' ancora `TrainingLoaded`.
  AthleteProgress get athleteProgress {
    final state = this;
    return state is TrainingLoaded
        ? state.athleteProgress
        : AthleteProgress.empty();
  }
}
