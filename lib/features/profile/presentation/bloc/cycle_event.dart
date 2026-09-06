import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';

abstract class CycleEvent extends Equatable {
  const CycleEvent();

  @override
  List<Object?> get props => const [];
}

/// Apre l'ascolto sulle registrazioni salvate.
class LoadCycleLogsEvent extends CycleEvent {}

/// Arriva dallo stream del repository a ogni scrittura.
class CycleLogsUpdated extends CycleEvent {
  const CycleLogsUpdated(this.logs);

  final List<CycleLogEntity> logs;

  @override
  List<Object?> get props => [logs];
}

/// Registra l'inizio della mestruazione di oggi.
class StartPeriodEvent extends CycleEvent {}

/// Chiude la mestruazione in corso alla data di oggi.
class EndPeriodEvent extends CycleEvent {}

class DeleteCycleLogEvent extends CycleEvent {
  const DeleteCycleLogEvent(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
