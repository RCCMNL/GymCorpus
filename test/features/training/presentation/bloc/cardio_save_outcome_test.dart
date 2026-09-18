import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/cardio_save_outcome.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Chiudere la schermata dopo mezzo secondo fisso significa dire "salvato"
/// senza saperlo: qui si aspetta che la sessione sia davvero comparsa,
/// che la scrittura sia fallita, o che sia passato troppo tempo.
void main() {
  CardioSessionEntity session(int id) {
    return CardioSessionEntity(
      id: id,
      type: 'run',
      distance: 5,
      duration: 1800,
      avgSpeed: 10,
      pace: "6'00\"",
      calories: 300,
      date: DateTime(2026, 9, 18),
    );
  }

  late StreamController<TrainingState> states;

  setUp(() => states = StreamController<TrainingState>.broadcast());
  tearDown(() => states.close());

  test('si conclude quando la sessione compare nello storico', () async {
    final done = awaitCardioSessionSaved(
      states.stream,
      sessionsBefore: 1,
      timeout: const Duration(seconds: 5),
    );

    states.add(TrainingState.loaded(
      exercises: const [],
      cardioSessions: [session(1), session(2)],
    ));

    expect(await done, CardioSaveOutcome.saved);
  });

  test('si conclude quando la scrittura fallisce', () async {
    final done = awaitCardioSessionSaved(
      states.stream,
      sessionsBefore: 0,
      timeout: const Duration(seconds: 5),
    );

    states.add(
      const TrainingState.loaded(exercises: [], actionError: 'disco pieno'),
    );

    expect(await done, CardioSaveOutcome.failed);
  });

  test('uno stato che non dice niente non basta a chiudere', () async {
    final done = awaitCardioSessionSaved(
      states.stream,
      sessionsBefore: 1,
      timeout: const Duration(milliseconds: 200),
    );

    states.add(TrainingState.loaded(
      exercises: const [],
      cardioSessions: [session(1)],
    ));

    expect(await done, CardioSaveOutcome.timedOut);
  });

  test('senza risposta si smette di aspettare', () async {
    final outcome = await awaitCardioSessionSaved(
      states.stream,
      sessionsBefore: 0,
      timeout: const Duration(milliseconds: 100),
    );

    expect(outcome, CardioSaveOutcome.timedOut);
  });
}
