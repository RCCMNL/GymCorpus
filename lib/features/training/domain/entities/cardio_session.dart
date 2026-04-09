import 'package:equatable/equatable.dart';

class CardioSessionEntity extends Equatable {
  const CardioSessionEntity({
    required this.id,
    required this.type,
    required this.distance,
    required this.duration,
    required this.avgSpeed,
    required this.pace,
    required this.calories,
    required this.date,
    this.routeJson,
  });

  final int id;
  final String type; // 'run' or 'walk'
  final double distance; // km
  final int duration; // seconds
  final double avgSpeed; // km/h
  final String pace; // mm:ss per km
  final int calories;
  final String? routeJson;
  final DateTime date;

  @override
  List<Object?> get props => [id, type, distance, duration, avgSpeed, pace, calories, routeJson, date];
}
