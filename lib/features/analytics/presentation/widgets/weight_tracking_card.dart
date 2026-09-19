import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/utils/decimal_input.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/body_weight.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Grafico del peso corporeo sugli ultimi 30 giorni, con statistiche
/// attuale/max/min e il pulsante per registrare un nuovo peso.
class WeightTrackingCard extends StatefulWidget {
  const WeightTrackingCard({super.key});

  @override
  State<WeightTrackingCard> createState() => _WeightTrackingCardState();
}

class _WeightTrackingCardState extends State<WeightTrackingCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        var current = '--';
        var max = '--';
        var min = '--';
        var trendPoints = <double>[];
        final profileWeight = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user, _) => user.weight,
          orElse: () => null,
        );

        final trainingState = context.read<TrainingBloc>().state;
        final settings = trainingState is TrainingLoaded
            ? trainingState.settings
            : <String, String>{};
        final isImperial = (settings['units'] ?? 'KG') == 'LB';
        final unitText = isImperial ? 'lb' : 'kg';

        if (state is TrainingLoaded) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final startDate = today.subtract(const Duration(days: 29));

          final logs = state.bodyWeightLogs;
          final dayMap = <DateTime, double>{};
          final actualDataDays = <int>{};
          final dates = <DateTime>[];
          final points = <double>[];

          if (logs.isNotEmpty) {
            for (final log in logs) {
              final d = DateTime(log.date.year, log.date.month, log.date.day);
              if (!dayMap.containsKey(d)) {
                dayMap[d] = log.weight;
              }
            }

            var lastWeight = logs
                .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
                .weight;

            for (var i = 0; i < 30; i++) {
              final d = startDate.add(Duration(days: i));
              dates.add(d);
              if (dayMap.containsKey(d)) {
                lastWeight = dayMap[d] ?? lastWeight;
                actualDataDays.add(i);
              }

              points.add(
                isImperial ? UnitConverter.kgToLb(lastWeight) : lastWeight,
              );
            }
            trendPoints = points;

            // Stats
            final latestWeightValue = logs.first.weight;
            current =
                (isImperial
                        ? UnitConverter.kgToLb(latestWeightValue)
                        : latestWeightValue)
                    .toStringAsFixed(1);

            final allProcessedWeights = logs
                .map(
                  (e) => isImperial ? UnitConverter.kgToLb(e.weight) : e.weight,
                )
                .toList();
            max = allProcessedWeights
                .reduce((a, b) => a > b ? a : b)
                .toStringAsFixed(1);
            min = allProcessedWeights
                .reduce((a, b) => a < b ? a : b)
                .toStringAsFixed(1);
          } else if (profileWeight != null) {
            final displayWeight = isImperial
                ? UnitConverter.kgToLb(profileWeight)
                : profileWeight;

            for (var i = 0; i < 30; i++) {
              dates.add(startDate.add(Duration(days: i)));
              points.add(displayWeight);
            }
            trendPoints = points;
            current = displayWeight.toStringAsFixed(1);
            max = displayWeight.toStringAsFixed(1);
            min = displayWeight.toStringAsFixed(1);
          } else {
            // Empty state defaults
            for (var i = 0; i < 30; i++) {
              dates.add(startDate.add(Duration(days: i)));
              points.add(0);
            }
            trendPoints = points;
          }

          // Calculate change
          double change = 0;
          if (points.length >= 2) {
            change = points.last - points.first;
          }
          final changeText =
              (change >= 0 ? '+' : '') + change.toStringAsFixed(1);
          final changeColor = change <= 0
              ? theme.colorScheme.tertiary
              : theme.colorScheme.error;

          return AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Il titolo cede spazio a cio che gli sta a destra.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progresso Peso',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: changeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$changeText $unitText',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: changeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'ULTIMI 30 GIORNI',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: () => _showAddWeightDialog(context),
                          icon: const Icon(Icons.add_rounded, size: 24),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    WeightItem(
                      label: 'Attuale',
                      value: current,
                      unit: unitText,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    WeightItem(
                      label: 'Max',
                      value: max,
                      unit: unitText,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    WeightItem(
                      label: 'Min',
                      value: min,
                      unit: unitText,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.05,
                            ),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 29,
                      minY: (trendPoints.reduce((a, b) => a < b ? a : b) - 2)
                          .clamp(0, double.infinity),
                      maxY: trendPoints.reduce((a, b) => a > b ? a : b) + 2,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) =>
                              theme.colorScheme.surfaceContainerHighest,
                          tooltipBorderRadius: BorderRadius.circular(12),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              return LineTooltipItem(
                                '${flSpot.y.toStringAsFixed(1)} $unitText\n',
                                theme.textTheme.labelMedium!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: formatDayMonthShort(
                                      dates[flSpot.x.toInt()],
                                    ),
                                    style: theme.textTheme.labelSmall!.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trendPoints.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              final isActual = actualDataDays.contains(index);
                              return FlDotCirclePainter(
                                radius: isActual ? 4 : 0,
                                color: theme.colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor: theme.colorScheme.surface,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                theme.colorScheme.primary.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Le date sotto il grafico si stringono invece di uscire.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${startDate.day} ${UnitConverter.monthName(startDate.month)}'
                            .toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      // Week indicators
                      ...List.generate(3, (index) {
                        final weekNum = 3 - index;
                        return Text(
                          '-$weekNum SET',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 7,
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        );
                      }),
                      Text(
                        'OGGI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    _showWeightDialog(context);
  }

  void _showWeightDialog(BuildContext context, {BodyWeightLogEntity? log}) {
    final controller = TextEditingController(
      text: log != null ? log.weight.toString() : '',
    );
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    if (log != null) {
      final w = isImperial ? UnitConverter.kgToLb(log.weight) : log.weight;
      controller.text = w.toStringAsFixed(1);
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log == null ? 'Registra Peso' : 'Modifica Peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: isImperial ? 'Peso (lb)' : 'Peso (kg)',
            suffixText: isImperial ? 'lb' : 'kg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final weightValue = parseDecimalInput(controller.text);
              if (weightValue != null) {
                var weight = weightValue;
                if (isImperial) {
                  weight = UnitConverter.lbToKg(weight);
                }
                if (log == null) {
                  context.read<TrainingBloc>().add(
                    AddBodyWeightLogEvent(weight),
                  );
                } else {
                  context.read<TrainingBloc>().add(
                    UpdateBodyWeightLogEvent(log.id!, weight),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(log == null ? 'Salva' : 'Aggiorna'),
          ),
        ],
      ),
    );
  }
}

class WeightItem extends StatelessWidget {
  const WeightItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        size: AppCardSize.tight,
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            // Valore e unita' si stringono insieme: sono una cosa sola.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
