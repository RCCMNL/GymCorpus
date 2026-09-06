import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/repositories/cycle_repository.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_event.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_state.dart';

/// Stato del calendario ciclo.
///
/// Vive quanto la schermata, non quanto l'app: viene creato dalla rotta del
/// calendario, cosi' chi non lo apre non mette mai in ascolto quei dati.
class CycleBloc extends Bloc<CycleEvent, CycleState> {
  CycleBloc({
    required this.repository,
    required this.notifications,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const CycleState(isLoading: true)) {
    on<LoadCycleLogsEvent>(_onLoad);
    on<CycleLogsUpdated>(_onUpdated);
    on<CycleReminderUpdated>(_onReminderUpdated);
    on<StartPeriodEvent>(_onStartPeriod);
    on<EndPeriodEvent>(_onEndPeriod);
    on<UpdateCycleLogEvent>(_onUpdateLog);
    on<DeleteCycleLogEvent>(_onDelete);
    on<SetCycleReminderEvent>(_onSetReminder);
  }

  final CycleRepository repository;
  final NotificationsRepository notifications;
  final DateTime Function() _clock;

  StreamSubscription<List<CycleLogEntity>>? _subscription;
  StreamSubscription<bool>? _reminderSubscription;

  /// Identificativo riservato al promemoria del ciclo: sta fuori dai range
  /// gia' usati per stretching (9001) e allenamento (9010-9016).
  static const reminderNotificationId = 9020;

  /// Con quanto anticipo avvisare rispetto alla previsione.
  static const reminderLeadDays = 2;

  Future<void> _onLoad(
    LoadCycleLogsEvent event,
    Emitter<CycleState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = repository.watchCycleLogs().listen(
      (logs) => add(CycleLogsUpdated(logs)),
    );

    await _reminderSubscription?.cancel();
    _reminderSubscription = repository.watchReminderEnabled().listen(
      (enabled) => add(CycleReminderUpdated(enabled: enabled)),
    );
  }

  void _onUpdated(CycleLogsUpdated event, Emitter<CycleState> emit) {
    final summary = CycleForecast.calculate(logs: event.logs, today: _clock());

    emit(
      CycleState(
        isLoading: false,
        logs: event.logs,
        summary: summary,
        errorMessage: state.errorMessage,
        reminderEnabled: state.reminderEnabled,
      ),
    );

    unawaited(_syncReminder(summary: summary, enabled: state.reminderEnabled));
  }

  void _onReminderUpdated(
    CycleReminderUpdated event,
    Emitter<CycleState> emit,
  ) {
    emit(state.copyWith(reminderEnabled: event.enabled));

    unawaited(_syncReminder(summary: state.summary, enabled: event.enabled));
  }

  /// Riallinea il promemoria a ogni cambiamento: la data prevista si sposta
  /// a ogni registrazione, quindi va riprogrammata, non solo accesa.
  Future<void> _syncReminder({
    required CycleSummary? summary,
    required bool enabled,
  }) async {
    final nextStart = summary?.nextPeriodStart;

    if (!enabled || nextStart == null) {
      await notifications.cancelScheduledReminder(reminderNotificationId);
      return;
    }

    final date = DateTime(
      nextStart.year,
      nextStart.month,
      nextStart.day - reminderLeadDays,
      9,
    );

    await notifications.scheduleOneTimeReminder(
      notificationId: reminderNotificationId,
      title: 'Ciclo in arrivo',
      body: 'Secondo le tue registrazioni dovrebbe iniziare tra due giorni.',
      date: date,
      type: 'cycle',
    );
  }

  Future<void> _onStartPeriod(
    StartPeriodEvent event,
    Emitter<CycleState> emit,
  ) async {
    // Con una mestruazione gia' in corso il pulsante mostra "segna fine":
    // un doppio tocco non deve comunque aprire due cicli sovrapposti.
    if (state.summary?.hasOpenLog ?? false) return;

    final result = await repository.startPeriod(_clock());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _clearError(emit),
    );
  }

  Future<void> _onEndPeriod(
    EndPeriodEvent event,
    Emitter<CycleState> emit,
  ) async {
    final open = _openLog();
    if (open == null) return;

    final result = await repository.endPeriod(id: open.id, date: _clock());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _clearError(emit),
    );
  }

  Future<void> _onUpdateLog(
    UpdateCycleLogEvent event,
    Emitter<CycleState> emit,
  ) async {
    final result = await repository.updateCycleLog(
      id: event.id,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _clearError(emit),
    );
  }

  Future<void> _onDelete(
    DeleteCycleLogEvent event,
    Emitter<CycleState> emit,
  ) async {
    final result = await repository.deleteCycleLog(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _clearError(emit),
    );
  }

  Future<void> _onSetReminder(
    SetCycleReminderEvent event,
    Emitter<CycleState> emit,
  ) async {
    final result = await repository.setReminderEnabled(enabled: event.enabled);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _clearError(emit),
    );
  }

  /// La sola registrazione chiudibile e' l'ultima, se aperta: una vecchia
  /// rimasta senza fine e' storia incompleta, non la mestruazione di oggi.
  CycleLogEntity? _openLog() {
    if (state.logs.isEmpty) return null;

    final sorted = [...state.logs]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final last = sorted.last;
    return last.isOngoing ? last : null;
  }

  void _clearError(Emitter<CycleState> emit) {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _reminderSubscription?.cancel();
    return super.close();
  }
}
