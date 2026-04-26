import 'package:equatable/equatable.dart';

class WorkoutSessionEntity extends Equatable {
  const WorkoutSessionEntity({
    required this.id,
    required this.date,
    required this.name,
    this.routineId,
    this.completedAt,
    this.durationSeconds,
  });

  final int id;
  final DateTime date;
  final String name;
  final int? routineId;
  final DateTime? completedAt;
  final int? durationSeconds;

  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [
        id,
        date,
        name,
        routineId,
        completedAt,
        durationSeconds,
      ];
}
