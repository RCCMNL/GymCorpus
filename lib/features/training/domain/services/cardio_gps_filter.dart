/// Quanto ci si puo' fidare della posizione ricevuta.
enum GpsQuality { poor, fair, good }

/// Decide quali punti GPS entrano in una sessione cardio.
///
/// Le soglie stanno insieme, e fuori dal listener delle posizioni, perche'
/// un punto scartato deve sparire del tutto: prima lo scarto avveniva
/// dentro la chiusura di `setState`, e il punto continuava comunque a
/// spostare la mappa, che saltava sui rimbalzi appena rifiutati.
abstract final class CardioGpsFilter {
  /// Oltre questa imprecisione dichiarata il punto non si usa.
  static const accuracyLimitMeters = 20.0;

  /// Fra due aggiornamenti ravvicinati uno scarto maggiore di questo
  /// significa una velocita' impossibile per un umano: e' un rimbalzo.
  static const jumpLimitMeters = 35.0;

  /// Vero se il punto va ignorato. [metersFromPrevious] e' `null` per il
  /// primo punto di un percorso, che non ha un precedente da cui saltare.
  static bool rejects({
    required double accuracyMeters,
    required double? metersFromPrevious,
  }) {
    if (accuracyMeters > accuracyLimitMeters) return true;
    if (metersFromPrevious == null) return false;
    return metersFromPrevious > jumpLimitMeters;
  }

  static GpsQuality qualityFor(double accuracyMeters) {
    if (accuracyMeters > 40) return GpsQuality.poor;
    if (accuracyMeters > accuracyLimitMeters) return GpsQuality.fair;
    return GpsQuality.good;
  }
}
