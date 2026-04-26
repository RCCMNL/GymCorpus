import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {}

class MarkNotificationReadEvent extends NotificationsEvent {
  const MarkNotificationReadEvent(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {}

class DeleteNotificationEvent extends NotificationsEvent {
  const DeleteNotificationEvent(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

class DeleteAllNotificationsEvent extends NotificationsEvent {}

class AddNotificationLogEvent extends NotificationsEvent {
  const AddNotificationLogEvent({
    required this.title,
    required this.body,
    required this.type,
  });

  final String title;
  final String body;
  final String type;

  @override
  List<Object?> get props => [title, body, type];
}

class ScheduleStretchingReminderEvent extends NotificationsEvent {
  const ScheduleStretchingReminderEvent({
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;

  @override
  List<Object?> get props => [hour, minute];
}

class CancelStretchingReminderEvent extends NotificationsEvent {}

class ScheduleTrainingReminderEvent extends NotificationsEvent {
  const ScheduleTrainingReminderEvent({
    required this.hour,
    required this.minute,
    required this.days,
  });

  final int hour;
  final int minute;
  final List<int> days; // 1=Mon, 7=Sun

  @override
  List<Object?> get props => [hour, minute, days];
}

class CancelTrainingReminderEvent extends NotificationsEvent {}

// Internal stream update event
class UpdateNotificationsList extends NotificationsEvent {
  const UpdateNotificationsList(this.notifications);
  final List<NotificationLogEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}
