import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';

/// Icona e colore di ogni attivita' cardio.
///
/// Sta nella presentazione perche' e' aspetto, non dominio: il tipo salvato
/// nel database resta l'identificativo di [CardioActivity].
extension CardioActivityStyle on CardioActivity {
  IconData get icon {
    switch (this) {
      case CardioActivity.run:
        return Icons.directions_run_rounded;
      case CardioActivity.walk:
        return Icons.directions_walk_rounded;
      case CardioActivity.bike:
        return Icons.directions_bike_rounded;
      case CardioActivity.treadmill:
        return Icons.fitness_center_rounded;
      case CardioActivity.elliptical:
        return Icons.sync_alt_rounded;
      case CardioActivity.rowing:
        return Icons.rowing_rounded;
    }
  }

  /// Colore d'accento: le attivita' all'aperto tengono i colori storici di
  /// corsa e camminata, cosi' lo storico gia' esistente non cambia aspetto.
  Color accent(ThemeData theme) {
    switch (this) {
      case CardioActivity.run:
        return theme.colorScheme.primary;
      case CardioActivity.walk:
        return Colors.orangeAccent;
      case CardioActivity.bike:
        return theme.colorScheme.tertiary;
      case CardioActivity.treadmill:
        return theme.colorScheme.secondary;
      case CardioActivity.elliptical:
        return const Color(0xFF8DE8C7);
      case CardioActivity.rowing:
        return const Color(0xFF94AAFF);
    }
  }

  /// Etichetta del pulsante di avvio.
  String get startLabel {
    switch (this) {
      case CardioActivity.run:
        return 'INIZIA CORSA';
      case CardioActivity.walk:
        return 'INIZIA CAMMINATA';
      case CardioActivity.bike:
        return 'INIZIA USCITA';
      case CardioActivity.treadmill:
      case CardioActivity.elliptical:
      case CardioActivity.rowing:
        return 'INIZIA SESSIONE';
    }
  }
}
