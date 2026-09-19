import 'package:flutter/material.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';

/// Riassunto di una sessione cardio nello storico.
///
/// La mappa non vive piu' qui dentro: la mini mappa incorporata era troppo
/// piccola per essere letta e caricava tile per ogni riga dell'elenco. Il
/// percorso, con i passaggi al chilometro, sta nella schermata di dettaglio
/// che si apre toccando la card.
class DetailedCardioCard extends StatelessWidget {
  const DetailedCardioCard({
    required this.session,
    required this.accentColor,
    this.onTap,
    super.key,
  });

  final CardioSessionEntity session;
  final Color accentColor;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) {
    return formatDateTimeShort(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activity = CardioActivity.fromId(session.type);
    final accent = activity.accent(theme);
    final hasRoute =
        CardioRoutePoint.decode(session.routeJson ?? '').length > 1;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Icon(activity.icon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(session.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Text(
                        '${session.calories} kcal',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'Distanza',
                        value: '${session.distance.toStringAsFixed(2)} km',
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricTile(
                        label: 'Durata',
                        value: formatCompactDuration(session.duration),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricTile(
                        label: 'Velocita',
                        value: '${session.avgSpeed.toStringAsFixed(1)} km/h',
                        accentColor: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ChipMetric(
                      icon: Icons.timer_outlined,
                      text: '${session.pace} /km',
                      accentColor: accent,
                    ),
                    const SizedBox(width: 8),
                    if (hasRoute)
                      ChipMetric(
                        icon: Icons.place_outlined,
                        text: 'Vedi percorso',
                        accentColor: theme.colorScheme.tertiary,
                      )
                    else
                      ChipMetric(
                        icon: Icons.place_outlined,
                        text: 'Mappa assente',
                        accentColor: theme.colorScheme.outline,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Etichetta e valore di una singola metrica dentro DetailedCardioCard.
class MetricTile extends StatelessWidget {
  const MetricTile({
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

    return AppCard(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      size: AppCardSize.tight,
      tone: AppCardTone.sunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                  color: accentColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip compatto con icona e testo per una metrica secondaria.
class ChipMetric extends StatelessWidget {
  const ChipMetric({
    required this.icon,
    required this.text,
    required this.accentColor,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.10),
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
