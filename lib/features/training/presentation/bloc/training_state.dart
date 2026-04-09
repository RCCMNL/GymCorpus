import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

part 'training_state.freezed.dart';

@freezed
class TrainingState with _$TrainingState {
  const factory TrainingState.loading() = TrainingLoading;

  const factory TrainingState.loaded({
    required List<ExerciseEntity> exercises,
    @Default([]) List<RoutineEntity> routines,
    @Default([]) List<WorkoutSetEntity> weightLogs,
    @Default([]) List<BodyWeightLogEntity> bodyWeightLogs,
    @Default([]) List<BodyMeasurementEntity> bodyMeasurements,
    @Default([]) List<CardioSessionEntity> cardioSessions,
    @Default({}) Map<String, String> settings,
    double? lastEstimated1RM,
  }) = TrainingLoaded;

  const factory TrainingState.error(String message) = TrainingError;
}
