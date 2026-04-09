import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:latlong2/latlong.dart';

class CardioTrackerScreen extends StatefulWidget {
  const CardioTrackerScreen({required this.type, super.key});

  final String type; // 'run' or 'walk'

  @override
  State<CardioTrackerScreen> createState() => _CardioTrackerScreenState();
}

class _CardioTrackerScreenState extends State<CardioTrackerScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _route = [];
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;

  int _elapsedSeconds = 0;
  double _distanceMeters = 0;
  double _currentSpeedKmh = 0;
  bool _isTracking = false;
  bool _isPaused = false;
  bool _isSaving = false;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
      if (_currentPosition != null) {
        _route.add(_currentPosition!);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) setState(() => _elapsedSeconds++);
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      if (_isPaused) return;
      final newPoint = LatLng(pos.latitude, pos.longitude);
      setState(() {
        if (_route.isNotEmpty) {
          final dist = const Distance().as(LengthUnit.Meter, _route.last, newPoint);
          _distanceMeters += dist;
        }
        _route.add(newPoint);
        _currentPosition = newPoint;
        _currentSpeedKmh = pos.speed * 3.6; // m/s -> km/h
        if (_currentSpeedKmh < 0) _currentSpeedKmh = 0;
      });
      _mapController.move(newPoint, 16);
    });
  }

  void _pauseTracking() {
    setState(() => _isPaused = true);
  }

  void _resumeTracking() {
    setState(() => _isPaused = false);
  }

  Future<void> _stopAndSave() async {
    setState(() => _isSaving = true);
    _timer?.cancel();
    await _positionStream?.cancel();

    final distKm = _distanceMeters / 1000;
    final avgSpeed = _elapsedSeconds > 0 ? (distKm / (_elapsedSeconds / 3600)) : 0.0;
    
    // Pace: minutes per km
    String pace = '--:--';
    if (distKm > 0) {
      final paceMinutes = (_elapsedSeconds / 60) / distKm;
      final pMins = paceMinutes.floor();
      final pSecs = ((paceMinutes - pMins) * 60).round();
      pace = '${pMins.toString().padLeft(2, '0')}:${pSecs.toString().padLeft(2, '0')}';
    }

    // MET-based calorie estimation
    final userWeight = _getUserWeight();
    final metValue = widget.type == 'run' ? 9.8 : 3.8;
    final calories = (metValue * userWeight * (_elapsedSeconds / 3600)).round();

    // Route JSON
    final routeJson = jsonEncode(_route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList());

    if (mounted) {
      context.read<TrainingBloc>().add(SaveCardioSessionEvent(
        type: widget.type,
        distance: double.parse(distKm.toStringAsFixed(2)),
        duration: _elapsedSeconds,
        avgSpeed: double.parse(avgSpeed.toStringAsFixed(1)),
        pace: pace,
        calories: calories,
        routeJson: routeJson,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop();
    }
  }

  double _getUserWeight() {
    final authState = context.read<AuthBloc>().state;
    return authState.maybeWhen(
      authenticated: (user) => user.weight ?? 70.0,
      orElse: () => 70.0,
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = widget.type == 'run';
    final distKm = _distanceMeters / 1000;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(41.9028, 12.4964), // Roma default
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gymcorpus.app',
              ),
              if (_route.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route,
                      color: isRun ? theme.colorScheme.primary : Colors.orangeAccent,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRun ? theme.colorScheme.primary : Colors.orangeAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: (isRun ? theme.colorScheme.primary : Colors.orangeAccent).withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () {
                if (_isTracking) {
                  _showExitConfirmation();
                } else {
                  context.pop();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10)],
                ),
                child: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.colorScheme.onSurface),
              ),
            ),
          ),

          // OSM Attribution
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '© OpenStreetMap',
                style: TextStyle(fontSize: 9, color: theme.colorScheme.outline),
              ),
            ),
          ),

          // Bottom Stats Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, -8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Activity Type Label
                  Row(
                    children: [
                      Container(
                        width: 4, height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: isRun
                              ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
                              : [Colors.orangeAccent, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isRun ? 'CORSA' : 'CAMMINATA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10,
                          color: isRun ? theme.colorScheme.primary : Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Main Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(label: 'DISTANZA', value: '${distKm.toStringAsFixed(2)} km', theme: theme),
                      _StatColumn(label: 'DURATA', value: _formatDuration(_elapsedSeconds), theme: theme),
                      _StatColumn(label: 'VEL. MEDIA', value: '${(_elapsedSeconds > 0 ? (distKm / (_elapsedSeconds / 3600)) : 0).toStringAsFixed(1)} km/h', theme: theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(label: 'VELOCITÀ', value: '${_currentSpeedKmh.toStringAsFixed(1)} km/h', theme: theme),
                      _StatColumn(label: 'CALORIE', value: '${(_getUserWeight() * (widget.type == "run" ? 9.8 : 3.8) * (_elapsedSeconds / 3600)).round()} kcal', theme: theme),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Controls
                  if (!_isTracking)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startTracking,
                        icon: Icon(isRun ? Icons.directions_run : Icons.directions_walk),
                        label: Text(
                          'INIZIA ${isRun ? "CORSA" : "CAMMINATA"}',
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRun ? theme.colorScheme.primary : Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPaused ? _resumeTracking : _pauseTracking,
                            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                            label: Text(
                              _isPaused ? 'RIPRENDI' : 'PAUSA',
                              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.surfaceContainerHigh,
                              foregroundColor: theme.colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _stopAndSave,
                            icon: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.stop_rounded),
                            label: Text(
                              _isSaving ? 'SALVO...' : 'FINE',
                              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Interrompere la sessione?', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
        content: const Text('I dati non salvati andranno persi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ANNULLA', style: TextStyle(color: theme.colorScheme.outline, fontWeight: FontWeight.w900)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _timer?.cancel();
              _positionStream?.cancel();
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('INTERROMPI', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value, required this.theme});

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 9,
        )),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 16,
        )),
      ],
    );
  }
}
