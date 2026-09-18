/// Il conto alla rovescia del recupero fra una serie e l'altra.
///
/// Vive fuori dal widget perche' il punto delicato non e' il numero che
/// scende, ma il tempo che passa quando nessuno sta guardando: in
/// background il recupero deve continuare a scorrere, in pausa no. La
/// schermata le confondeva, e tornando da un'app aperta durante la pausa
/// il recupero era gia' finito da solo.
class RestCountdown {
  RestCountdown({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  int _remaining = 0;
  int _total = 0;

  /// Quando scadra' il recupero, o `null` se il tempo e' fermo.
  DateTime? _endsAt;

  /// I secondi che mancano alla fine del recupero.
  int get remaining => _remaining;

  /// I secondi da cui e' partito questo recupero: e' la misura su cui si
  /// calcola l'avanzamento.
  int get total => _total;

  /// Vero se il tempo sta scorrendo: falso da fermo o in pausa.
  bool get isRunning => _endsAt != null;

  bool get isOver => _remaining <= 0;

  void start(int seconds) {
    _remaining = seconds;
    _total = seconds;
    _endsAt = _now().add(Duration(seconds: seconds));
  }

  void tick() {
    if (_endsAt == null || _remaining <= 0) return;
    _remaining--;
  }

  /// Ferma il tempo senza perdere i secondi che restano.
  void pause() => _endsAt = null;

  void resume() {
    if (isOver) return;
    _endsAt = _now().add(Duration(seconds: _remaining));
  }

  /// Ritorno in primo piano: recupera il tempo trascorso mentre il timer
  /// era sospeso dal sistema. Da fermo non cambia nulla.
  void onForeground() {
    final endsAt = _endsAt;
    if (endsAt == null) return;

    final left = endsAt.difference(_now()).inSeconds;
    _remaining = left > 0 ? left : 0;
  }

  void stop() {
    _endsAt = null;
    _remaining = 0;
  }
}
