import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.actionError,
  });

  final List<NotificationLogEntity> notifications;
  final bool isLoading;

  /// Errore transitorio di una singola azione (es. segnare come letta una
  /// notifica). La UI lo mostra e poi lo azzera con
  /// `ClearNotificationActionErrorEvent`, senza che le notifiche gia'
  /// caricate vengano perse nel frattempo.
  final String? actionError;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationLogEntity>? notifications,
    bool? isLoading,
    String? actionError,
    bool clearActionError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, actionError];
}
