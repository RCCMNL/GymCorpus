import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/service_locator.dart' as di;
import 'package:gym_corpus/core/services/health_service.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/app_card.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/core/widgets/skeleton.dart';

/// Card riepilogo attività giornaliera con passi, km, tempo, kcal
/// e grafico a barre settimanale.
class DailyStepsSection extends StatefulWidget {
  const DailyStepsSection({super.key});

  @override
  State<DailyStepsSection> createState() => _DailyStepsSectionState();
}

class _DailyStepsSectionState extends State<DailyStepsSection> {
  final HealthService _healthService = di.sl<HealthService>();
  List<DailyActivity>? _weeklyData;
  DailyActivity? _today;
  bool _isLoading = true;
  bool _permissionDenied = false;
  static const int _dailyGoal = 10000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      debugPrint('[DailyStepsSection] Controllo permessi...');
      final hasPermission = await _healthService.checkPermissions();

      if (!hasPermission) {
        debugPrint('[DailyStepsSection] Richiesta permessi in corso...');
        final granted = await _healthService.requestPermissions();

        if (!granted) {
          debugPrint("[DailyStepsSection] Permessi negati dall'utente.");
          if (mounted) {
            setState(() {
              _isLoading = false;
              _permissionDenied = true;
            });
            AppSnackBar.showWarning(
              context,
              'Permessi salute necessari per visualizzare i passi.',
            );
          }
          return;
        }
      }

      debugPrint('[DailyStepsSection] Caricamento dati settimanali...');
      final weekly = await _healthService.getWeeklyActivity();

      if (mounted) {
        setState(() {
          _weeklyData = weekly;
          _today = weekly.isNotEmpty ? weekly.last : null;
          _isLoading = false;
          _permissionDenied = false;
        });
      }
    } catch (e) {
      debugPrint('[DailyStepsSection] Errore critico: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });
        AppSnackBar.showError(context, 'Errore: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            const AccentBar(height: 20),
            const SizedBox(width: 12),
            const SectionTitle(
              'ATTIVITÀ GIORNALIERA',
              tone: SectionTitleTone.muted,
            ),
            const Spacer(),
            if (!_isLoading && !_permissionDenied)
              IconButton(
                onPressed: _loadData,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Main Content
        if (_isLoading)
          _buildLoadingState()
        else if (_permissionDenied)
          _buildPermissionBanner(theme)
        else
          _buildActivityContent(theme),
      ],
    );
  }

  Widget _buildLoadingState() {
    // La forma di quello che arriva: l'anello dei passi a sinistra, le
    // tre misure a destra, il grafico della settimana sotto.
    return const AppCard(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 72, height: 72, radius: AppRadius.pill),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 16),
                      SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: SkeletonBox(),
                      ),
                      SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: 0.45,
                        child: SkeletonBox(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SkeletonBox(height: 90, radius: AppRadius.md),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionBanner(ThemeData theme) {
    return GestureDetector(
      onTap: _loadData,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppPalette.mint.withValues(alpha: 0.08),
              AppPalette.mint.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppPalette.mint.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const IconBadge(
              Icons.directions_walk_rounded,
              color: AppPalette.mint,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attiva il contapassi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Collega Google Fit o Apple Health per visualizzare '
                    'passi, distanza e calorie.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppPalette.mint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityContent(ThemeData theme) {
    final today = _today;
    if (today == null) return const SizedBox.shrink();

    final progress = (today.steps / _dailyGoal).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => context.push('/analytics/daily-activity'),
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Steps ring
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: AppPalette.mint.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: const AlwaysStoppedAnimation(
                            AppPalette.mint,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.directions_walk_rounded,
                            size: 18,
                            color: AppPalette.mint,
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: AppPalette.mint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Steps count + metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        today.steps.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]}.',
                        ),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Lexend',
                          fontSize: 28,
                        ),
                      ),
                      Text(
                        'passi oggi · obiettivo ${_dailyGoal ~/ 1000}k',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MiniMetric(
                            icon: Icons.straighten_rounded,
                            value: today.formattedDistance,
                            color: AppPalette.blue,
                          ),
                          const SizedBox(width: 16),
                          _MiniMetric(
                            icon: Icons.timer_outlined,
                            value: today.formattedActiveTime,
                            color: AppPalette.gold,
                          ),
                          const SizedBox(width: 16),
                          _MiniMetric(
                            icon: Icons.local_fire_department_rounded,
                            value: '${today.caloriesBurned.round()}',
                            color: AppPalette.coral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Weekly Chart
            if (_weeklyData != null && _weeklyData!.isNotEmpty)
              _WeeklyStepsChart(data: _weeklyData!, dailyGoal: _dailyGoal),
          ],
        ),
      ),
    );
  }
}

// ─── MINI METRIC ────────────────────────────────────────────────────────────

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lexend',
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── WEEKLY STEPS CHART ─────────────────────────────────────────────────────

class _WeeklyStepsChart extends StatelessWidget {
  const _WeeklyStepsChart({required this.data, required this.dailyGoal});

  final List<DailyActivity> data;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSteps = data.fold<int>(0, (m, d) => d.steps > m ? d.steps : m);
    final chartMax = (maxSteps > dailyGoal ? maxSteps : dailyGoal) * 1.15;

    final dayNames = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ULTIMI 7 GIORNI',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                fontSize: 9,
                color: theme.colorScheme.outline,
              ),
            ),
            Text(
              'media: ${_average()} passi',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: BarChart(
            BarChartData(
              maxY: chartMax,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: AppRadius.sm,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final activity = data[group.x];
                    return BarTooltipItem(
                      '${activity.steps} passi',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        fontFamily: 'Lexend',
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final weekday = data[index].date.weekday;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dayNames[weekday - 1],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: dailyGoal.toDouble(),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppPalette.mint.withValues(alpha: 0.2),
                  strokeWidth: 1,
                  dashArray: [6, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                final isToday = index == data.length - 1;
                final reachedGoal = activity.steps >= dailyGoal;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: activity.steps.toDouble(),
                      width: 24,
                      borderRadius: AppRadius.xs,
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        // Obiettivo raggiunto: menta piena. Oggi, ma non
                        // ancora raggiunto: la stessa menta smorzata, che
                        // si legge come "ci siamo quasi" invece che come
                        // un altro colore.
                        colors: reachedGoal
                            ? [
                                AppPalette.mint.withValues(alpha: 0.5),
                                AppPalette.mint,
                              ]
                            : isToday
                            ? [
                                AppPalette.mint.withValues(alpha: 0.25),
                                AppPalette.mint.withValues(alpha: 0.65),
                              ]
                            : [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _average() {
    if (data.isEmpty) return '0';
    final avg = data.fold<int>(0, (s, d) => s + d.steps) ~/ data.length;
    if (avg < 1000) return avg.toString();
    return '${(avg / 1000).toStringAsFixed(1)}k';
  }
}
