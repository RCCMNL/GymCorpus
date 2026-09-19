import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/empty_state.dart';
import 'package:gym_corpus/core/widgets/labels.dart';

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
        // Titolo e sottotitolo cedono spazio al tasto indietro.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cronologia cardio',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SectionTitle('CRONOLOGIA E PERCORSI'),
            ],
          ),
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
          borderRadius: AppRadius.md,
          border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatLabel(label.toUpperCase()),
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
            borderRadius: AppRadius.xl,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('PANORAMICA CARDIO'),
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
                    accentColor: AppPalette.gold,
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
    // Scorrevole con altezza minima pari allo schermo: le spaziature
    // elastiche centrano il messaggio quando c'e' posto, e su uno schermo
    // basso il contenuto scorre invece di essere tagliato.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // Da' alla colonna un'altezza definita: senza, le spaziature
          // elastiche non saprebbero fra cosa distribuirsi.
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardioHistoryTopBar(theme: theme),
                  const Spacer(),
                  const EmptyStateCard(
                    icon: Icons.route_rounded,
                    title: 'Nessuna sessione cardio salvata',
                    message:
                        'Quando registri corsa o camminata, qui troverai '
                        'cronologia, percorso e metriche recenti.',
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
