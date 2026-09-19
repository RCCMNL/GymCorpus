import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

/// Etichetta e valore in evidenza per una singola statistica, usata nel
/// pannello del CardioTrackerScreen.
class StatColumn extends StatelessWidget {
  const StatColumn({
    required this.label,
    required this.value,
    required this.theme,
    super.key,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatLabel(label),
        const SizedBox(height: 6),
        // Il numero si stringe quando lo spazio non basta invece di
        // uscire dal pannello: "10.4 km/h" su uno schermo stretto non ci
        // stava, e la riga veniva tranciata.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
