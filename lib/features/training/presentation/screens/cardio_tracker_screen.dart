import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/services/health_service.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:latlong2/latlong.dart';

class CardioTrackerScreen extends StatefulWidget {
  const CardioTrackerScreen({required this.type, super.key});

  final String type; // 'run' or 'walk'

  @override
  State<CardioTrackerScreen> createState() => _CardioTrackerScreenState();
}

/// Sessione cardio interrotta, salvata periodicamente per poterla riprendere
/// dopo una chiusura imprevista dell'app.
///
/// La bozza arriva da JSON scritto da una versione potenzialmente diversa
/// dell'app, o troncato da un crash a meta' scrittura. Interpretarla campo per
/// campo con cast diretti significava far fallire l'intero ripristino per una
/// singola coordinata malformata, quindi ogni valore viene controllato e i
/// punti non validi vengono scartati singolarmente.
class _CardioDraft {
  const _CardioDraft({
    required this.type,
    required this.elapsedSeconds,
    required this.distanceMeters,
    required this.steps,
    required this.startTime,
    required this.route,
  });

  final String type;
  final int elapsedSeconds;
  final double distanceMeters;
  final int steps;
  final DateTime? startTime;
  final List<LatLng> route;

  /// Restituisce `null` se la bozza non e' interpretabile.
  static _CardioDraft? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final route = <LatLng>[];
      final rawRoute = decoded['route'];
      if (rawRoute is List) {
        for (final point in rawRoute) {
          if (point is! Map) continue;
          final lat = point['lat'];
          final lng = point['lng'];
          if (lat is num && lng is num) {
            route.add(LatLng(lat.toDouble(), lng.toDouble()));
          }
        }
      }

      final type = decoded['type'];
      final elapsed = decoded['elapsedSeconds'];
      final distance = decoded['distanceMeters'];
      final steps = decoded['steps'];
      final startTime = decoded['startTime'];

      return _CardioDraft(
        type: type is String ? type : 'run',
        elapsedSeconds: elapsed is num ? elapsed.toInt() : 0,
        distanceMeters: distance is num ? distance.toDouble() : 0,
        steps: steps is num ? steps.toInt() : 0,
        startTime: startTime is String ? DateTime.tryParse(startTime) : null,
        route: route,
      );
    } catch (e) {
      debugPrint('CardioTracker: bozza non interpretabile: $e');
      return null;
    }
  }
}

class _CardioTrackerScreenState extends State<CardioTrackerScreen> {
  final MapController _mapController = MapController();
  final HealthService _healthService = GetIt.I<HealthService>();
  final List<LatLng> _route = [];
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  Timer? _countdownTimer;

  int _elapsedSeconds = 0;
  double _distanceMeters = 0;
  double _currentSpeedKmh = 0;
  int _currentSteps = 0;
  DateTime? _sessionStartTime;
  bool _isTracking = false;
  bool _isPaused = false;
  bool _isSaving = false;
  LatLng? _currentPosition;

  // Professional tracking states
  int _gpsSignalQuality = 2; // 0=Bad, 1=Ok, 2=Good
  int _secondsWithoutMovement = 0;
  bool _autoPaused = false;

