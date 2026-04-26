import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class LoadExercisesEvent extends TrainingEvent {}

class LoadRoutinesEvent extends TrainingEvent {}

class LoadWeightLogsEvent extends TrainingEvent {}

class LoadBodyWeightLogsEvent extends TrainingEvent {}

class LoadSettingsEvent extends TrainingEvent {}

class LoadCardioSessionsEvent extends TrainingEvent {}

class AddRoutineEvent extends TrainingEvent {
  const AddRoutineEvent({
    required this.title,
    required this.exercises,
    this.estDuration,
  });

  final String title;
  final List<RoutineExerciseEntity> exercises;
  final int? estDuration;

  @override
  List<Object?> get props => [title, exercises, estDuration];
}

class UpdateRoutineEvent extends TrainingEvent {
  const UpdateRoutineEvent({
    required this.id,
    required this.title,
    required this.exercises,
    this.estDuration,
  });

  final int id;
  final String title;
  final List<RoutineExerciseEntity> exercises;
  final int? estDuration;

  @override
  List<Object?> get props => [id, title, exercises, estDuration];
}

class DeleteRoutineEvent extends TrainingEvent {
  const DeleteRoutineEvent(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class AddSetToExercise extends TrainingEvent {
  const AddSetToExercise({
    required this.workoutId,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    this.rpe,
  });

  final int workoutId;
  final int exerciseId;
  final int reps;
  final double weight;
  final int? rpe;

  @override
  List<Object?> get props => [workoutId, exerciseId, reps, weight, rpe];
}

class AddBodyWeightLogEvent extends TrainingEvent {
  const AddBodyWeightLogEvent(this.weight);

  final double weight;

  @override
  List<Object?> get props => [weight];
}

class DeleteBodyWeightLogEvent extends TrainingEvent {
  const DeleteBodyWeightLogEvent(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class UpdateBodyWeightLogEvent extends TrainingEvent {
  const UpdateBodyWeightLogEvent(this.id, this.weight);

  final int id;
  final double weight;

  @override
  List<Object?> get props => [id, weight];
}

class ReseedWeightHistoryEvent extends TrainingEvent {}

class LoadBodyMeasurementsEvent extends TrainingEvent {}

class AddBodyMeasurementEvent extends TrainingEvent {
  const AddBodyMeasurementEvent(this.part, this.value);

  final String part;
  final double value;

  @override
  List<Object?> get props => [part, value];
}

class DeleteBodyMeasurementEvent extends TrainingEvent {
  const DeleteBodyMeasurementEvent(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class UpdateBodyMeasurementEvent extends TrainingEvent {
  const UpdateBodyMeasurementEvent(this.id, this.value);

  final int id;
  final double value;

  @override
  List<Object?> get props => [id, value];
}

class SaveCardioSessionEvent extends TrainingEvent {
  const SaveCardioSessionEvent({
    required this.type,
    required this.distance,
    required this.duration,
    required this.avgSpeed,
    required this.pace,
    required this.calories,
    this.routeJson,
  });

  final String type;
  final double distance;
  final int duration;
  final double avgSpeed;
  final String pace;
  final int calories;
  final String? routeJson;

  @override
  List<Object?> get props =>
      [type, distance, duration, avgSpeed, pace, calories, routeJson];
}

class DeleteCardioSessionEvent extends TrainingEvent {
  const DeleteCardioSessionEvent(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class UpdatePreferenceEvent extends TrainingEvent {
  const UpdatePreferenceEvent(this.key, this.value);

  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

class ToggleExerciseFavoriteEvent extends TrainingEvent {
  const ToggleExerciseFavoriteEvent(this.exerciseId,
      {required this.isFavorite,});

  final int exerciseId;
  final bool isFavorite;

  @override
  List<Object?> get props => [exerciseId, isFavorite];
}

class UpdateExerciseNotesEvent extends TrainingEvent {
  const UpdateExerciseNotesEvent(this.exerciseId, {required this.notes});

  final int exerciseId;
  final String notes;

  @override
  List<Object?> get props => [exerciseId, notes];
}

// Update events (Internal, but public for visibility)
class UpdateExercisesList extends TrainingEvent {
  const UpdateExercisesList(this.exercises);

  final List<ExerciseEntity> exercises;

  @override
  List<Object?> get props => [exercises];
}

class UpdateRoutinesList extends TrainingEvent {
  const UpdateRoutinesList(this.routines);

  final List<RoutineEntity> routines;

  @override
  List<Object?> get props => [routines];
}

class UpdateWeightLogsList extends TrainingEvent {
  const UpdateWeightLogsList(this.weightLogs);

  final List<WorkoutSetEntity> weightLogs;

  @override
  List<Object?> get props => [weightLogs];
}

class UpdateBodyWeightLogsList extends TrainingEvent {
  const UpdateBodyWeightLogsList(this.bodyWeightLogs);

  final List<BodyWeightLogEntity> bodyWeightLogs;

  @override
  List<Object?> get props => [bodyWeightLogs];
}

class UpdateCardioSessionsList extends TrainingEvent {
  const UpdateCardioSessionsList(this.cardioSessions);

  final List<CardioSessionEntity> cardioSessions;

  @override
  List<Object?> get props => [cardioSessions];
}

class UpdateSettingsList extends TrainingEvent {
  const UpdateSettingsList(this.settings);

  final Map<String, String> settings;

  @override
  List<Object?> get props => [settings];
}

class UpdateBodyMeasurementsList extends TrainingEvent {
  const UpdateBodyMeasurementsList(this.bodyMeasurements);

  final List<BodyMeasurementEntity> bodyMeasurements;

  @override
  List<Object?> get props => [bodyMeasurements];
}

class StreamErrorEvent extends TrainingEvent {
  const StreamErrorEvent(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
