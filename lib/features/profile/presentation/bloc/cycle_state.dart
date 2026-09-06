import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/services/cycle_forecast.dart';

class CycleState extends Equatable {
  const CycleState({
    required this.isLoading,
    this.logs = const [],
    this.summary,
    this.errorMessage,
  });

  final bool isLoading;
  final List<CycleLogEntity> logs;

  /// Ricalcolato a ogni aggiornamento dei log: non viene mai salvato.
  final CycleSummary? summary;

  final String? errorMessage;

  CycleState copyWith({
    bool? isLoading,
    List<CycleLogEntity>? logs,
    CycleSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CycleState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, logs, summary, errorMessage];
}
