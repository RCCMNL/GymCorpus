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

/// Corregge le date di una registrazione esistente.
class UpdateCycleLogEvent extends CycleEvent {
  const UpdateCycleLogEvent({
    required this.id,
    required this.startDate,
    this.endDate,
  });

  final int id;
  final DateTime startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [id, startDate, endDate];
}

/// Accende o spegne il promemoria del ciclo previsto.
class SetCycleReminderEvent extends CycleEvent {
  const SetCycleReminderEvent({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Arriva dallo stream della preferenza salvata.
class CycleReminderUpdated extends CycleEvent {
  const CycleReminderUpdated({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}
