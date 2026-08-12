import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/service_locator.dart' as di;
import 'package:gym_corpus/core/services/health_service.dart';
import 'package:intl/intl.dart';

class DailyActivityScreen extends StatefulWidget {
  const DailyActivityScreen({super.key});

  @override
  State<DailyActivityScreen> createState() => _DailyActivityScreenState();
}

class _DailyActivityScreenState extends State<DailyActivityScreen> {
  final HealthService _healthService = di.sl<HealthService>();
  List<DailyActivity>? _weeklyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (!_healthService.isAuthorized) {
      final alreadyGranted = await _healthService.checkPermissions();
      if (!alreadyGranted) {
        // Senza questa richiesta, chi arriva qui senza essere passato dalla
        // scheda Analytics vedeva "nessun dato" invece del prompt di sistema.
        await _healthService.requestPermissions();
      }
    }

    final data = await _healthService.getWeeklyActivity(days: 30); // Ultimi 30 giorni per lo storico
    if (mounted) {
      setState(() {
        _weeklyData = data.reversed.toList(); // Più recenti prima
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Dettaglio Attività',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontFamily: 'Lexend',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : _weeklyData == null || _weeklyData!.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _weeklyData!.length,
                  itemBuilder: (context, index) {
                    final activity = _weeklyData![index];
                    return _ActivityDayCard(activity: activity);
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk_rounded, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Nessun dato disponibile',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDayCard extends StatelessWidget {
  const _ActivityDayCard({required this.activity});

  final DailyActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateFormat('yyyy-MM-dd').format(activity.date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isToday 
              ? Colors.greenAccent.shade400.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.08),
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToday ? 'Oggi' : DateFormat('EEEE d MMM', 'it_IT').format(activity.date).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isToday ? Colors.greenAccent.shade400 : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (activity.steps >= 10000)
                Icon(Icons.emoji_events_rounded, size: 16, color: Colors.amber.shade400),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.formattedSteps,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'passi',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.straighten_rounded,
                value: activity.formattedDistance,
                label: 'Distanza',
                color: Colors.blueAccent,
              ),
              Container(width: 1, height: 30, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              _StatItem(
                icon: Icons.timer_outlined,
                value: activity.formattedActiveTime,
                label: 'Attività',
                color: Colors.orangeAccent,
              ),
              Container(width: 1, height: 30, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${activity.caloriesBurned.round()}',
                label: 'Kcal',
                color: Colors.redAccent,
              ),
            ],
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
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Lexend',
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
