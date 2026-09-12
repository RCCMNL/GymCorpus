import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gym_corpus/core/utils/date_format.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/analytics/presentation/widgets/cardio_splits_section.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_splits.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_activity_style.dart';
import 'package:latlong2/latlong.dart';

/// Dettaglio di una sessione cardio: percorso, metriche e passaggi al
/// chilometro.
///
/// Prima lo storico mostrava solo una card espandibile con una mini mappa:
/// il percorso era illeggibile e gli split non esistevano.
class CardioSessionDetailScreen extends StatelessWidget {
  const CardioSessionDetailScreen({required this.session, super.key});

  final CardioSessionEntity session;

  CardioActivity get _activity => CardioActivity.fromId(session.type);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _activity.accent(theme);
    final points = CardioRoutePoint.decode(session.routeJson ?? '');
    final splits = CardioSplits.fromRoute(points);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(title: 'Dettaglio sessione'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_activity.icon, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activity.label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      Text(
                        formatDateAtTime(session.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (session.goal != null) ...[
              const SizedBox(height: 16),
              _GoalOutcome(session: session, accent: accent),
            ],
            const SizedBox(height: 20),
            if (points.length > 1) ...[
              _RouteMap(points: points, accent: accent),
              const SizedBox(height: 20),
            ],
            _MetricsGrid(session: session, accent: accent),
            const SizedBox(height: 28),
            Text(
              'PASSAGGI AL CHILOMETRO',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            CardioSplitsSection(splits: splits),
            if (splits.length > 1) ...[
              const SizedBox(height: 28),
              Text(
                'ANDAMENTO DEL PASSO',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              _PaceChart(splits: splits, accent: accent),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.points, required this.accent});

  final List<CardioRoutePoint> points;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final positions = points.map((p) => p.position).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: positions,
              padding: const EdgeInsets.all(40),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gymcorpus.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(points: positions, color: accent, strokeWidth: 5),
              ],
            ),
            MarkerLayer(
              markers: [
                _endpoint(positions.first, Colors.white, accent),
                _endpoint(positions.last, accent, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _endpoint(LatLng point, Color fill, Color border) => Marker(
    point: point,
    width: 18,
    height: 18,
    child: Container(
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 3),
      ),
    ),
  );
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.session, required this.accent});

  final CardioSessionEntity session;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final steps = session.steps;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricTile(
          label: 'DISTANZA',
          value: '${session.distance.toStringAsFixed(2)} km',
          accent: accent,
        ),
        _MetricTile(
          label: 'DURATA',
          value: formatClock(session.duration),
          accent: accent,
        ),
        _MetricTile(
          label: 'PASSO MEDIO',
          value: '${session.pace} /km',
          accent: accent,
        ),
        _MetricTile(
          label: 'CALORIE',
          value: '${session.calories} kcal',
          accent: accent,
        ),
        if (steps != null)
          _MetricTile(label: 'PASSI', value: '$steps', accent: accent),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = (MediaQuery.of(context).size.width - 52) / 2;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Passo per chilometro: l'asse e' rovesciato, cosi' un picco verso l'alto
/// significa "piu' veloce" invece di "piu' secondi".
class _PaceChart extends StatelessWidget {
  const _PaceChart({required this.splits, required this.accent});

  final List<CardioSplit> splits;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = [
      for (final split in splits)
        FlSpot(
          split.index.toDouble(),
          split.distanceKm <= 0 ? 0 : (split.seconds / split.distanceKm) / 60,
        ),
    ];

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accent,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: accent.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Esito dell'obiettivo scelto prima della sessione.
class _GoalOutcome extends StatelessWidget {
  const _GoalOutcome({required this.session, required this.accent});

  final CardioSessionEntity session;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = session.goal!;
    final reached = goal.isReached(
      distanceKm: session.distance,
      seconds: session.duration,
      calories: session.calories,
    );
    final color = reached ? accent : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            reached ? Icons.emoji_events_rounded : Icons.flag_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Obiettivo ${goal.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            reached ? 'Raggiunto' : 'Non raggiunto',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
