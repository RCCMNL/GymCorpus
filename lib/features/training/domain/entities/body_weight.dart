import 'package:equatable/equatable.dart';

class BodyWeightLogEntity extends Equatable {
  const BodyWeightLogEntity({
    required this.weight,
    required this.date,
    this.id,
  });

  final int? id;
  final double weight;
  final DateTime date;

  @override
  List<Object?> get props => [id, weight, date];
}
