// Come l'app scrive i tempi.
//
// Sta qui perche' le stesse righe erano copiate in piu' schermate, e le
// copie avevano preso strade diverse: la stessa sessione veniva scritta in
// tre modi, e due passi su tre erano sbagliati.

/// Passo al chilometro in `mm:ss`.
///
/// Il totale al chilometro va arrotondato **prima** di essere diviso in
/// minuti e secondi: arrotondando dopo, 3599 secondi su 10 km diventavano
/// `05:60`, che non e' un orario.
String formatPace({required int seconds, required double distanceKm}) {
  if (distanceKm <= 0) return '--:--';

  final perKm = (seconds / distanceKm).round();
  return '${_pad(perKm ~/ 60)}:${_pad(perKm % 60)}';
}

String _pad(int value) => value.toString().padLeft(2, '0');

/// Durata come orologio: `45:12`, e `01:01:01` passata l'ora.
///
/// Con [alwaysHours] le ore ci sono sempre, anche a zero: lo vuole il
/// cronometro dell'allenamento, che deve restare largo uguale mentre
/// scorre.
String formatClock(int seconds, {bool alwaysHours = false}) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final base = '${_pad(minutes)}:${_pad(seconds % 60)}';

  if (hours == 0 && !alwaysHours) return base;
  return '${_pad(hours)}:$base';
}

/// Durata a parole corte: `45s`, `45m`, `1h 15m`, `2h`.
///
/// Passato il minuto i secondi spariscono, e passata l'ora spariscono
/// anche i minuti quando sono zero: sono numeri da leggere di sfuggita in
/// una scheda, non da cronometrare.
String formatCompactDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;

  if (hours == 0) return '${minutes}m';
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}
