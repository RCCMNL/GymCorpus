import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/services/health_service.dart';
import 'package:gym_corpus/core/utils/pending_alarm.dart';
import 'package:gym_corpus/core/utils/time_format.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_draft.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_location_issue.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_route_point.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_gps_filter.dart';
import 'package:gym_corpus/features/training/domain/services/cardio_splits.dart';
import 'package:gym_corpus/features/training/presentation/bloc/cardio_save_outcome.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_map_view.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_overlays.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_stats_panel.dart';
import 'package:gym_corpus/features/training/presentation/widgets/gps_status_badge.dart';
import 'package:gym_corpus/features/training/presentation/widgets/indoor_session_widgets.dart';
import 'package:latlong2/latlong.dart';

class CardioTrackerScreen extends StatefulWidget {
  const CardioTrackerScreen({required this.activity, this.goal, super.key});

  final CardioActivity activity;

  /// Obiettivo scelto prima di partire: non viene salvato con la sessione,
  /// serve alla barra di avanzamento e all'avviso al traguardo.
  final CardioGoal? goal;

  @override
  State<CardioTrackerScreen> createState() => _CardioTrackerScreenState();
}

class _CardioTrackerScreenState extends State<CardioTrackerScreen> {
  final MapController _mapController = MapController();
  final HealthService _healthService = GetIt.I<HealthService>();
  final List<CardioRoutePoint> _route = [];
  StreamSubscription<Position>? _positionStream;
  /// Il battito al secondo della sessione: uno solo, sempre.
  final PendingAlarm _tick = PendingAlarm();
  Timer? _countdownTimer;
  Timer? _bannerTimer;

  /// Ultimo chilometro gia' annunciato: senza questa memoria l'avviso si
  /// ripeterebbe a ogni punto GPS ricevuto oltre il traguardo.
  int _announcedKm = 0;
  bool _goalAnnounced = false;
  String? _bannerTitle;
  String? _bannerSubtitle;

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

