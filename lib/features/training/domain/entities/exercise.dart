import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  static const String bodyweightCategory = 'Corpo libero';

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
    this.userNotes,
    this.isBodyweight = false,
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
  final String? userNotes;
  final bool isBodyweight;
  final bool isVector;
  final bool isFavorite;

  List<String> get categories {
    final values = <String>[];
    final muscle = targetMuscle.trim();
    if (muscle.isNotEmpty) {
      values.add(muscle);
    }
    if (isBodyweight && !values.contains(bodyweightCategory)) {
      values.add(bodyweightCategory);
    }
    return List.unmodifiable(values);
  }

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
        userNotes,
        isBodyweight,
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
  List<Object?> get props =>
      [id, workoutId, exerciseId, reps, weight, rpe, timestamp];
}
