import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// Card dettagliata di una sessione cardio: metriche, chip di andatura e
/// mappa del percorso espandibile.
class DetailedCardioCard extends StatefulWidget {
  const DetailedCardioCard({
    required this.session,
    required this.accentColor,
    super.key,
  });

  final CardioSessionEntity session;
  final Color accentColor;

  @override
  State<DetailedCardioCard> createState() => _DetailedCardioCardState();
}

class _DetailedCardioCardState extends State<DetailedCardioCard> {
  bool _showMap = false;

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'it_IT').format(date);
  }

  String _formatDuration(int durationInSeconds) {
    final durationMins = durationInSeconds ~/ 60;
    final durationSecs = durationInSeconds % 60;

    if (durationMins > 59) {
      return '${durationMins ~/ 60}h ${durationMins % 60}m';
    }

    return '${durationMins}m ${durationSecs}s';
  }

  List<LatLng> _parseRoute(String? routeJson) {
    if (routeJson == null || routeJson.isEmpty) {
      return <LatLng>[];
    }

    try {
      final decoded = jsonDecode(routeJson) as List;
      return decoded.map((point) {
        final map = point as Map;
        return LatLng(
          (map['lat'] as num).toDouble(),
          (map['lng'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('CardioHistoryScreen route parse error: $e');
      return <LatLng>[];
    }
  }

  LatLngBounds? _buildBounds(List<LatLng> route) {
    if (route.length < 2) return null;

    try {
      return LatLngBounds.fromPoints(route);
    } catch (e) {
      debugPrint('CardioHistoryScreen route bounds error: $e');
      return null;
    }
  }

  void _openFullMap({
    required BuildContext context,
    required List<LatLng> route,
    required Color color,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final bounds = _buildBounds(route);

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DETTAGLIO PERCORSO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                        Text(
                          _formatDate(widget.session.date),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: route.isEmpty
                        ? const Center(child: Text('Mappa non disponibile'))
                        : FlutterMap(
                            options: MapOptions(
                              initialCenter: route.length > 1
                                  ? route[route.length ~/ 2]
                                  : route[0],
                              initialZoom: 15,
                              initialCameraFit:
                                  route.length > 1 && bounds != null
                                  ? CameraFit.bounds(
                                      bounds: bounds,
                                      padding: const EdgeInsets.all(40),
                                    )
                                  : null,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.gymcorpus.app',
                              ),
                              if (route.length > 1)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: route,
                                      color: color,
                                      strokeWidth: 5,
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: route.first,
                                    width: 32,
                                    height: 32,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                  ),
                                  if (route.length > 1)
                                    Marker(
                                      point: route.last,
                                      width: 32,
                                      height: 32,
                                      child: const Icon(
                                        Icons.flag,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = widget.session;
    final accentColor = session.type == 'run'
        ? theme.colorScheme.primary
        : Colors.orangeAccent;
    final route = _parseRoute(session.routeJson);
    final bounds = _buildBounds(route);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  session.type == 'run'
                      ? Icons.directions_run_rounded
                      : Icons.directions_walk_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.type == 'run' ? 'Corsa' : 'Camminata',
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
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${session.calories} kcal',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
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
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(
                  label: 'Durata',
                  value: _formatDuration(session.duration),
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(
                  label: 'Velocita',
                  value: '${session.avgSpeed.toStringAsFixed(1)} km/h',
                  accentColor: accentColor,
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
                accentColor: accentColor,
              ),
              const SizedBox(width: 8),
              if (route.isNotEmpty)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showMap = !_showMap),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'MAPPA',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                          Icon(
                            _showMap ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: theme.colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ChipMetric(
                  icon: Icons.place_outlined,
                  text: 'Mappa assente',
                  accentColor: theme.colorScheme.outline,
                ),
            ],
          ),
          if (route.isNotEmpty) ...[
            const SizedBox(height: 14),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InkWell(
                  onTap: () => _openFullMap(
                    context: context,
                    route: route,
                    color: accentColor,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 170,
                          width: double.infinity,
                          child: IgnorePointer(
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: route.length > 1
                                    ? route[route.length ~/ 2]
                                    : route[0],
                                initialZoom: 14,
                                initialCameraFit:
                                    route.length > 1 && bounds != null
                                    ? CameraFit.bounds(
                                        bounds: bounds,
                                        padding: const EdgeInsets.all(12),
                                      )
                                    : null,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.gymcorpus.app',
                                ),
                                if (route.length > 1)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: route,
                                        color: accentColor,
                                        strokeWidth: 4,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.86,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 13,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Apri percorso',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: _showMap
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ],
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

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
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
          borderRadius: BorderRadius.circular(14),
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
