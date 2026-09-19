import 'package:flutter/material.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/features/analytics/domain/progress_formatters.dart';
import 'package:gym_corpus/features/training/domain/entities/body_measurement.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';

/// Riepilogo in evidenza in cima a ProgressScreen: ultimo peso registrato
/// per la tab Peso, stato delle misure per la tab Misure.
class ProgressHero extends StatefulWidget {
  const ProgressHero({
    required this.logs,
    required this.profileWeight,
    required this.measurements,
    required this.settings,
    required this.activeTab,
    super.key,
  });

  final List<BodyWeightLogEntity> logs;
  final double? profileWeight;
  final List<BodyMeasurementEntity> measurements;
  final Map<String, String> settings;
  final int activeTab;

  @override
  State<ProgressHero> createState() => _ProgressHeroState();
}

class _ProgressHeroState extends State<ProgressHero> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedLogs = List<BodyWeightLogEntity>.from(widget.logs)
      ..sort((a, b) => b.date.compareTo(a.date));
    final sortedMeasurements = List<BodyMeasurementEntity>.from(
      widget.measurements,
    )..sort((a, b) => b.date.compareTo(a.date));

    final isImperial = widget.settings['units'] == 'LB';
    final latestWeight = sortedLogs.isNotEmpty ? sortedLogs.first : null;
    final previousWeight = sortedLogs.length > 1 ? sortedLogs[1] : null;

    final isWeightTab = widget.activeTab == 0;

    // For measurements summary grid
    final latestByPart = <String, BodyMeasurementEntity>{};
    for (final measurement in sortedMeasurements) {
      latestByPart.putIfAbsent(measurement.part, () => measurement);
    }
    final sortedParts = latestByPart.keys.toList()..sort();

    final weightDelta = latestWeight != null && previousWeight != null
        ? latestWeight.weight - previousWeight.weight
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isWeightTab
              ? "Controlla l'andamento del tuo peso."
              : 'Monitora le tue circonferenze corporee.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isWeightTab
                  ? [
                      theme.colorScheme.primary.withValues(alpha: 0.16),
                      theme.colorScheme.tertiary.withValues(alpha: 0.10),
                    ]
                  : [
                      theme.colorScheme.tertiary.withValues(alpha: 0.16),
                      theme.colorScheme.primary.withValues(alpha: 0.10),
                    ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color:
                  (isWeightTab
                          ? theme.colorScheme.primary
                          : theme.colorScheme.tertiary)
                      .withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeightTab) ...[
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface.withValues(
                          alpha: 0.24,
                        ),
                      ),
                      child: Icon(
                        Icons.monitor_weight_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latestWeight != null
                                ? formatWeight(
                                    latestWeight.weight,
                                    isImperial: isImperial,
                                  )
                                : widget.profileWeight != null
                                ? formatWeight(
                                    widget.profileWeight!,
                                    isImperial: isImperial,
                                  )
                                : '--',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            latestWeight != null
                                ? 'Ultimo peso registrato'
                                : widget.profileWeight != null
                                ? 'Peso attuale dal profilo'
                                : 'Nessun peso registrato',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (weightDelta != null)
                      Flexible(
                        child: DeltaBadge(
                          value: weightDelta,
                          isImperial: isImperial,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: HeroMetricChip(
                        icon: Icons.history_toggle_off_rounded,
                        label: 'Ultimo log peso',
                        value: latestWeight != null
                            ? formatShortDate(latestWeight.date)
                            : widget.profileWeight != null
                            ? 'Profilo'
                            : 'Nessun dato',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.straighten_rounded,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stato Attuale',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Lexend',
                              ),
                            ),
                            Text(
                              '${latestByPart.length} aree monitorate',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: sortedParts.length,
                    itemBuilder: (context, index) {
                      final part = sortedParts[index];
                      final m = latestByPart[part]!;
                      return AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        size: AppCardSize.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              part.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.outline,
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${m.value.toStringAsFixed(1)} cm',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Lexend',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Chip con icona, valore in evidenza ed etichetta usata dentro [ProgressHero].
class HeroMetricChip extends StatelessWidget {
  const HeroMetricChip({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(14),
      tone: AppCardTone.sunken,
      child: Row(
        children: [
          IconBadge(
            icon,
            color: theme.colorScheme.primary,
            size: IconBadgeSize.small,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge che mostra la variazione di peso rispetto all'ultimo log,
/// con colore e freccia coerenti con la direzione del cambiamento.
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({required this.value, required this.isImperial, super.key});

  final double value;
  final bool isImperial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDown = value <= 0;
    final accent = isDown ? theme.colorScheme.tertiary : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDown ? Icons.south_rounded : Icons.north_rounded,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 4),
              Text(
                formatSignedWeight(value, isImperial: isImperial),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'vs ultimo log',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
