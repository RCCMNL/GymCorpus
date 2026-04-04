import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';

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

class AddRoutineEvent extends TrainingEvent {
  final String title;
  final List<RoutineExerciseEntity> exercises;
  final int? estDuration;

  const AddRoutineEvent({required this.title, required this.exercises, this.estDuration});

  @override
  List<Object?> get props => [title, exercises, estDuration];
}

class UpdateRoutineEvent extends TrainingEvent {
  final int id;
  final String title;
  final List<RoutineExerciseEntity> exercises;
  final int? estDuration;

  const UpdateRoutineEvent({
    required this.id,
    required this.title,
    required this.exercises,
    this.estDuration,
  });

  @override
  List<Object?> get props => [id, title, exercises, estDuration];
}

class DeleteRoutineEvent extends TrainingEvent {
  final int id;
  const DeleteRoutineEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddSetToExercise extends TrainingEvent {
  final int workoutId;
  final int exerciseId;
  final int reps;
  final double weight;
  final int? rpe;

  const AddSetToExercise({
    required this.workoutId,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    this.rpe,
  });

  @override
  List<Object?> get props => [workoutId, exerciseId, reps, weight, rpe];
}

class AddBodyWeightLogEvent extends TrainingEvent {
  final double weight;
  const AddBodyWeightLogEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

class UpdatePreferenceEvent extends TrainingEvent {
  final String key;
  final String value;
  const UpdatePreferenceEvent(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class ToggleExerciseFavoriteEvent extends TrainingEvent {
  final int exerciseId;
  final bool isFavorite;

  const ToggleExerciseFavoriteEvent(this.exerciseId, this.isFavorite);

  @override
  List<Object?> get props => [exerciseId, isFavorite];
}

// Update events (Internal, but public for visibility)
class UpdateExercisesList extends TrainingEvent {
  final List<ExerciseEntity> exercises;
  const UpdateExercisesList(this.exercises);
  @override
  List<Object?> get props => [exercises];
}

class UpdateRoutinesList extends TrainingEvent {
  final List<RoutineEntity> routines;
  const UpdateRoutinesList(this.routines);
  @override
  List<Object?> get props => [routines];
}

class UpdateWeightLogsList extends TrainingEvent {
  final List<WorkoutSetEntity> weightLogs;
  const UpdateWeightLogsList(this.weightLogs);
  @override
  List<Object?> get props => [weightLogs];
}

class UpdateBodyWeightLogsList extends TrainingEvent {
  final List<BodyWeightLogEntity> bodyWeightLogs;
  const UpdateBodyWeightLogsList(this.bodyWeightLogs);
  @override
  List<Object?> get props => [bodyWeightLogs];
}

class UpdateSettingsList extends TrainingEvent {
  final Map<String, String> settings;
  const UpdateSettingsList(this.settings);
  @override
  List<Object?> get props => [settings];
}

class StreamErrorEvent extends TrainingEvent {
  final String message;
  const StreamErrorEvent(this.message);
  @override
  List<Object?> get props => [message];
}
