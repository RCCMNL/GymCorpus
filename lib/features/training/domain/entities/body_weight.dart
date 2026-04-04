import 'package:equatable/equatable.dart';

class BodyWeightLogEntity extends Equatable {
  final int? id;
  final double weight;
  final DateTime date;

  const BodyWeightLogEntity({
    this.id,
    required this.weight,
    required this.date,
  });

  @override
  List<Object?> get props => [id, weight, date];
}
