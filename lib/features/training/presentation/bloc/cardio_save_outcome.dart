import 'dart:async';

import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Com'e' finito il salvataggio di una sessione cardio.
enum CardioSaveOutcome {
  saved,
  failed,

  /// Nessuna risposta in tempo utile: la scrittura puo' ancora andare a
  /// buon fine, ma la schermata non resta appesa ad aspettarla.
  timedOut,
}

/// Aspetta l'esito della scrittura guardando gli stati del TrainingBloc.
///
/// La schermata cardio chiudeva dopo mezzo secondo fisso: un ritardo che
/// non verificava niente e diceva "salvato" anche quando non lo era. La
/// sessione appena scritta arriva dallo stream del database come una
/// sessione in piu' rispetto a [sessionsBefore]; un fallimento arriva come
/// `actionError`.
Future<CardioSaveOutcome> awaitCardioSessionSaved(
  Stream<TrainingState> states, {
  required int sessionsBefore,
  Duration timeout = const Duration(seconds: 5),
}) {
  return states
      .map((state) {
        if (state is! TrainingLoaded) return null;
        if (state.actionError != null) return CardioSaveOutcome.failed;
        if (state.cardioSessions.length > sessionsBefore) {
          return CardioSaveOutcome.saved;
        }
        return null;
      })
      .where((outcome) => outcome != null)
      .cast<CardioSaveOutcome>()
      .first
      .timeout(timeout, onTimeout: () => CardioSaveOutcome.timedOut);
}
