import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

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
      ..add(LoadBodyWeightLogsEvent());
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

            if (state is TrainingLoaded) {
              final logs = state.weightLogs;
              sessionsCount = logs.map((e) => e.workoutId).toSet().length;
              totalWeight = logs.fold(0, (sum, e) => sum + (e.weight * e.reps));

              final now = DateTime.now();
              final monthLogs = logs
                  .where((e) =>
                      e.timestamp.month == now.month &&
                      e.timestamp.year == now.year,
                  )
                  .toList();
              monthSessions = monthLogs.map((e) => e.workoutId).toSet().length;
              monthWeight = monthLogs.fold(0, (sum, e) => sum + (e.weight * e.reps));
            }

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
                  const SizedBox(height: 32),

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
                        value: '${(totalWeight / 1000).toStringAsFixed(1)}k',
                        label: 'Volume (kg)',
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
                        value: '${(monthWeight / 1000).toStringAsFixed(1)}k',
                        label: 'Volume (kg)',
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

        if (state is TrainingLoaded && state.bodyWeightLogs.isNotEmpty) {
          final logs = state.bodyWeightLogs;
          current = logs.first.weight.toStringAsFixed(1);
          max = logs.map((e) => e.weight).reduce((a, b) => a > b ? a : b).toStringAsFixed(1);
          min = logs.map((e) => e.weight).reduce((a, b) => a < b ? a : b).toStringAsFixed(1);
          trendPoints = logs.map((e) => e.weight).toList().reversed.toList();
        }

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
                  _WeightItem(label: 'Current', value: current, unit: 'kg', color: theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                  _WeightItem(label: 'Maximum', value: max, unit: 'kg', color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  _WeightItem(label: 'Minimum', value: min, unit: 'kg', color: theme.colorScheme.tertiary),
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Body Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null) {
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

class _BMICard extends StatelessWidget {
  const _BMICard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.person_search, color: theme.colorScheme.tertiary),
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
                '23.4',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.tertiary,
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
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'NORMAL',
                    style: TextStyle(
                      color: theme.colorScheme.tertiary,
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
  }
}
