import 'dart:math' as math;

/// Attivita' cardio tracciabili.
///
/// L'identificativo e' quello salvato nella colonna `type` delle sessioni:
/// `run` e `walk` erano gia' in uso e restano invariati.
enum CardioActivity {
  run('run', 'Corsa'),
  walk('walk', 'Camminata'),
  bike('bike', 'Bici'),
  treadmill('treadmill', 'Tapis roulant'),
  elliptical('elliptical', 'Ellittica'),
  rowing('rowing', 'Vogatore');

  const CardioActivity(this.id, this.label);

  final String id;
  final String label;

  /// Ricava l'attivita' dal valore salvato.
  ///
  /// Un identificativo sconosciuto ricade sulla corsa: puo' arrivare da una
  /// versione piu' recente dell'app o da un dato corrotto, e non deve far
  /// fallire la lettura dello storico.
  static CardioActivity fromId(String? id) {
    for (final activity in CardioActivity.values) {
      if (activity.id == id) return activity;
    }
    return CardioActivity.run;
  }

  /// Le attivita' all'aperto registrano il percorso GPS.
  bool get tracksLocation =>
      this == run || this == walk || this == bike;

  /// L'ellittica non produce una distanza confrontabile: si registrano solo
  /// tempo e intensita'.
  bool get tracksDistance => this != elliptical;

  /// MET dell'attivita' alla velocita' indicata.
  ///
  /// I valori seguono il Compendium of Physical Activities. La velocita'
  /// viene limitata a un intervallo umano: un rimbalzo GPS puo' produrre
  /// numeri impossibili, e senza il limite moltiplicherebbe le calorie.
  double metAt(double speedKmh) {
    final speed = speedKmh.isFinite ? speedKmh.clamp(0.0, 45.0) : 0.0;

    switch (this) {
      case CardioActivity.walk:
        return _interpolate(speed, const [
          (3.2, 2.8),
          (4.8, 3.5),
          (5.6, 4.3),
          (6.4, 5.0),
          (8.0, 7.0),
        ]);
      case CardioActivity.run:
      case CardioActivity.treadmill:
        return _interpolate(speed, const [
          (6.4, 6.0),
          (8.0, 8.3),
          (9.7, 9.8),
          (11.3, 11.0),
          (12.9, 11.8),
          (14.5, 12.8),
          (16.0, 14.5),
        ]);
      case CardioActivity.bike:
        return _interpolate(speed, const [
          (16.0, 4.0),
          (19.0, 6.8),
          (22.5, 8.0),
          (26.0, 10.0),
          (32.0, 12.0),
        ]);
      case CardioActivity.elliptical:
        return 5;
      case CardioActivity.rowing:
        return 6;
    }
  }

  /// Calorie stimate con la formula MET: kcal = MET x kg x ore.
  double caloriesFor({
    required double speedKmh,
    required double weightKg,
    required int seconds,
  }) {
    if (seconds <= 0 || weightKg <= 0) return 0;
    return metAt(speedKmh) * weightKg * (seconds / 3600);
  }

  /// Sceglie il MET dalla prima soglia non superata, o quello finale.
  /// Interpola il MET tra i punti noti della tabella.
  ///
  /// A scalini il valore saltava di un punto intero superata la soglia: due
  /// corse a 9,6 e 9,8 km/h risultavano molto piu' diverse di quanto siano.
  static double _interpolate(double speed, List<(double, double)> anchors) {
    if (speed <= anchors.first.$1) return anchors.first.$2;
    if (speed >= anchors.last.$1) return anchors.last.$2;

    for (var i = 1; i < anchors.length; i++) {
      final (upperSpeed, upperMet) = anchors[i];
      if (speed > upperSpeed) continue;

      final (lowerSpeed, lowerMet) = anchors[i - 1];
      final ratio = (speed - lowerSpeed) / (upperSpeed - lowerSpeed);
      return lowerMet + (upperMet - lowerMet) * ratio;
    }

    return anchors.last.$2;
  }

  /// Velocita' media in km/h, usata per la stima delle calorie.
  static double averageSpeed({
    required double distanceKm,
    required int seconds,
  }) {
    if (seconds <= 0 || distanceKm <= 0) return 0;
    return distanceKm / (seconds / 3600);
  }

  /// Attivita' proposte all'avvio di una sessione.
  static const outdoor = [run, walk, bike];
  static const indoor = [treadmill, elliptical, rowing];

  static double clampSpeed(double speedKmh) =>
      speedKmh.isFinite ? math.max(0, math.min(speedKmh, 45)) : 0;
}
