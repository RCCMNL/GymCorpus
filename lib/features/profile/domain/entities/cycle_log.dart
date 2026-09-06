import 'package:equatable/equatable.dart';

/// Una mestruazione registrata dall'utente.
///
/// `endDate` nullo significa "ancora in corso": e' l'unico stato che
/// distingue un ciclo aperto da uno concluso, quindi non va riempito con
/// una data di comodo quando manca.
class CycleLogEntity extends Equatable {
  const CycleLogEntity({
    required this.id,
    required this.startDate,
    this.endDate,
  });

  final int id;
  final DateTime startDate;
  final DateTime? endDate;

  bool get isOngoing => endDate == null;

  @override
  List<Object?> get props => [id, startDate, endDate];
}
