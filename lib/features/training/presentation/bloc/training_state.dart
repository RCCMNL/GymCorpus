import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

class TrainingLoading extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final List<ExerciseEntity> exercises;
  final List<RoutineEntity> routines;
  final List<WorkoutSetEntity> weightLogs;
  final List<BodyWeightLogEntity> bodyWeightLogs;
  final Map<String, String> settings;
  final double? lastEstimated1RM;

  const TrainingLoaded({
    required this.exercises,
    this.routines = const [],
    this.weightLogs = const [],
    this.bodyWeightLogs = const [],
    this.settings = const {},
    this.lastEstimated1RM,
  });

  @override
  List<Object?> get props => [exercises, routines, weightLogs, bodyWeightLogs, settings, lastEstimated1RM];
  
  TrainingLoaded copyWith({
    List<ExerciseEntity>? exercises,
    List<RoutineEntity>? routines,
    List<WorkoutSetEntity>? weightLogs,
    List<BodyWeightLogEntity>? bodyWeightLogs,
    Map<String, String>? settings,
    double? lastEstimated1RM,
  }) {
    return TrainingLoaded(
      exercises: exercises ?? this.exercises,
      routines: routines ?? this.routines,
      weightLogs: weightLogs ?? this.weightLogs,
      bodyWeightLogs: bodyWeightLogs ?? this.bodyWeightLogs,
      settings: settings ?? this.settings,
      lastEstimated1RM: lastEstimated1RM ?? this.lastEstimated1RM,
    );
  }
}

class TrainingError extends TrainingState {
  final String message;
  const TrainingError(this.message);

  @override
  List<Object?> get props => [message];
}
