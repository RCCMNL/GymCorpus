import 'package:equatable/equatable.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_info.dart';

/// Quanto e' urgente aggiornare, rispetto alla versione installata.
enum AppUpdateUrgency {
  /// La versione installata e' gia' l'ultima (o non c'e' nessuna
  /// configurazione di aggiornamento da confrontare).
  none,

  /// C'e' una versione piu' recente, ma quella installata resta supportata:
  /// un promemoria dismissibile basta.
  optional,

  /// La versione installata e' sotto la soglia minima supportata: l'uso
  /// dell'app va bloccato finche' non si aggiorna.
  required,
}

class AppUpdateStatus extends Equatable {
  const AppUpdateStatus({required this.urgency, this.info});

  const AppUpdateStatus.none() : this(urgency: AppUpdateUrgency.none);

  final AppUpdateUrgency urgency;

  /// Presente per [AppUpdateUrgency.optional] e [AppUpdateUrgency.required],
  /// null per [AppUpdateUrgency.none].
  final AppUpdateInfo? info;

  @override
  List<Object?> get props => [urgency, info];
}
