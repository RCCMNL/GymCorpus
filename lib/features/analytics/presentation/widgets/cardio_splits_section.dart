import 'package:flutter/material.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_splits.dart';

/// Passaggi al chilometro di una sessione cardio.
///
/// Gli split si ricavano dal percorso: le sessioni registrate prima che i
/// tempi venissero salvati non ne hanno, e la sezione lo dichiara invece di
/// scomparire senza spiegazioni.
class CardioSplitsSection extends StatelessWidget {
  const CardioSplitsSection({required this.splits, super.key});

  final List<CardioSplit> splits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (splits.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split non disponibili',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Questa sessione e stata registrata senza i tempi di '
              'passaggio. Le prossime avranno i passaggi al chilometro.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    final slowest = _slowestPace();
    final fastestIndex = _fastestIndex();

    return Column(
      children: [
        for (final split in splits)
          CardioSplitRow(
            split: split,
            isFastest: split.index == fastestIndex,
            relativeWidth: slowest <= 0
                ? 1
                : (_paceSeconds(split) / slowest).clamp(0.15, 1.0),
          ),
      ],
    );
  }

  /// Passo al chilometro in secondi, confrontabile tra tratti di lunghezza
  /// diversa.
  static double _paceSeconds(CardioSplit split) =>
      split.distanceKm <= 0 ? 0 : split.seconds / split.distanceKm;

  double _slowestPace() => splits
      .map(_paceSeconds)
      .fold<double>(0, (max, pace) => pace > max ? pace : max);

  /// Il tratto piu' veloce si cerca solo tra i chilometri completi: un
  /// tratto finale di 100 metri avrebbe un passo non confrontabile.
  int? _fastestIndex() {
    final full = splits.where((s) => !s.isPartial).toList();
    if (full.isEmpty) return null;

    var fastest = full.first;
    for (final split in full) {
      if (_paceSeconds(split) < _paceSeconds(fastest)) fastest = split;
    }
    return fastest.index;
  }
}

/// Una riga della lista split.
class CardioSplitRow extends StatelessWidget {
  const CardioSplitRow({
    required this.split,
    required this.isFastest,
    required this.relativeWidth,
    super.key,
  });

  final CardioSplit split;
  final bool isFastest;

  /// Larghezza della barra rispetto al tratto piu' lento, tra 0 e 1.
  final double relativeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFastest
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              'KM ${split.index}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 10,
                  width: constraints.maxWidth * relativeWidth,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isFastest ? 0.9 : 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (split.isPartial) ...[
            Text(
              '${split.distanceKm.toStringAsFixed(1)} km',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 56,
            child: Text(
              split.pace,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isFastest ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
