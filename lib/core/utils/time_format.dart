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