  // Countdown state
  int _countdown = 3;
  bool _showCountdown = false;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await _checkDraft();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
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
        _isLocating = false;
      });
      _mapController.move(_currentPosition!, 16);
    }
  }

  Future<void> _checkDraft() async {
    try {
      final db = GetIt.I<AppDatabase>();
      final draftStr = await db.watchSetting('cardio_draft').first;
      if (draftStr == null || draftStr.isEmpty) return;

      // La bozza viene interpretata prima di proporre il ripristino. Prima i
      // campi venivano letti dopo il tap su RIPRENDI: una bozza malformata,
      // per esempio scritta a meta' durante un crash, faceva fallire il
      // parsing a quel punto e la sessione ripartiva da zero senza spiegazioni.
      final draft = _CardioDraft.tryParse(draftStr);
      if (draft == null) {
        await _clearDraft();
        return;
      }

      if (!mounted) return;

      final shouldResume = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Sessione interrotta',
            style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
          ),
          content: Text(
            'Abbiamo trovato una sessione di '
            '${draft.type == 'run' ? 'Corsa' : 'Camminata'} non terminata. '
            'Vuoi riprenderla?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                unawaited(_clearDraft());
                Navigator.pop(ctx, false);
              },
              child: Text(
                'SCARTA',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'RIPRENDI',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (shouldResume != true || !mounted) return;

      setState(() {
        // Riprendendo una bozza la posizione e' gia' nota.
        _isLocating = false;
        _elapsedSeconds = draft.elapsedSeconds;
        _distanceMeters = draft.distanceMeters;
        _currentSteps = draft.steps;
        _sessionStartTime = draft.startTime;
        _route
          ..clear()
          ..addAll(draft.route);
        if (_route.isNotEmpty) {
          _currentPosition = _route.last;
        }
        _isTracking = true;
      });
      _startTracking(resume: true);
    } catch (e) {
      debugPrint('CardioTracker._checkDraft: $e');
    }
  }

  Future<void> _saveDraft() async {
    if (_route.isEmpty) return;
    try {
      final db = GetIt.I<AppDatabase>();
      final draft = {
        'type': widget.type,
        'distanceMeters': _distanceMeters,
        'elapsedSeconds': _elapsedSeconds,
        'steps': _currentSteps,
        'startTime': _sessionStartTime?.toIso8601String(),
        'route': _route
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
      };
      await db.updateSetting('cardio_draft', jsonEncode(draft));
    } catch (e) {
      // Il salvataggio automatico gira ogni 10 secondi: senza log, fallimenti
      // ripetuti di scrittura resterebbero invisibili per tutta la sessione.
      debugPrint('CardioTracker._saveDraft: $e');
    }
  }

  /// Cancella la bozza della sessione in corso.
  ///
  /// Deve restare un metodo async con il proprio try/catch: chiamare
  /// `db.updateSetting` senza await dentro un handler sincrono fa sfuggire
  /// l'errore al blocco catch che lo circonda, perche' viene sollevato dopo
  /// il primo await interno.
  Future<void> _clearDraft() async {
    try {
      final db = GetIt.I<AppDatabase>();
      await db.updateSetting('cardio_draft', '');
    } catch (e) {
      debugPrint('CardioTracker._clearDraft: $e');
    }
  }

  void _runCountdown() {
    setState(() {
      _showCountdown = true;
      _countdown = 3;
    });

    // Conservato in un campo per poterlo annullare in dispose: altrimenti,
    // uscendo dalla schermata durante il conto alla rovescia, il timer
    // sopravvive fino al tick successivo.
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else if (_countdown == 1) {
          _countdown = 0; // Mostrerà "VIA!"
        } else {
          timer.cancel();
          _showCountdown = false;
          _startTracking();
        }
      });
    });
  }

  void _startTracking({bool resume = false}) {
    setState(() {
      _isTracking = true;
      _isPaused = false;
      _autoPaused = false;
      _secondsWithoutMovement = 0;
      _sessionStartTime ??= DateTime.now();
      if (!resume && _currentPosition != null) {
        _route.add(_currentPosition!);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isPaused) return;

      if (_currentSpeedKmh < 1.8) {
        // Meno di 0.5 m/s
        _secondsWithoutMovement++;
      } else {
        _secondsWithoutMovement = 0;
        if (_autoPaused) {
          setState(() => _autoPaused = false); // Riprende automaticamente
        }
      }

      // Auto-pause dopo 30 secondi di inattività
      if (_secondsWithoutMovement > 30 && !_autoPaused) {
        setState(() => _autoPaused = true);
      }

      if (!_autoPaused) {
        setState(() => _elapsedSeconds++);
      }

      // Aggiorna i passi ogni 5 secondi
      if (_elapsedSeconds > 0 &&
          _elapsedSeconds % 5 == 0 &&
          _sessionStartTime != null) {
        if (_healthService.isAuthorized) {
          final steps = await _healthService.getStepsSince(_sessionStartTime!);
          if (mounted) setState(() => _currentSteps = steps);
        }
      }

      // Salva la bozza ogni 10 secondi. Volutamente non attesa: il timer non
      // deve bloccarsi su una scrittura lenta. _saveDraft gestisce e logga
      // i propri errori.
      if (_elapsedSeconds > 0 && _elapsedSeconds % 10 == 0) {
        unawaited(_saveDraft());
      }
    });

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'Tracciamento in corso...',
          notificationTitle: 'GymCorpus',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((pos) {
          if (_isPaused) return;

          // Aggiorna la qualità del segnale
          var signalQuality = 2;
          if (pos.accuracy > 40) {
            signalQuality = 0;
          } else if (pos.accuracy > 20) {
            signalQuality = 1;
          }

          setState(() {
            _gpsSignalQuality = signalQuality;
          });

          // Filtro GPS Drift: Scarta punti troppo imprecisi (rimbalzi)
          if (pos.accuracy > 20) return;

          final newPoint = LatLng(pos.latitude, pos.longitude);

          setState(() {
            if (_route.isNotEmpty) {
              final dist = const Distance().as(
                LengthUnit.Meter,
                _route.last,
                newPoint,
              );

              // Anti-drift avanzato (Filtro cinetico):
              // Con aggiornamenti ravvicinati, uno sbalzo > 35m significa una velocità
              // impossibile per un umano (> 60 km/h). Indica che il GPS ha "rimbalzato" lontano.
              if (dist > 35.0) return;

              _distanceMeters += dist;
              _route.add(newPoint);
            } else {
              _route.add(newPoint);
            }

            _currentPosition = newPoint;
            _currentSpeedKmh = pos.speed * 3.6; // m/s -> km/h
            if (_currentSpeedKmh < 0) _currentSpeedKmh = 0;
          });
          _mapController.move(newPoint, 16);
        });
  }

  void _pauseTracking() {
    setState(() {
      _isPaused = true;
      _autoPaused = false; // Override manuale
    });
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
      _autoPaused = false;
      _secondsWithoutMovement = 0;
    });
  }

  Future<void> _stopAndSave() async {
    setState(() => _isSaving = true);
    _timer?.cancel();
    await _positionStream?.cancel();

    await _clearDraft();

    final distKm = _distanceMeters / 1000;
    final avgSpeed = _elapsedSeconds > 0
        ? (distKm / (_elapsedSeconds / 3600))
        : 0.0;

    // Pace: minutes per km
    var pace = '--:--';
    if (distKm > 0) {
      final paceMinutes = (_elapsedSeconds / 60) / distKm;
      final pMins = paceMinutes.floor();
      final pSecs = ((paceMinutes - pMins) * 60).round();
      pace =
          '${pMins.toString().padLeft(2, '0')}:${pSecs.toString().padLeft(2, '0')}';
    }

    // MET-based calorie estimation
    final userWeight = _getUserWeight();
    final metValue = widget.type == 'run' ? 9.8 : 3.8;
    final calories = (metValue * userWeight * (_elapsedSeconds / 3600)).round();

    // Route JSON
    final routeJson = jsonEncode(
      _route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    );

    if (mounted) {
      context.read<TrainingBloc>().add(
        SaveCardioSessionEvent(
          type: widget.type,
          distance: double.parse(distKm.toStringAsFixed(2)),
          duration: _elapsedSeconds,
          avgSpeed: double.parse(avgSpeed.toStringAsFixed(1)),
          pace: pace,
          calories: calories,
          steps: _currentSteps,
          routeJson: routeJson,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop();
    }
  }

  double _getUserWeight() {
    final trainingState = context.read<TrainingBloc>().state;
    if (trainingState is TrainingLoaded &&
        trainingState.bodyWeightLogs.isNotEmpty) {
      return trainingState.bodyWeightLogs.first.weight;
    }

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
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = widget.type == 'run';
    final distKm = _distanceMeters / 1000;

    return PopScope(
      canPop: !_isTracking || _isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentPosition ??
                    const LatLng(41.9028, 12.4964), // Roma default
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
                        color: isRun
                            ? theme.colorScheme.primary
                            : Colors.orangeAccent,
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
                            color: isRun
                                ? theme.colorScheme.primary
                                : Colors.orangeAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isRun
                                            ? theme.colorScheme.primary
                                            : Colors.orangeAccent)
                                        .withValues(alpha: 0.4),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Top Right Controls (GPS + OSM)
            if (!_isLocating)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isTracking)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.85,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _gpsSignalQuality == 2
                                  ? Icons.signal_cellular_4_bar
                                  : _gpsSignalQuality == 1
                                  ? Icons.signal_cellular_alt
                                  : Icons
                                        .signal_cellular_connected_no_internet_0_bar,
                              size: 14,
                              color: _gpsSignalQuality == 2
                                  ? Colors.green
                                  : _gpsSignalQuality == 1
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _gpsSignalQuality == 2
                                  ? 'GPS OTTIMO'
                                  : _gpsSignalQuality == 1
                                  ? 'GPS DEBOLE'
                                  : 'GPS PERSO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '© OpenStreetMap',
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Stats Panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      32,
                      24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Activity Type Label
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isRun
                                      ? [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.tertiary,
                                        ]
                                      : [
                                          Colors.orangeAccent,
                                          Colors.deepOrange,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isRun ? 'CORSA' : 'CAMMINATA',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                fontSize: 10,
                                color: isRun
                                    ? theme.colorScheme.primary
                                    : Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Main Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatColumn(
                              label: 'DISTANZA',
                              value: '${distKm.toStringAsFixed(2)} km',
                              theme: theme,
                            ),
                            _StatColumn(
                              label: 'DURATA',
                              value: _formatDuration(_elapsedSeconds),
                              theme: theme,
                            ),
                            _StatColumn(
                              label: 'VEL. MEDIA',
                              value:
                                  '${(_elapsedSeconds > 0 ? (distKm / (_elapsedSeconds / 3600)) : 0).toStringAsFixed(1)} km/h',
                              theme: theme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatColumn(
                              label: 'VELOCITÀ',
                              value:
                                  '${_currentSpeedKmh.toStringAsFixed(1)} km/h',
                              theme: theme,
                            ),
                            _StatColumn(
                              label: 'PASSI',
                              value: '$_currentSteps',
                              theme: theme,
                            ),
                            _StatColumn(
                              label: 'CALORIE',
                              value:
                                  '${(_getUserWeight() * (widget.type == "run" ? 9.8 : 3.8) * (_elapsedSeconds / 3600)).round()} kcal',
                              theme: theme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Controls
                        if (!_isTracking && !_isLocating)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _runCountdown,
                              icon: Icon(
                                isRun
                                    ? Icons.directions_run
                                    : Icons.directions_walk,
                              ),
                              label: Text(
                                'INIZIA ${isRun ? "CORSA" : "CAMMINATA"}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRun
                                    ? theme.colorScheme.primary
                                    : Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isPaused
                                      ? _resumeTracking
                                      : _pauseTracking,
                                  icon: Icon(
                                    _isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                  ),
                                  label: Text(
                                    _isPaused ? 'RIPRENDI' : 'PAUSA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.surfaceContainerHigh,
                                    foregroundColor:
                                        theme.colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _stopAndSave,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.stop_rounded),
                                  label: Text(
                                    _isSaving ? 'SALVO...' : 'FINE',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
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
              ),
            ),

            // Loading Overlay (Ricerca GPS)
            if (_isLocating)
              Positioned.fill(
                child: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'RICERCA SEGNALE GPS...',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Resta all'aperto per una migliore precisione",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Countdown Overlay
            if (_showCountdown)
              Positioned.fill(
                child: ColoredBox(
                  color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        _countdown > 0 ? '$_countdown' : 'VIA!',
                        key: ValueKey<int>(_countdown),
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Manual Pause Overlay (Explicit)
            if (_isPaused && !_isLocating && !_showCountdown)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_circle_filled_rounded,
                            size: 100,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'SESSIONE IN PAUSA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lexend',
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _resumeTracking,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('RIPRENDI'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Auto Pause Overlay (Moved to end to ensure it covers UI)
            if (_autoPaused && !_isPaused)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _autoPaused = false;
                      _secondsWithoutMovement = 0;
                    });
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: ColoredBox(
                      color: theme.colorScheme.surface.withValues(alpha: 0.4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 36,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.motion_photos_paused_rounded,
                                  size: 56,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'IN PAUSA',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Lexend',
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rilevato stop.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'TOCCA PER RIPRENDERE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
        title: const Text(
          'Interrompere la sessione?',
          style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
        ),
        content: const Text('I dati non salvati andranno persi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ANNULLA',
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _timer?.cancel();
              _positionStream?.cancel();

              // Elimina la bozza se l'utente interrompe intenzionalmente
              unawaited(_clearDraft());

              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text(
              'INTERROMPI',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
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
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontFamily: 'Lexend',
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
