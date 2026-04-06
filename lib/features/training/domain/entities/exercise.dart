import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.targetMuscle,
    this.referenceVideoUrl,
    this.imageUrl,
    this.equipment,
    this.focusArea,
    this.preparation,
    this.execution,
    this.tips,
    this.isVector = false,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String targetMuscle;
  final String? referenceVideoUrl;
  final String? imageUrl;
  final String? equipment;
  final String? focusArea;
  final String? preparation;
  final String? execution;
  final String? tips;
  final bool isVector;
  final bool isFavorite;

  @override
  List<Object?> get props => [
        id,
        name,
        targetMuscle,
        referenceVideoUrl,
        imageUrl,
        equipment,
        focusArea,
        preparation,
        execution,
        tips,
        isVector,
        isFavorite,
      ];
}

class WorkoutSetEntity extends Equatable {
  const WorkoutSetEntity({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    required this.timestamp,
    this.rpe,
  });

  final int id;
  final int workoutId;
  final int exerciseId;
  final int reps;
  final double weight;
  final int? rpe;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, workoutId, exerciseId, reps, weight, rpe, timestamp];
}
