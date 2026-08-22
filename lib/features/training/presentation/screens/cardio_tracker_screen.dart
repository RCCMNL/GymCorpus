import 'dart:async';
import 'dart:convert';

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
import 'package:gym_corpus/features/training/domain/entities/cardio_draft.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_map_view.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_overlays.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_stats_panel.dart';
import 'package:gym_corpus/features/training/presentation/widgets/gps_status_badge.dart';
import 'package:latlong2/latlong.dart';

class CardioTrackerScreen extends StatefulWidget {
  const CardioTrackerScreen({required this.type, super.key});

  final String type; // 'run' or 'walk'

  @override
  State<CardioTrackerScreen> createState() => _CardioTrackerScreenState();
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
      final draft = CardioDraft.tryParse(draftStr);
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
      final draft = CardioDraft(
        type: widget.type,
        elapsedSeconds: _elapsedSeconds,
        distanceMeters: _distanceMeters,
        steps: _currentSteps,
        startTime: _sessionStartTime,
        route: List<LatLng>.of(_route),
      );
      await db.updateSetting('cardio_draft', draft.encode());
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
            CardioMapView(
              mapController: _mapController,
              currentPosition: _currentPosition,
              route: _route,
              isRun: isRun,
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
                child: GpsStatusBadge(
                  gpsSignalQuality: _gpsSignalQuality,
                  isTracking: _isTracking,
                ),
              ),

            // Bottom Stats Panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CardioStatsPanel(
                isRun: isRun,
                distanceKm: distKm,
                elapsedSeconds: _elapsedSeconds,
                currentSpeedKmh: _currentSpeedKmh,
                currentSteps: _currentSteps,
                userWeightKg: _getUserWeight(),
                isTracking: _isTracking,
                isLocating: _isLocating,
                isPaused: _isPaused,
                isSaving: _isSaving,
                onStart: _runCountdown,
                onPauseResume: _isPaused ? _resumeTracking : _pauseTracking,
                onStop: _stopAndSave,
              ),
            ),

            // Loading Overlay (Ricerca GPS)
            if (_isLocating)
              const Positioned.fill(child: GpsSearchingOverlay()),

            // Countdown Overlay
            if (_showCountdown)
              Positioned.fill(child: CountdownOverlay(countdown: _countdown)),

            // Manual Pause Overlay (Explicit)
            if (_isPaused && !_isLocating && !_showCountdown)
              Positioned.fill(
                child: ManualPauseOverlay(onResume: _resumeTracking),
              ),

            // Auto Pause Overlay (Moved to end to ensure it covers UI)
            if (_autoPaused && !_isPaused)
              Positioned.fill(
                child: AutoPauseOverlay(
                  onDismiss: () {
                    setState(() {
                      _autoPaused = false;
                      _secondsWithoutMovement = 0;
                    });
                  },
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
