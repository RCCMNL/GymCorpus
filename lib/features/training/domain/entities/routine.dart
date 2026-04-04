import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

class RoutineEntity extends Equatable {
  final int id;
  final String title;
  final int? estimatedDuration;
  final DateTime createdAt;
  final List<RoutineExerciseEntity> exercises;

  const RoutineEntity({
    required this.id,
    required this.title,
    this.estimatedDuration,
    required this.createdAt,
    this.exercises = const [],
  });

  @override
  List<Object?> get props => [id, title, estimatedDuration, createdAt, exercises];
}

class RoutineExerciseEntity extends Equatable {
  final int id;
  final int routineId;
  final ExerciseEntity exercise;
  final int sets;
  final int reps;
  final double weight;
  final int orderIndex;
  final String? setsData; // JSON string with detailed sets

  const RoutineExerciseEntity({
    required this.id,
    required this.routineId,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.orderIndex,
    this.setsData,
  });

  RoutineExerciseEntity copyWith({
    int? id,
    int? routineId,
    ExerciseEntity? exercise,
    int? sets,
    int? reps,
    double? weight,
    int? orderIndex,
    String? setsData,
  }) {
    return RoutineExerciseEntity(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      orderIndex: orderIndex ?? this.orderIndex,
      setsData: setsData ?? this.setsData,
    );
  }

  @override
  List<Object?> get props =>
      [id, routineId, exercise, sets, reps, weight, orderIndex, setsData];
}
