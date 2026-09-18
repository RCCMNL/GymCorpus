import 'dart:async';

/// Un avviso differito di cui esiste al massimo una copia.
///
/// Nasce da un `Future.delayed` che non si poteva annullare: ogni riavvio
/// del recupero ne accodava uno nuovo e i vecchi restavano, pronti a
/// scattare in mezzo al recupero successivo. Qui riprogrammare sostituisce,
/// e annullare annulla davvero.
class PendingAlarm {
  Timer? _timer;

  bool get isPending => _timer?.isActive ?? false;

  void schedule(Duration delay, void Function() onFire) {
    _timer?.cancel();
    _timer = Timer(delay, onFire);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
