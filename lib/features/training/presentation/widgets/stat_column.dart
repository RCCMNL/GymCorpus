import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

/// Quanto conta questo numero rispetto a quelli che gli stanno intorno.
///
/// Il pannello del cardio mostrava sei statistiche tutte dello stesso
/// peso: distanza, durata, velocita' media, velocita', passi, calorie.
/// Sei numeri identici sono sei numeri fra cui scegliere mentre corri.
/// Due sono quelli che si guardano di sfuggita, gli altri si leggono
/// dopo: a dirlo deve essere la pagina.
enum StatProminence {
  /// Il numero che si legge di corsa.
  primary,

  /// Il contorno: piu' piccolo e smorzato, ma leggibile.
  secondary,
}

/// Etichetta e valore in evidenza per una singola statistica, usata nel
/// pannello del CardioTrackerScreen.
class StatColumn extends StatelessWidget {
  const StatColumn({
    required this.label,
    required this.value,
    required this.theme,
    this.prominence = StatProminence.primary,
    super.key,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final StatProminence prominence;

  @override
  Widget build(BuildContext context) {
    final style = switch (prominence) {
      StatProminence.primary => theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        fontFamily: 'Lexend',
        color: theme.colorScheme.onSurface,
      ),
      StatProminence.secondary => theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontFamily: 'Lexend',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
      ),
    };

    return Column(
      children: [
        StatLabel(label),
        const SizedBox(height: 6),
        // Il numero si stringe quando lo spazio non basta invece di
        // uscire dal pannello: "10.4 km/h" su uno schermo stretto non ci
        // stava, e la riga veniva tranciata.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, maxLines: 1, style: style),
        ),
      ],
    );
  }
}
