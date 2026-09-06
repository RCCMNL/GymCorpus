import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
  CycleBloc({required this.repository, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(const CycleState(isLoading: true)) {
    on<LoadCycleLogsEvent>(_onLoad);
    on<CycleLogsUpdated>(_onUpdated);
    on<StartPeriodEvent>(_onStartPeriod);
    on<EndPeriodEvent>(_onEndPeriod);
    on<DeleteCycleLogEvent>(_onDelete);
  }

  final CycleRepository repository;
  final DateTime Function() _clock;
  StreamSubscription<List<CycleLogEntity>>? _subscription;

  Future<void> _onLoad(
    LoadCycleLogsEvent event,
    Emitter<CycleState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = repository.watchCycleLogs().listen(
      (logs) => add(CycleLogsUpdated(logs)),
    );
  }

  void _onUpdated(CycleLogsUpdated event, Emitter<CycleState> emit) {
    emit(
      CycleState(
        isLoading: false,
        logs: event.logs,
        summary: CycleForecast.calculate(logs: event.logs, today: _clock()),
        errorMessage: state.errorMessage,
      ),
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
    return super.close();
  }
}
