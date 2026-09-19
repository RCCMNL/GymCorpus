import 'package:flutter/material.dart';

/// La scala dei raggi dell'app.
///
/// Prima ce n'erano diciannove valori diversi sparsi nei file, spesso a
/// quattro pixel di distanza fra loro: 20 e 22 sulla stessa schermata,
/// 14 e 16 dentro la stessa card. A occhio non si legge "questo e' piu'
/// morbido di quello", si legge che nessuno ha deciso.
///
/// Sei gradini, piu' la pillola. Se una cosa sembra chiedere un raggio
/// che qui non c'e', quasi sempre la risposta e' che va nel gradino
/// accanto: e' il vincolo che tiene insieme l'insieme.
abstract final class AppRadius {
  /// Tacche, barre di avanzamento, quadratini di legenda.
  static const xs = BorderRadius.all(Radius.circular(8));

  /// Etichette e riquadri piccoli dentro una card.
  static const sm = BorderRadius.all(Radius.circular(12));

  /// Campi, bottoni, tessere di elenco: il raggio piu' comune.
  static const md = BorderRadius.all(Radius.circular(16));

  /// Contenitori medi: pannelli, banner, pulsanti larghi.
  static const lg = BorderRadius.all(Radius.circular(20));

  /// Card e dialoghi.
  static const xl = BorderRadius.all(Radius.circular(24));

  /// Superfici grandi: eroi, riquadri a tutta larghezza.
  static const xxl = BorderRadius.all(Radius.circular(32));

  /// Lati a semicerchio, qualunque sia l'altezza: chip, badge, barre.
  static const pill = BorderRadius.all(Radius.circular(999));

  /// Solo i due angoli in alto, per i fogli che salgono dal basso.
  static const topXxl = BorderRadius.vertical(top: Radius.circular(32));
}
