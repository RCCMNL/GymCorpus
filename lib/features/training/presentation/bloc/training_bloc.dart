import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/training_calculations.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  TrainingBloc({required this.repository, required this.authRepository})
      : super(const TrainingState.loading()) {
    on<LoadExercisesEvent>((event, emit) async {
      await _exercisesSubscription?.cancel();
      _exercisesSubscription = repository.watchExercises().listen(
        (exercises) {
          add(UpdateExercisesList(exercises));
        },
        onError: (Object e) => add(StreamErrorEvent(e.toString())),
      );
    });

    on<LoadRoutinesEvent>((event, emit) async {
      await _routinesSubscription?.cancel();
      _routinesSubscription = repository.watchRoutines().listen(
        (routines) {
          add(UpdateRoutinesList(routines));
        },
        onError: (Object e) => add(StreamErrorEvent(e.toString())),
      );
    });

    on<LoadWeightLogsEvent>((event, emit) async {
      await _weightLogsSubscription?.cancel();
      _weightLogsSubscription = repository.watchWeightLogs().listen(
        (logs) {
          add(UpdateWeightLogsList(logs));
        },
        onError: (Object e) => add(StreamErrorEvent(e.toString())),
      );
    });

    on<LoadBodyWeightLogsEvent>((event, emit) async {
      await _bodyWeightLogsSubscription?.cancel();
      _bodyWeightLogsSubscription = repository.watchBodyWeightLogs().listen(
        (logs) {
          add(UpdateBodyWeightLogsList(logs));
        },
        onError: (Object e) => add(StreamErrorEvent(e.toString())),
      );
    });

    on<LoadSettingsEvent>((event, emit) async {
      await _settingsSubscription?.cancel();
      _settingsSubscription = repository.watchAllSettings().listen(
        (settings) {
          add(UpdateSettingsList(settings));
        },
        onError: (Object e) => add(StreamErrorEvent(e.toString())),
      );
    });

    on<LoadCardioSessionsEvent>((event, emit) async {
      await _cardioSessionsSubscription?.cancel();
      _cardioSessionsSubscription = repository.watchCardioSessions().listen(
        (sessions) {
          add(UpdateCardioSessionsList(sessions));
        },
        onError: (Object e) => add(StreamErrorEvent(e.toString())),
      );
    });

    on<UpdateExercisesList>((event, emit) {
      if (state is TrainingLoaded) {
        emit((state as TrainingLoaded).copyWith(exercises: event.exercises));
      } else {
        emit(TrainingLoaded(exercises: event.exercises));
      }
    });

    on<UpdateRoutinesList>((event, emit) {
      if (state is TrainingLoaded) {
        emit((state as TrainingLoaded).copyWith(routines: event.routines));
      } else {
        emit(TrainingLoaded(exercises: const [], routines: event.routines));
      }
    });

    on<UpdateWeightLogsList>((event, emit) {
      if (state is TrainingLoaded) {
        emit((state as TrainingLoaded).copyWith(weightLogs: event.weightLogs));
      } else {
        emit(TrainingLoaded(exercises: const [], weightLogs: event.weightLogs));
      }
    });

    on<UpdateBodyWeightLogsList>((event, emit) {
      if (state is TrainingLoaded) {
        emit(
          (state as TrainingLoaded).copyWith(
            bodyWeightLogs: event.bodyWeightLogs,
          ),
        );
      } else {
        emit(
          TrainingLoaded(
            exercises: const [],
            bodyWeightLogs: event.bodyWeightLogs,
          ),
        );
      }
    });

    on<UpdateCardioSessionsList>((event, emit) {
      if (state is TrainingLoaded) {
        emit(
          (state as TrainingLoaded)
              .copyWith(cardioSessions: event.cardioSessions),
        );
      } else {
        emit(
          TrainingLoaded(
            exercises: const [],
            cardioSessions: event.cardioSessions,
          ),
        );
      }
    });

    on<UpdateSettingsList>((event, emit) {
      if (state is TrainingLoaded) {
        emit((state as TrainingLoaded).copyWith(settings: event.settings));
      } else {
        emit(TrainingLoaded(exercises: const [], settings: event.settings));
      }
    });

    on<UpdateBodyMeasurementsList>((event, emit) {
      if (state is TrainingLoaded) {
        emit(
          (state as TrainingLoaded)
              .copyWith(bodyMeasurements: event.bodyMeasurements),
        );
      } else {
        emit(
          TrainingLoaded(
            exercises: const [],
            bodyMeasurements: event.bodyMeasurements,
          ),
        );
      }
    });

    on<AddRoutineEvent>((event, emit) async {
      final result = await repository.addRoutine(
        event.title,
        event.exercises,
        event.estDuration,
      );
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (id) => null, // Stream will update UI
      );
    });

    on<UpdateRoutineEvent>((event, emit) async {
      final result = await repository.updateRoutine(
        event.id,
        event.title,
        event.exercises,
        event.estDuration,
      );
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null, // Stream will update UI
      );
    });

    on<DeleteRoutineEvent>((event, emit) async {
      final result = await repository.deleteRoutine(event.id);
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null,
      );
    });

    on<AddSetToExercise>((event, emit) async {
      if (state is TrainingLoaded) {
        final current = state as TrainingLoaded;
        var new1RM = current.lastEstimated1RM;

        if (event.rpe != null && event.rpe! > 8) {
          new1RM = TrainingCalculations.calculateBrzycki1RM(
            weight: event.weight,
            reps: event.reps,
          );
        }

        final result = await repository.addSetToExercise(
          workoutId: event.workoutId,
          exerciseId: event.exerciseId,
          reps: event.reps,
          weight: event.weight,
          rpe: event.rpe,
        );

        result.fold(
          (failure) => emit(TrainingError(failure.message)),
          (_) {
            emit(current.copyWith(lastEstimated1RM: new1RM));
          },
        );
      }
    });

    on<AddBodyWeightLogEvent>((event, emit) async {
      final result = await repository.addBodyWeightLogEntry(event.weight);
      await result.fold<Future<void>>(
        (f) async => emit(TrainingError(f.message)),
        (_) => _syncProfileWeight(weight: event.weight),
      );
    });

    on<DeleteBodyWeightLogEvent>((event, emit) async {
      final currentLogs = state is TrainingLoaded
          ? (state as TrainingLoaded).bodyWeightLogs
          : const <BodyWeightLogEntity>[];
      final deletedLatest =
          currentLogs.isNotEmpty && currentLogs.first.id == event.id;
      final remainingLogs =
          currentLogs.where((log) => log.id != event.id).toList();

      final result = await repository.deleteBodyWeightLogEntry(event.id);
      await result.fold<Future<void>>(
        (f) async => emit(TrainingError(f.message)),
        (_) async {
          if (!deletedLatest) return;
          if (remainingLogs.isEmpty) {
            await _syncProfileWeight(clearWeight: true);
            return;
          }
          await _syncProfileWeight(weight: remainingLogs.first.weight);
        },
      );
    });

    on<UpdateBodyWeightLogEvent>((event, emit) async {
      final currentLogs = state is TrainingLoaded
          ? (state as TrainingLoaded).bodyWeightLogs
          : const <BodyWeightLogEntity>[];
      final updatedLatest =
          currentLogs.isNotEmpty && currentLogs.first.id == event.id;

      final result =
          await repository.updateBodyWeightLogEntry(event.id, event.weight);
      await result.fold<Future<void>>(
        (f) async => emit(TrainingError(f.message)),
        (_) async {
          if (updatedLatest) {
            await _syncProfileWeight(weight: event.weight);
          }
        },
      );
    });

    on<LoadBodyMeasurementsEvent>((event, emit) async {
      await _bodyMeasurementsSubscription?.cancel();
      _bodyMeasurementsSubscription = repository.watchBodyMeasurements().listen(
        (logs) {
          add(UpdateBodyMeasurementsList(logs));
        },
        onError: (Object _) {
          add(const UpdateBodyMeasurementsList([]));
        },
      );
    });

    on<AddBodyMeasurementEvent>((event, emit) async {
      final result =
          await repository.addBodyMeasurement(event.part, event.value);
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (id) => null,
      );
    });

    on<DeleteBodyMeasurementEvent>((event, emit) async {
      final result = await repository.deleteBodyMeasurement(event.id);
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null,
      );
    });

    on<UpdateBodyMeasurementEvent>((event, emit) async {
      final result =
          await repository.updateBodyMeasurement(event.id, event.value);
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null,
      );
    });

    on<SaveCardioSessionEvent>((event, emit) async {
      final result = await repository.addCardioSession(
        type: event.type,
        distance: event.distance,
        duration: event.duration,
        avgSpeed: event.avgSpeed,
        pace: event.pace,
        calories: event.calories,
        routeJson: event.routeJson,
      );
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (id) => null, // Stream will update UI
      );
    });

    on<DeleteCardioSessionEvent>((event, emit) async {
      final result = await repository.deleteCardioSession(event.id);
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null,
      );
    });

    on<UpdatePreferenceEvent>((event, emit) async {
      final result = await repository.updatePreference(event.key, event.value);
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null,
      );
    });

    on<ToggleExerciseFavoriteEvent>((event, emit) async {
      final result = await repository.toggleExerciseFavorite(
        event.exerciseId,
        isFavorite: event.isFavorite,
      );
      result.fold(
        (f) => emit(TrainingError(f.message)),
        (_) => null, // The stream will update the UI
      );
    });

    on<StreamErrorEvent>((event, emit) {
      emit(TrainingError(event.message));
    });

    on<ReseedWeightHistoryEvent>((event, emit) async {
      final result = await repository.reseedWeightHistory();
      await result.fold<Future<void>>(
        (f) async => emit(TrainingError(f.message)),
        (latestWeight) async {
          if (latestWeight == null) {
            await _syncProfileWeight(clearWeight: true);
            return;
          }
          await _syncProfileWeight(weight: latestWeight);
        },
      );
    });
  }

  final TrainingRepository repository;
  final AuthRepository authRepository;
  StreamSubscription<List<ExerciseEntity>>? _exercisesSubscription;
  StreamSubscription<List<RoutineEntity>>? _routinesSubscription;
  StreamSubscription<List<WorkoutSetEntity>>? _weightLogsSubscription;
  StreamSubscription<List<BodyWeightLogEntity>>? _bodyWeightLogsSubscription;
  StreamSubscription<List<BodyMeasurementEntity>>?
      _bodyMeasurementsSubscription;
  StreamSubscription<List<CardioSessionEntity>>? _cardioSessionsSubscription;
  StreamSubscription<Map<String, String>>? _settingsSubscription;

  Future<void> _syncProfileWeight({
    double? weight,
    bool clearWeight = false,
  }) async {
    await authRepository.updateProfileDetails(
      weight: weight,
      clearWeight: clearWeight,
    );
  }

  @override
  Future<void> close() {
    _exercisesSubscription?.cancel();
    _routinesSubscription?.cancel();
    _weightLogsSubscription?.cancel();
    _bodyWeightLogsSubscription?.cancel();
    _bodyMeasurementsSubscription?.cancel();
    _cardioSessionsSubscription?.cancel();
    _settingsSubscription?.cancel();
    return super.close();
  }
}
