import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrainingBloc>()
      ..add(LoadWeightLogsEvent())
      ..add(LoadBodyWeightLogsEvent())
      ..add(LoadCardioSessionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            var sessionsCount = 0;
            var totalWeight = 0.0;
            var monthSessions = 0;
            var monthWeight = 0.0;

            var currentUnit = 'KG';
            if (state is TrainingLoaded) {
              currentUnit = state.settings['units'] ?? 'KG';
              final logs = state.weightLogs;
              sessionsCount = logs.map((e) => e.workoutId).toSet().length;
              totalWeight = logs.fold(0.0, (sum, e) => sum + (e.weight * e.reps));

              final now = DateTime.now();
              final monthLogs = logs
                  .where((e) =>
                      e.timestamp.month == now.month &&
                      e.timestamp.year == now.year,
                  )
                  .toList();
              monthSessions = monthLogs.map((e) => e.workoutId).toSet().length;
              monthWeight = monthLogs.fold(0.0, (sum, e) => sum + (e.weight * e.reps));
            }
            final isImperial = currentUnit == 'LB';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics Dashboard',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PERFORMANCE TRACKING & VOLUME INSIGHTS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Insights Section
                  _InsightsSection(state: state, isImperial: isImperial),
                  const SizedBox(height: 24),

                  // Stats Cards Grid
                  _StatSection(
                    title: 'All-Time Stats',
                    color: theme.colorScheme.primary,
                    stats: [
                      _StatItem(
                        icon: Icons.fitness_center,
                        value: sessionsCount.toString(),
                        label: 'Workouts',
                      ),
                      _StatItem(
                        icon: Icons.schedule,
                        value: '${(sessionsCount * 0.8).toStringAsFixed(1)}h',
                        label: 'Time Spent',
                      ),
                      _StatItem(
                        icon: Icons.scale,
                        value: isImperial 
                          ? '${(UnitConverter.kgToLb(totalWeight) / 1000).toStringAsFixed(1)}k'
                          : '${(totalWeight / 1000).toStringAsFixed(1)}k',
                        label: isImperial ? 'Volume (lb)' : 'Volume (kg)',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatSection(
                    title: 'This Month',
                    color: theme.colorScheme.tertiary,
                    stats: [
                      _StatItem(
                        icon: Icons.calendar_month,
                        value: monthSessions.toString(),
                        label: 'Workouts',
                      ),
                      _StatItem(
                        icon: Icons.timer,
                        value: '${(monthSessions * 0.8).toStringAsFixed(1)}h',
                        label: 'Time spent',
                      ),
                      _StatItem(
                        icon: Icons.trending_up,
                        value: isImperial
                          ? '${(UnitConverter.kgToLb(monthWeight) / 1000).toStringAsFixed(1)}k'
                          : '${(monthWeight / 1000).toStringAsFixed(1)}k',
                        label: isImperial ? 'Volume (lb)' : 'Volume (kg)',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // This Week Activity Card
                  const _ActivityCard(),

                  const SizedBox(height: 24),

                  // Weight Tracking Card
                  const _WeightTrackingCard(),

                  const SizedBox(height: 24),

                  // BMI Card
                  const _BMICard(),

                  const SizedBox(height: 24),

                  // Cardio History Section
                  _CardioHistorySection(state: state),

                  const SizedBox(height: 100), // Bottom padding for navbar
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── INSIGHTS ──────────────────────────────────────────────────────────────

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.state, required this.isImperial});
  final TrainingState state;
  final bool isImperial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = _generateInsights(context);
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ).createShader(bounds),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'INSIGHTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(insight.icon, size: 16, color: insight.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insight.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<_Insight> _generateInsights(BuildContext context) {
    final insights = <_Insight>[];
    final theme = Theme.of(context);

    if (state is! TrainingLoaded) return insights;
    final loaded = state as TrainingLoaded;

    // Weight stability insight
    if (loaded.bodyWeightLogs.length >= 3) {
      final recent3 = loaded.bodyWeightLogs.take(3).map((e) => e.weight).toList();
      final range = recent3.reduce((a, b) => a > b ? a : b) - recent3.reduce((a, b) => a < b ? a : b);
      if (range < 0.5) {
        insights.add(_Insight(
          icon: Icons.balance,
          text: 'Il tuo peso è stabile da ${loaded.bodyWeightLogs.length >= 7 ? "3" : "2"} settimane. Ottimo lavoro!',
          color: theme.colorScheme.tertiary,
        ));
      }
    }

    // Volume trend insight
    final logs = loaded.weightLogs;
    if (logs.isNotEmpty) {
      final now = DateTime.now();
      final last30 = logs.where((e) => e.timestamp.isAfter(now.subtract(const Duration(days: 30)))).toList();
      final prev30 = logs.where((e) => e.timestamp.isAfter(now.subtract(const Duration(days: 60))) && e.timestamp.isBefore(now.subtract(const Duration(days: 30)))).toList();
    
      if (last30.isNotEmpty && prev30.isNotEmpty) {
        final volLast = last30.fold(0.0, (sum, e) => sum + e.weight * e.reps);
        final volPrev = prev30.fold(0.0, (sum, e) => sum + e.weight * e.reps);
        if (volPrev > 0) {
          final change = ((volLast - volPrev) / volPrev * 100).round();
          if (change > 0) {
            insights.add(_Insight(
              icon: Icons.trending_up,
              text: 'Hai aumentato il volume totale del $change% negli ultimi 30 giorni.',
              color: theme.colorScheme.primary,
            ));
          } else if (change < -5) {
            insights.add(_Insight(
              icon: Icons.trending_down,
              text: 'Il volume totale è calato del ${change.abs()}% rispetto al mese precedente.',
              color: Colors.orangeAccent,
            ));
          }
        }
      }
    }

    // Cardio sessions insight
    if (loaded.cardioSessions.isNotEmpty) {
      final totalKm = loaded.cardioSessions.fold(0.0, (sum, e) => sum + e.distance);
      insights.add(_Insight(
        icon: Icons.directions_run,
        text: 'Hai percorso ${totalKm.toStringAsFixed(1)} km in ${loaded.cardioSessions.length} sessioni cardio.',
        color: const Color(0xFFFF9494),
      ));
    }

    return insights.take(3).toList();
  }
}

class _Insight {
  const _Insight({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;
}

// ─── STATS ─────────────────────────────────────────────────────────────────

class _StatSection extends StatelessWidget {
  const _StatSection({
    required this.title,
    required this.color,
    required this.stats,
  });

  final String title;
  final Color color;
  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ─── ACTIVITY ──────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'OGGI'];
    final completed = [true, false, true, true, false, true, false];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: theme.colorScheme.secondary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK ACTIVITY',
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              final isToday = index == days.length - 1;
              final isDone = completed[index];
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: theme.colorScheme.primary, width: 2)
                          : (isDone
                              ? null
                              : Border.all(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                                )),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.secondary
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: isDone ? 1 : 0.6),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── WEIGHT TRACKING ───────────────────────────────────────────────────────

class _WeightTrackingCard extends StatelessWidget {
  const _WeightTrackingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        var current = '--';
        var max = '--';
        var min = '--';
        var trendPoints = <double>[];

        final trainingState = context.read<TrainingBloc>().state;
        final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
        final isImperial = (settings['units'] ?? 'KG') == 'LB';

        if (state is TrainingLoaded && state.bodyWeightLogs.isNotEmpty) {
          var logs = state.bodyWeightLogs;
          if (isImperial) {
            current = UnitConverter.kgToLb(logs.first.weight).toStringAsFixed(1);
            max = logs.map((e) => UnitConverter.kgToLb(e.weight)).reduce((a, b) => a > b ? a : b).toStringAsFixed(1);
            min = logs.map((e) => UnitConverter.kgToLb(e.weight)).reduce((a, b) => a < b ? a : b).toStringAsFixed(1);
            trendPoints = logs.map((e) => UnitConverter.kgToLb(e.weight)).toList().reversed.toList();
          } else {
            current = logs.first.weight.toStringAsFixed(1);
            max = logs.map((e) => e.weight).reduce((a, b) => a > b ? a : b).toStringAsFixed(1);
            min = logs.map((e) => e.weight).reduce((a, b) => a < b ? a : b).toStringAsFixed(1);
            trendPoints = logs.map((e) => e.weight).toList().reversed.toList();
          }
        }

        final unitText = isImperial ? 'lb' : 'kg';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight Tracking', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        'LAST 30 DAYS TREND',
                        style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddWeightDialog(context),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add Weight', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _WeightItem(label: 'Current', value: current, unit: unitText, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  _WeightItem(label: 'Maximum', value: max, unit: unitText, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  _WeightItem(label: 'Minimum', value: min, unit: unitText, color: theme.colorScheme.tertiary),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 100,
                width: double.infinity,
                child: CustomPaint(
                  painter: _TrendLinePainter(
                    color: theme.colorScheme.primary,
                    dataPoints: trendPoints,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('30 DAYS AGO', style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: theme.colorScheme.outline.withValues(alpha: 0.5))),
                  Text('TODAY', style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: theme.colorScheme.outline.withValues(alpha: 0.5))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final controller = TextEditingController();
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Body Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: isImperial ? 'Weight (lb)' : 'Weight (kg)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              double? weight = double.tryParse(controller.text);
              if (weight != null) {
                if (isImperial) {
                  weight = UnitConverter.lbToKg(weight);
                }
                context.read<TrainingBloc>().add(AddBodyWeightLogEvent(weight));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _WeightItem extends StatelessWidget {
  const _WeightItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900, fontSize: 18, color: color),
                  ),
                  TextSpan(
                    text: unit,
                    style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.6)),
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

// ─── TREND PAINTER ─────────────────────────────────────────────────────────

class _TrendLinePainter extends CustomPainter {
  const _TrendLinePainter({required this.color, this.dataPoints = const []});
  final Color color;
  final List<double> dataPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX =
        size.width / (dataPoints.length > 1 ? dataPoints.length - 1 : 1);

    final maxWeight = dataPoints.reduce((a, b) => a > b ? a : b);
    final minWeight = dataPoints.reduce((a, b) => a < b ? a : b);
    final range =
        (maxWeight - minWeight).abs() < 0.1 ? 1 : (maxWeight - minWeight);

    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minWeight) / range;
      final y =
          size.height - (normalizedY * size.height * 0.8 + size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Endpoint dot
    if (dataPoints.isNotEmpty) {
      final lastX = size.width;
      final normalizedY = (dataPoints.last - minWeight) / range;
      final lastY =
          size.height - (normalizedY * size.height * 0.8 + size.height * 0.1);

      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) =>
      oldDelegate.dataPoints != dataPoints;
}

// ─── BMI ────────────────────────────────────────────────────────────────────

class _BMICard extends StatelessWidget {
  const _BMICard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        double? bmi;
        String category = 'N/A';
        Color categoryColor = theme.colorScheme.outline;

        final user = state.maybeWhen(
          authenticated: (u) => u,
          orElse: () => null,
        );

        if (user != null && user.weight != null && user.height != null) {
          final hMetri = user.height! / 100;
          bmi = user.weight! / (hMetri * hMetri);

          if (bmi < 18.5) {
            category = 'UNDERWEIGHT';
            categoryColor = Colors.lightBlue;
          } else if (bmi < 25) {
            category = 'NORMAL';
            categoryColor = theme.colorScheme.tertiary;
          } else if (bmi < 30) {
            category = 'OVERWEIGHT';
            categoryColor = Colors.orange;
          } else {
            category = 'OBESE';
            categoryColor = Colors.red;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_search, color: categoryColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indice BMI',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'BODY MASS INDEX',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bmi != null ? bmi.toStringAsFixed(1) : '--',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: categoryColor,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── CARDIO HISTORY ────────────────────────────────────────────────────────

class _CardioHistorySection extends StatelessWidget {
  const _CardioHistorySection({required this.state});
  final TrainingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<CardioSessionEntity> sessions = state is TrainingLoaded ? (state as TrainingLoaded).cardioSessions : <CardioSessionEntity>[];
    
    // Sort by date newest first
    sessions = List<CardioSessionEntity>.from(sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final displaySessions = sessions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0xFFFF9494), Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'RECENTI CARDIO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11,
                  ),
                ),
              ],
            ),
            if (sessions.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/analytics/cardio-history'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('GUARDA TUTTE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 0.5)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: theme.colorScheme.primary),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Nessuna sessione registrata',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          )
        else
          ...displaySessions.map((session) => _CompactCardioCard(session: session)),
      ],
    );
  }
}

class _CompactCardioCard extends StatelessWidget {
  const _CompactCardioCard({required this.session});
  final CardioSessionEntity session;

  String _formatDate(DateTime date) {
    final months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = session.type == 'run';
    final accentColor = isRun ? theme.colorScheme.primary : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isRun ? Icons.directions_run : Icons.directions_walk, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRun ? 'Corsa' : 'Camminata', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 13)),
                Text(_formatDate(session.date), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${session.distance.toStringAsFixed(2)} km', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Lexend')),
              Text('${session.calories} kcal', style: TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}


class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.theme});
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: theme.colorScheme.outline)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
      ],
    );
  }
}
