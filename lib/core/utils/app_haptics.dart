import 'dart:async';

import 'package:flutter/services.dart';

/// Quando l'app si fa sentire.
///
/// Non a ogni tocco: una vibrazione che risponde a tutto smette di
/// voler dire qualcosa, e in palestra il telefono sta spesso appoggiato
/// da qualche parte. Solo dove il tocco cambia lo stato
/// dell'allenamento, e dove l'utente probabilmente non sta guardando lo
/// schermo.
abstract final class AppHaptics {
  /// Una serie chiusa, un traguardo raggiunto: il colpo che conferma.
  static void milestone() => unawaited(HapticFeedback.mediumImpact());

  /// Il recupero e' finito, la sessione e' partita o si e' fermata: i
  /// momenti in cui lo schermo e' lontano dagli occhi.
  static void transition() => unawaited(HapticFeedback.heavyImpact());

  /// Un valore scelto in una rotella o in una lista di opzioni.
  static void selection() => unawaited(HapticFeedback.selectionClick());
}
