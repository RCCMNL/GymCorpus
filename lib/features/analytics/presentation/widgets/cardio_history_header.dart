import 'package:flutter/material.dart';

/// Barra superiore con pulsante indietro e titolo di CardioHistoryScreen.
class CardioHistoryTopBar extends StatelessWidget {
  const CardioHistoryTopBar({required this.theme, super.key});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cronologia cardio',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
            Text(
              'CRONOLOGIA E PERCORSI',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Riquadro con etichetta e valore per una singola statistica riassuntiva.
class CardioOverviewStat extends StatelessWidget {
  const CardioOverviewStat({
    required this.label,
    required this.value,
    required this.accentColor,
    super.key,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
                color: accentColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Intestazione di CardioHistoryScreen con la panoramica di sessioni,
/// distanza e calorie totali.
class CardioHistoryOverview extends StatelessWidget {
  const CardioHistoryOverview({
    required this.totalSessions,
    required this.totalDistance,
    required this.totalCalories,
    super.key,
  });

  final int totalSessions;
  final double totalDistance;
  final int totalCalories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardioHistoryTopBar(theme: theme),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.10),
                theme.colorScheme.tertiary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PANORAMICA CARDIO',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CardioOverviewStat(
                    label: 'Sessioni',
                    value: totalSessions.toString(),
                    accentColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  CardioOverviewStat(
                    label: 'Distanza',
                    value: '${totalDistance.toStringAsFixed(1)} km',
                    accentColor: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 12),
                  CardioOverviewStat(
                    label: 'Kcal',
                    value: totalCalories.toString(),
                    accentColor: Colors.orangeAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stato vuoto di CardioHistoryScreen quando non esistono sessioni salvate.
class EmptyCardioHistoryView extends StatelessWidget {
  const EmptyCardioHistoryView({required this.theme, super.key});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardioHistoryTopBar(theme: theme),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.route_rounded,
                  size: 52,
                  color: theme.colorScheme.primary.withValues(alpha: 0.75),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nessuna sessione cardio salvata',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quando registri corsa o camminata, qui troverai cronologia, percorso e metriche recenti.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
