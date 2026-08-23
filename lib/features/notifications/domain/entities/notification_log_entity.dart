import 'package:equatable/equatable.dart';

class NotificationLogEntity extends Equatable {
  const NotificationLogEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  @override
  List<Object?> get props => [id, title, body, timestamp, isRead, type];
}
