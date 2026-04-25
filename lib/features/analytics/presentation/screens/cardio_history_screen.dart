import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:latlong2/latlong.dart' hide Path;

class CardioHistoryScreen extends StatelessWidget {
  const CardioHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(
        title: 'CRONOLOGIA CARDIO',
      ),
      body: BlocBuilder<TrainingBloc, TrainingState>(
        builder: (context, state) {
          final sessions = state is TrainingLoaded
              ? state.cardioSessions
              : <CardioSessionEntity>[];

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_run_outlined,
                    size: 64,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ancora nessuna sessione',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          // Sort sessions by date (newest first)
          final sortedSessions = List<CardioSessionEntity>.from(sessions)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: sortedSessions.length,
            itemBuilder: (context, index) {
              return _DetailedCardioCard(session: sortedSessions[index]);
            },
          );
        },
      ),
    );
  }
}

class _DetailedCardioCard extends StatelessWidget {
  const _DetailedCardioCard({required this.session});
  final CardioSessionEntity session;

  String _formatDate(DateTime date) {
    final months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = session.type == 'run';
    final accentColor = isRun ? theme.colorScheme.primary : Colors.orangeAccent;

    final durationMins = session.duration ~/ 60;
    final durationSecs = session.duration % 60;
    final durationStr = durationMins > 59
        ? '${durationMins ~/ 60}h ${durationMins % 60}m'
        : '${durationMins}m ${durationSecs}s';

    var route = <LatLng>[];
    if (session.routeJson != null && session.routeJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(session.routeJson!) as List;
        route = decoded.map((p) {
          final map = p as Map;
          return LatLng(
            (map['lat'] as num).toDouble(),
            (map['lng'] as num).toDouble(),
          );
        }).toList();
      } catch (_) {}
    }

    LatLngBounds? bounds;
    if (route.length >= 2) {
      try {
        bounds = LatLngBounds.fromPoints(route);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () => _openFullMap(context, route, accentColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isRun ? Icons.directions_run : Icons.directions_walk,
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRun ? 'Corsa' : 'Camminata',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        Text(
                          _formatDate(session.date),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'DISTANZA',
                  value: '${session.distance.toStringAsFixed(2)} km',
                  theme: theme,
                ),
                _StatItem(label: 'DURATA', value: durationStr, theme: theme),
                _StatItem(
                  label: 'VELOCITÀ',
                  value: '${session.avgSpeed.toStringAsFixed(1)} km/h',
                  theme: theme,
                ),
              ],
            ),
            if (route.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: route.length > 1
                            ? route[route.length ~/ 2]
                            : route[0],
                        initialZoom: 14,
                        initialCameraFit: route.length > 1 && bounds != null
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
                          PolylineLayer(polylines: [
                            Polyline(
                              points: route,
                              color: accentColor,
                              strokeWidth: 4,
                            ),
                          ],),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '© OpenStreetMap',
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openFullMap(BuildContext context, List<LatLng> route, Color color) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        LatLngBounds? bounds;
        if (route.length >= 2) {
          try {
            bounds = LatLngBounds.fromPoints(route);
          } catch (_) {}
        }

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
                            _formatDate(session.date),
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
                      child: route.isNotEmpty
                          ? FlutterMap(
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
                                  PolylineLayer(polylines: [
                                    Polyline(
                                      points: route,
                                      color: color,
                                      strokeWidth: 5,
                                    ),
                                  ],),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: route[0],
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
                            )
                          : const Center(child: Text('Mappa non disponibile')),
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
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
  });
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
