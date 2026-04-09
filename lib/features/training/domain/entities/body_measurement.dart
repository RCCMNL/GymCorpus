import 'package:equatable/equatable.dart';

class BodyMeasurementEntity extends Equatable {
  const BodyMeasurementEntity({
    required this.part,
    required this.value,
    required this.date,
    this.id,
  });

  final int? id;
  final String part; // e.g., 'Chest', 'Waist', 'Hips', 'Biceps', 'Thigh'
  final double value;
  final DateTime date;

  @override
  List<Object?> get props => [id, part, value, date];
}
