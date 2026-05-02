import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/services/notification_service.dart';
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
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
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

    _tapSubscription =
        NotificationService.instance.notificationTapStream.listen(
      _onNotificationTapped,
    );
  }

  final NotificationsRepository repository;
  StreamSubscription<List<NotificationLogEntity>>? _subscription;
  StreamSubscription<NotificationPayloadData>? _tapSubscription;

  Future<void> _addLog({
    required String title,
    required String body,
    required String type,
  }) async {
    await repository.addNotificationLog(
      title: title,
      body: body,
      type: type,
    );
  }

  void _onNotificationTapped(NotificationPayloadData payload) {
    unawaited(
      _addLog(
        title: payload.title,
        body: payload.body,
        type: payload.type,
      ),
    );
  }

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
    await _addLog(
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
      title: 'Stretching time',
      body: 'E il momento di fare stretching. Anche 10 minuti aiutano.',
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
    for (var i = 0; i < 7; i++) {
      await repository.cancelScheduledReminder(_trainingBaseNotificationId + i);
    }

    for (final day in event.days) {
      await repository.scheduleWeeklyReminder(
        notificationId: _trainingBaseNotificationId + (day - 1),
        title: 'Allenamento previsto',
        body: 'Oggi e giorno di allenamento. Preparati per la sessione.',
        dayOfWeek: day,
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
    _tapSubscription?.cancel();
    return super.close();
  }
}
