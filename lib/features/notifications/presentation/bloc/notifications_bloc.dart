import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/error/failures.dart';
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
    on<ClearNotificationActionErrorEvent>(_onClearActionError);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
    on<DeleteNotificationEvent>(_onDelete);
    on<DeleteAllNotificationsEvent>(_onDeleteAll);
    on<AddNotificationLogEvent>(_onAddLog);
    on<ScheduleStretchingReminderEvent>(_onScheduleStretching);
    on<CancelStretchingReminderEvent>(_onCancelStretching);
    on<ScheduleTrainingReminderEvent>(_onScheduleTraining);
    on<CancelTrainingReminderEvent>(_onCancelTraining);

    _tapSubscription = NotificationService.instance.notificationTapStream
        .listen(_onNotificationTapped);
  }

  final NotificationsRepository repository;
  StreamSubscription<List<NotificationLogEntity>>? _subscription;
  StreamSubscription<NotificationPayloadData>? _tapSubscription;

  Future<void> _addLog({
    required String title,
    required String body,
    required String type,
  }) async {
    await repository.addNotificationLog(title: title, body: body, type: type);
  }

  void _onNotificationTapped(NotificationPayloadData payload) {
    unawaited(
      _addLog(title: payload.title, body: payload.body, type: payload.type),
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
    emit(state.copyWith(notifications: event.notifications, isLoading: false));
  }

  void _onClearActionError(
    ClearNotificationActionErrorEvent event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.actionError != null) {
      emit(state.copyWith(clearActionError: true));
    }
  }

  /// Esegue [action] e, se fallisce, porta l'errore in `actionError` invece
  /// di scartarlo. Restituisce `true` se l'azione e' andata a buon fine.
  ///
  /// Il valore di ritorno serve ai cicli di annullamento/programmazione dei
  /// promemoria (vedi `_onScheduleTraining` e `_onCancelTraining`) per
  /// fermarsi al primo fallimento: continuare significherebbe annullare o
  /// programmare i giorni restanti su uno stato gia' a meta', con il rischio
  /// di promemoria duplicati o mancanti senza che l'errore originale venga
  /// piu' segnalato.
  Future<bool> _runOrEmitFailure(
    Future<Either<Failure, void>> Function() action,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await action();
    return result.fold((failure) {
      emit(state.copyWith(actionError: failure.message));
      return false;
    }, (_) => true);
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _runOrEmitFailure(() => repository.markAsRead(event.id), emit);
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _runOrEmitFailure(repository.markAllAsRead, emit);
  }

  Future<void> _onDelete(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _runOrEmitFailure(
      () => repository.deleteNotification(event.id),
      emit,
    );
  }

  Future<void> _onDeleteAll(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _runOrEmitFailure(repository.deleteAllNotifications, emit);
  }

  Future<void> _onAddLog(
    AddNotificationLogEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _addLog(title: event.title, body: event.body, type: event.type);
  }

  Future<void> _onScheduleStretching(
    ScheduleStretchingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _runOrEmitFailure(
      () => repository.scheduleDailyReminder(
        notificationId: _stretchingNotificationId,
        title: 'Stretching time',
        body: 'E il momento di fare stretching. Anche 10 minuti aiutano.',
        hour: event.hour,
        minute: event.minute,
      ),
      emit,
    );
  }

  Future<void> _onCancelStretching(
    CancelStretchingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _runOrEmitFailure(
      () => repository.cancelScheduledReminder(_stretchingNotificationId),
      emit,
    );
  }

  Future<void> _onScheduleTraining(
    ScheduleTrainingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    for (var i = 0; i < 7; i++) {
      final cancelled = await _runOrEmitFailure(
        () =>
            repository.cancelScheduledReminder(_trainingBaseNotificationId + i),
        emit,
      );
      if (!cancelled) return;
    }

    for (final day in event.days) {
      final scheduled = await _runOrEmitFailure(
        () => repository.scheduleWeeklyReminder(
          notificationId: _trainingBaseNotificationId + (day - 1),
          title: 'Allenamento previsto',
          body: 'Oggi e giorno di allenamento. Preparati per la sessione.',
          dayOfWeek: day,
          hour: event.hour,
          minute: event.minute,
        ),
        emit,
      );
      if (!scheduled) return;
    }
  }

  Future<void> _onCancelTraining(
    CancelTrainingReminderEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    for (var i = 0; i < 7; i++) {
      final cancelled = await _runOrEmitFailure(
        () =>
            repository.cancelScheduledReminder(_trainingBaseNotificationId + i),
        emit,
      );
      if (!cancelled) return;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _tapSubscription?.cancel();
    return super.close();
  }
}