  /// Perche' la posizione non e' disponibile, quando non lo e'.
  CardioLocationIssue? _issue;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await _checkDraft();
    await _locate();
  }

  /// Cerca la posizione di partenza e chiude comunque la ricerca.
  ///
  /// L'esito passa da un unico punto proprio perche' il contrario era un
  /// bug: ogni `return` anticipato lasciava `_isLocating` a true, e la
  /// schermata restava sulla ricerca del segnale per sempre, senza
  /// spiegazione e senza il pulsante di avvio.
  Future<void> _locate() async {
    final issue = await _locationIssue();
    if (!mounted) return;

    setState(() {
      _isLocating = false;
      // Una sessione ripresa da una bozza e' gia' in corso: non ha senso
      // coprirla con l'avviso di posizione mancante.
      _issue = _isTracking ? null : issue;
    });

    final position = _currentPosition;
    if (issue == null && position != null) _mapController.move(position, 16);
  }

  /// Il motivo per cui la sessione non puo' seguire la posizione, o `null`
  /// se puo'.
  Future<CardioLocationIssue?> _locationIssue() async {
    // Al chiuso non c'e' percorso da seguire: chiedere il permesso di
    // localizzazione per una sessione sul tapis roulant sarebbe solo un
    // permesso in piu' senza contropartita.
    if (!widget.activity.tracksLocation) return null;

    if (!await Geolocator.isLocationServiceEnabled()) {
      return CardioLocationIssue.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return CardioLocationIssue.permissionDenied;
    }
    if (permission == LocationPermission.deniedForever) {
      return CardioLocationIssue.permissionDeniedForever;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // Il permesso c'e': il flusso di posizioni puo' comunque partire, e
      // la mappa si centrera' al primo punto ricevuto. Meglio una mappa
      // non centrata che una schermata bloccata.
      debugPrint('CardioTracker._locationIssue: $e');
    }
    return null;
  }

  void _retryLocation() {
    setState(() {
      _isLocating = true;
      _issue = null;
    });
    unawaited(_locate());
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

      // Una bozza di un'altra attivita' non si propone qui: riprenderla
      // significherebbe salvare distanza, tempo e percorso di quella
      // sessione sotto il tipo di questa. Resta dov'e', e tornera' a essere
      // proposta aprendo l'attivita' giusta.
      if (!draft.isFor(widget.activity)) return;

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
            '${CardioActivity.fromId(draft.type).label} non terminata. '
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
          _currentPosition = _route.last.position;
        }
        // Riprendendo non si riannunciano i chilometri gia' percorsi.
        _announcedKm = (_distanceMeters / 1000).floor();
        _isTracking = true;
      });
      _startTracking(resume: true);
    } catch (e) {
      debugPrint('CardioTracker._checkDraft: $e');
    }
  }

  Future<void> _saveDraft() async {
    // Al chiuso non esiste un percorso: la bozza deve salvarsi lo stesso,
    // altrimenti una sessione indoor interrotta non sarebbe recuperabile.
    if (_route.isEmpty && _elapsedSeconds == 0) return;
    try {
      final db = GetIt.I<AppDatabase>();
      final draft = CardioDraft(
        type: widget.activity.id,
        elapsedSeconds: _elapsedSeconds,
        distanceMeters: _distanceMeters,
        steps: _currentSteps,
        startTime: _sessionStartTime,
        route: List<CardioRoutePoint>.of(_route),
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
        _route.add(
          CardioRoutePoint(
            position: _currentPosition!,
            elapsedSeconds: _elapsedSeconds,
          ),
        );
      }
    });

    _tick.schedulePeriodic(const Duration(seconds: 1), () async {
      if (_isPaused) return;

      // La pausa automatica si basa sulla velocita' GPS: al chiuso quella
      // velocita' e' sempre zero, e metterebbe in pausa una sessione in
      // corso dopo mezzo minuto.
      if (!widget.activity.tracksLocation) {
        setState(() => _elapsedSeconds++);
        await _updateStepsIfDue();
        _saveDraftIfDue();
        return;
      }

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

      await _updateStepsIfDue();
      _saveDraftIfDue();
    });

    // Al chiuso non c'e' alcun flusso di posizioni da aprire.
    if (!widget.activity.tracksLocation) return;

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

          setState(() {
            // GpsStatusBadge legge 0 scarso, 1 discreto, 2 buono: lo stesso
            // ordine in cui sono dichiarati i valori di GpsQuality.
            _gpsSignalQuality = CardioGpsFilter.qualityFor(pos.accuracy).index;
          });

          final newPoint = LatLng(pos.latitude, pos.longitude);
          final previous = _route.isEmpty ? null : _route.last.position;
          final metersFromPrevious = previous == null
              ? null
              : const Distance().as(LengthUnit.Meter, previous, newPoint);

          // Punto scartato: niente percorso, niente distanza e soprattutto
          // niente mappa. Spostarla comunque la faceva saltare sul rimbalzo
          // che si era appena deciso di ignorare.
          if (CardioGpsFilter.rejects(
            accuracyMeters: pos.accuracy,
            metersFromPrevious: metersFromPrevious,
          )) {
            return;
          }

          setState(() {
            _distanceMeters += metersFromPrevious ?? 0;
            _route.add(
              CardioRoutePoint(
                position: newPoint,
                elapsedSeconds: _elapsedSeconds,
              ),
            );

            _currentPosition = newPoint;
            _currentSpeedKmh = pos.speed * 3.6; // m/s -> km/h
            if (_currentSpeedKmh < 0) _currentSpeedKmh = 0;
          });
          _checkMilestones();
          _mapController.move(newPoint, 16);
        });
  }

  /// Aggiorna i passi ogni cinque secondi, se il conteggio e' disponibile.
  Future<void> _updateStepsIfDue() async {
    if (_elapsedSeconds == 0 || _elapsedSeconds % 5 != 0) return;
    if (_sessionStartTime == null || !_healthService.isAuthorized) return;

    final steps = await _healthService.getStepsSince(_sessionStartTime!);
    if (mounted) setState(() => _currentSteps = steps);
  }

  /// Salva la bozza ogni dieci secondi. Volutamente non attesa: il timer non
  /// deve bloccarsi su una scrittura lenta, e `_saveDraft` gestisce e logga
  /// i propri errori.
  void _saveDraftIfDue() {
    if (_elapsedSeconds > 0 && _elapsedSeconds % 10 == 0) {
      unawaited(_saveDraft());
    }
  }

  /// Vibrazione e avviso a ogni chilometro completato e al traguardo.
  ///
  /// Durante una corsa il telefono e' in tasca o al braccio: senza un
  /// riscontro percepibile l'obiettivo si scoprirebbe solo a fine sessione.
  void _checkMilestones() {
    final completedKm = (_distanceMeters / 1000).floor();
    if (completedKm > _announcedKm) {
      _announcedKm = completedKm;
      final splits = CardioSplits.fromRoute(_route);
      final lastFull = splits.where((s) => !s.isPartial).lastOrNull;

      unawaited(HapticFeedback.mediumImpact());
      _showBanner(
        '$completedKm km',
        lastFull == null ? null : '${lastFull.pace} al chilometro',
      );
    }

    final goal = widget.goal;
    if (goal == null || _goalAnnounced) return;

    final reached = goal.isReached(
      distanceKm: _distanceMeters / 1000,
      seconds: _elapsedSeconds,
      calories: _estimatedCalories,
    );
    if (!reached) return;

    _goalAnnounced = true;
    unawaited(HapticFeedback.heavyImpact());
    _showBanner('Obiettivo raggiunto', goal.label);
  }

  void _showBanner(String title, String? subtitle) {
    if (!mounted) return;

    setState(() {
      _bannerTitle = title;
      _bannerSubtitle = subtitle;
    });

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _bannerTitle = null;
        _bannerSubtitle = null;
      });
    });
  }

  /// Stima MET, la stessa usata dal pannello statistiche e dal salvataggio.
  int get _estimatedCalories => widget.activity
      .caloriesFor(
        speedKmh: CardioActivity.averageSpeed(
          distanceKm: _distanceMeters / 1000,
          seconds: _elapsedSeconds,
        ),
        weightKg: _getUserWeight(),
        seconds: _elapsedSeconds,
      )
      .round();

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
    _tick.cancel();
    await _positionStream?.cancel();

    // Al chiuso la distanza non la misura nessun sensore: la si chiede una
    // volta sola, alla fine, e si puo' non indicarla.
    if (!widget.activity.tracksLocation &&
        widget.activity.tracksDistance &&
        _distanceMeters == 0 &&
        mounted) {
      final km = await showDialog<double>(
        context: context,
        builder: (_) => const IndoorDistanceDialog(),
      );
      if (km != null) _distanceMeters = km * 1000;
    }

    await _clearDraft();

    final distKm = _distanceMeters / 1000;
    final avgSpeed = _elapsedSeconds > 0
        ? (distKm / (_elapsedSeconds / 3600))
        : 0.0;

    // Stima MET calibrata sull'andatura media: prima era un valore fisso per
    // tipo di attivita', e una corsa lenta valeva quanto una veloce.
    final calories = _estimatedCalories;

    // Percorso con i tempi di passaggio: sono loro a rendere possibili gli
    // split al chilometro nella schermata di dettaglio.
    final routeJson = CardioRoutePoint.encode(_route);

    if (!mounted) return;

    final bloc = context.read<TrainingBloc>();
    final state = bloc.state;
    final sessionsBefore = state is TrainingLoaded
        ? state.cardioSessions.length
        : 0;

    bloc.add(
      SaveCardioSessionEvent(
        type: widget.activity.id,
        distance: double.parse(distKm.toStringAsFixed(2)),
        duration: _elapsedSeconds,
        avgSpeed: double.parse(avgSpeed.toStringAsFixed(1)),
        pace: formatPace(seconds: _elapsedSeconds, distanceKm: distKm),
        calories: calories,
        steps: _currentSteps,
        routeJson: routeJson,
        goal: widget.goal,
      ),
    );

    // Si aspetta che la sessione sia davvero comparsa, non mezzo secondo:
    // l'attesa fissa chiudeva la schermata dicendo "salvato" senza saperlo.
    // Un fallimento lo racconta la SnackBar globale sugli errori del bloc.
    await awaitCardioSessionSaved(bloc.stream, sessionsBefore: sessionsBefore);
    if (mounted) context.pop();
  }

  double _getUserWeight() {
    final trainingState = context.read<TrainingBloc>().state;
    if (trainingState is TrainingLoaded &&
        trainingState.bodyWeightLogs.isNotEmpty) {
      return trainingState.bodyWeightLogs.first.weight;
    }

    final authState = context.read<AuthBloc>().state;
    return authState.maybeWhen(
      authenticated: (user, _) => user.weight ?? 70.0,
      orElse: () => 70.0,
    );
  }

  @override
  void dispose() {
    _tick.cancel();
    _countdownTimer?.cancel();
    _bannerTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = widget.activity == CardioActivity.run;
    final tracksLocation = widget.activity.tracksLocation;
    final distKm = _distanceMeters / 1000;

    // Senza posizione la sessione non puo' partire: si mostra il motivo al
    // posto dei comandi, non sopra di essi.
    final blocked = tracksLocation && !_isLocating && _issue != null;

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
            // Sfondo: la mappa all'aperto, il cronometro al chiuso, dove un
            // percorso GPS non esiste.
            if (tracksLocation)
              CardioMapView(
                mapController: _mapController,
                currentPosition: _currentPosition,
                route: [for (final point in _route) point.position],
                isRun: isRun,
              )
            else
              Positioned.fill(
                child: IndoorSessionBackdrop(
                  activity: widget.activity,
                  elapsedSeconds: _elapsedSeconds,
                  isTracking: _isTracking,
                ),
              ),

            // Posizione non disponibile: sotto al tasto indietro, cosi' da
            // qui si puo' sempre uscire.
            if (blocked)
              Positioned.fill(
                child: GpsUnavailableOverlay(
                  issue: _issue!,
                  onRetry: _retryLocation,
                ),
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
            if (!_isLocating && tracksLocation && !blocked)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: GpsStatusBadge(
                  gpsSignalQuality: _gpsSignalQuality,
                  isTracking: _isTracking,
                ),
              ),

            // Bottom Stats Panel
            if (!blocked)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CardioStatsPanel(
                  activity: widget.activity,
                  distanceKm: distKm,
                  elapsedSeconds: _elapsedSeconds,
                  currentSpeedKmh: _currentSpeedKmh,
                  currentSteps: _currentSteps,
                  userWeightKg: _getUserWeight(),
                  isTracking: _isTracking,
                  isLocating: _isLocating,
                  isPaused: _isPaused,
                  isSaving: _isSaving,
                  goal: widget.goal,
                  onStart: _runCountdown,
                  onPauseResume: _isPaused ? _resumeTracking : _pauseTracking,
                  onStop: _stopAndSave,
                ),
              ),

            // Avviso di chilometro completato o obiettivo raggiunto
            if (_bannerTitle != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 72,
                left: 24,
                right: 24,
                child: Center(
                  child: CardioMilestoneBanner(
                    title: _bannerTitle!,
                    subtitle: _bannerSubtitle,
                  ),
                ),
              ),

            // Loading Overlay (Ricerca GPS)
            if (_isLocating && tracksLocation)
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
              _tick.cancel();
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
