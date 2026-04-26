import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';
import 'package:gym_corpus/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:injectable/injectable.dart';

/// Notification IDs riservati per i promemoria schedulati.
/// Usiamo range fissi per evitare conflitti.
const int _stretchingNotificationId = 9001;
const int _trainingBaseNotificationId = 9010; // 9010-9016 per lun-dom

@injectable
class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required this.repository})
      : super(const NotificationsState(isLoading: true)) {
    on<LoadNotificationsEvent>(_onLoad);
    on<UpdateNotificationsList>(_onUpdate);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
    on<DeleteNotificationEvent>(_onDelete);
    on<DeleteAllNotificationsEvent>(_onDeleteAll);
    on<AddNotificationLogEvent>(_onAddLog);
    on<ScheduleStretchingReminderEvent>(_onScheduleStretching);
    on<CancelStretchingReminderEvent>(_onCancelStretching);
    on<ScheduleTrainingReminderEvent>(_onScheduleTraining);
    on<CancelTrainingReminderEvent>(_onCancelTraining);
  }

  final NotificationsRepository repository;
  StreamSubscription<List<NotificationLogEntity>>? _subscription;

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = repository.watchNotificationLogs().listen(
      (logs) => add(UpdateNotificationsList(logs)),
    );
  }

  void _onUpdate(
    UpdateNotificationsList event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      notifications: event.notifications,
      isLoading: false,
    ));
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.markAsRead(event.id);
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.markAllAsRead();
  }

  Future<void> _onDelete(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.deleteNotification(event.id);
  }

  Future<void> _onDeleteAll(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.deleteAllNotifications();
  }

  Future<void> _onAddLog(
    AddNotificationLogEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.addNotificationLog(
      title: event.title,
      body: event.body,
      type: event.type,
    );
  }

  Future<void> _onScheduleStretching(
    ScheduleStretchingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.scheduleDailyReminder(
      notificationId: _stretchingNotificationId,
      title: '🧘 Stretching Time',
      body: 'È il momento di fare stretching! '
          'Anche 10 minuti fanno la differenza.',
      hour: event.hour,
      minute: event.minute,
    );
  }

  Future<void> _onCancelStretching(
    CancelStretchingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.cancelScheduledReminder(_stretchingNotificationId);
  }

  Future<void> _onScheduleTraining(
    ScheduleTrainingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    // Cancel any existing training reminders first
    for (var i = 0; i < 7; i++) {
      await repository.cancelScheduledReminder(_trainingBaseNotificationId + i);
    }

    // Schedule for each selected day
    for (final day in event.days) {
      await repository.scheduleDailyReminder(
        notificationId: _trainingBaseNotificationId + (day - 1),
        title: '💪 Allenamento Previsto',
        body: 'Oggi è giorno di allenamento! '
            'Preparati per la tua sessione.',
        hour: event.hour,
        minute: event.minute,
      );
    }
  }

  Future<void> _onCancelTraining(
    CancelTrainingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    for (var i = 0; i < 7; i++) {
      await repository.cancelScheduledReminder(_trainingBaseNotificationId + i);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
