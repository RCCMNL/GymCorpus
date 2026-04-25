import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:latlong2/latlong.dart' hide Path;

class CardioHistoryScreen extends StatefulWidget {
  const CardioHistoryScreen({super.key});

  @override
  State<CardioHistoryScreen> createState() => _CardioHistoryScreenState();
}

class _CardioHistoryScreenState extends State<CardioHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrainingBloc>().add(LoadCardioSessionsEvent());
  }

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

          final sortedSessions = List<CardioSessionEntity>.from(sessions)
            ..sort((a, b) => b.date.compareTo(a.date));

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final recentThreshold = today.subtract(const Duration(days: 7));

          final recentSessions = sortedSessions
              .where((s) => s.date.isAfter(recentThreshold))
              .toList();
          final olderSessions = sortedSessions
              .where((s) => s.date.isBefore(recentThreshold) || s.date.isAtSameMomentAs(recentThreshold))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (recentSessions.isNotEmpty) ...[
                _SectionHeader(
                  title: 'RECENTI',
                  color: theme.colorScheme.primary,
                ),
                ...recentSessions.map((s) => _DismissibleCardioCard(session: s)),
                const SizedBox(height: 24),
              ],
              if (olderSessions.isNotEmpty) ...[
                _SectionHeader(
                  title: 'PRECEDENTI',
                  color: theme.colorScheme.outline,
                ),
                ...olderSessions.map((s) => _DismissibleCardioCard(session: s)),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissibleCardioCard extends StatelessWidget {
  const _DismissibleCardioCard({required this.session});
  final CardioSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('cardio_${session.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: const Text(
              'ELIMINA SESSIONE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            content: const Text(
              'Sei sicuro di voler eliminare definitivamente questa sessione di cardio?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'ANNULLA',
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'ELIMINA',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<TrainingBloc>().add(DeleteCardioSessionEvent(session.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sessione eliminata'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 20),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.redAccent,
        ),
      ),
      child: _DetailedCardioCard(session: session),
    );
  }
}

class _DetailedCardioCard extends StatelessWidget {
  const _DetailedCardioCard({required this.session});
  final CardioSessionEntity session;

  String _formatDate(DateTime date) {
    final months = [
      'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
      'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic',
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
      } catch (e) {
        debugPrint('CardioHistoryScreen route parse error: $e');
      }
    }

    LatLngBounds? bounds;
    if (route.length >= 2) {
      try {
        bounds = LatLngBounds.fromPoints(route);
      } catch (e) {
        debugPrint('CardioHistoryScreen route bounds error: $e');
      }
    }

    return Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _openFullMap(context, route, accentColor),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Apri mappa'),
                ),
              ),
            ],
        ],
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
          } catch (e) {
            debugPrint('CardioHistoryScreen full map bounds error: $e');
          }
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
                              initialCameraFit: route.length > 1 && bounds != null
                                  ? CameraFit.bounds(
                                      bounds: bounds,
                                      padding: const EdgeInsets.all(40),
                                    )
                                  : null,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                    child: const Icon(Icons.location_on, color: Colors.green, size: 32),
                                  ),
                                  if (route.length > 1)
                                    Marker(
                                      point: route.last,
                                      width: 32,
                                      height: 32,
                                      child: const Icon(Icons.flag, color: Colors.red, size: 32),
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
