import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/services/notification_service.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/set_specs.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/exercise_progress_card.dart';
import 'package:gym_corpus/features/training/presentation/widgets/next_up_card.dart';
import 'package:gym_corpus/features/training/presentation/widgets/pause_overlay.dart';
import 'package:gym_corpus/features/training/presentation/widgets/rest_timer_overlay.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_header.dart';
import 'package:gym_corpus/features/training/presentation/widgets/training_terminal_screens.dart';

enum _Phase { working, resting, completed }

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({this.routine, super.key});
  final RoutineEntity? routine;
  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _timer;
  int _seconds = 0;
  int _restDuration = 90;
  _Phase _phase = _Phase.working;
  int _exIdx = 0;
  int _setIdx = 0;
  AnimationController? _pulseCtrl;
  late int _workoutId;
  DateTime? _lastResumeTime;
  Duration _elapsedBeforePause = Duration.zero;
  bool _isPaused = false;
  DateTime? _restEndTime;
  Timer? _executionTimer;
  String _execTimeStr = '00:00:00';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _workoutId = DateTime.now().millisecondsSinceEpoch;
    _lastResumeTime = DateTime.now();
    _startExecutionTimer();
    context.read<TrainingBloc>()
      ..add(LoadWeightLogsEvent())
      ..add(LoadWorkoutSessionsEvent())
      ..add(
        StartWorkoutSessionEvent(
          id: _workoutId,
          name: widget.routine?.title ?? 'Allenamento',
          routineId: widget.routine?.id,
        ),
      );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  int get _elapsedSessionSeconds {
    final runningTime = _lastResumeTime == null
        ? Duration.zero
        : DateTime.now().difference(_lastResumeTime!);
    return (_elapsedBeforePause + runningTime).inSeconds;
  }

  void _startExecutionTimer() {
    _executionTimer?.cancel();
    _executionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() {
          _execTimeStr = _fmtFull(_elapsedSessionSeconds);
        });
      }
    });
  }

  String _fmtFull(int s) {
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sc = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sc';
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _elapsedBeforePause += DateTime.now().difference(_lastResumeTime!);
        _lastResumeTime = null;
        _timer?.cancel();
        NotificationService.instance.cancelNotification(100);
      } else {
        _lastResumeTime = DateTime.now();
        if (_phase == _Phase.resting) {
          _startTimer();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App tornata in foreground: ricalcola i secondi rimanenti
      if (_phase == _Phase.resting && _restEndTime != null) {
        final remaining = _restEndTime!.difference(DateTime.now()).inSeconds;
        if (remaining <= 0) {
          // Recupero già scaduto in background
          NotificationService.instance.cancelNotification(100);
          _onRestDone();
        } else {
          // Ancora in recupero: aggiorna il countdown e riavvia il timer
          _timer?.cancel();
          setState(() => _seconds = remaining);
          _startTimer();
        }
      }
    } else if (state == AppLifecycleState.paused) {
      // App in background: il Timer.periodic si ferma su alcuni dispositivi;
      // la notifica avviserà l'utente quando il recupero finisce
      _timer?.cancel();
    }
  }

  List<RoutineExerciseEntity> get _exercises => widget.routine?.exercises ?? [];
  RoutineExerciseEntity? get _curEx =>
      _exIdx < _exercises.length ? _exercises[_exIdx] : null;
  int get _totalSets => _curEx?.sets ?? 0;
  bool get _isLastSet => _setIdx + 1 >= _totalSets;
  bool get _isLastEx => _exIdx + 1 >= _exercises.length;

  double get _progress {
    if (_exercises.isEmpty) return 0;
    final total = _exercises.fold<int>(0, (s, e) => s + e.sets);
    if (total == 0) return 0;
    var done = 0;
    for (var i = 0; i < _exIdx && i < _exercises.length; i++) {
      done += _exercises[i].sets;
    }
    done += _setIdx;
    return done / total;
  }

  void _completeSet() {
    if (_phase != _Phase.working) return;
    final ex = _curEx;
    if (ex != null) {
      final currentSpecs = getSetSpecs(ex, _setIdx);

      // La durata della sessione finisce in `Workouts.durationSeconds` con
      // CompleteWorkoutSessionEvent, qui sotto. Prima veniva scritta anche
      // nel campo `rpe` dell'ultimo set, da quando quella colonna non
      // esisteva: un numero di secondi in un campo che vale da 1 a 10 faceva
      // scattare a ogni allenamento la stima del massimale, pensata per i
      // set portati oltre RPE 8.
      context.read<TrainingBloc>().add(
        AddSetToExercise(
          workoutId: _workoutId,
          exerciseId: ex.exercise.id,
          reps: currentSpecs.reps,
          weight: ex.exercise.isBodyweight ? 0 : currentSpecs.weight,
        ),
      );
    }
    if (_isLastSet && _isLastEx) {
      context.read<TrainingBloc>().add(
        CompleteWorkoutSessionEvent(
          workoutId: _workoutId,
          durationSeconds: _elapsedSessionSeconds,
        ),
      );
      setState(() => _phase = _Phase.completed);
      return;
    }
    setState(() {
      _phase = _Phase.resting;
      _seconds = _restDuration;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // Registra quando finisce il recupero (usato per ricalcolo al resume)
    _restEndTime = DateTime.now().add(Duration(seconds: _seconds));
    // Schedula notifica locale per quando scade il recupero
    Future.delayed(Duration(seconds: _seconds), () {
      // Spara la notifica solo se ancora in recupero e l'app NON è in primo piano
      if (mounted && _phase == _Phase.resting) {
        final isForeground =
            WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
        if (!isForeground) {
          NotificationService.instance.showNotification(
            id: 100,
            title: 'GymCorpus - Recupero terminato',
            body: 'Inizia la serie successiva! 💪',
          );
        }
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _onRestDone();
      }
    });
  }

  void _onRestDone() {
    _timer?.cancel();
    _restEndTime = null;
    NotificationService.instance.cancelNotification(100);
    setState(() {
      if (_isLastSet) {
        _exIdx++;
        _setIdx = 0;
      } else {
        _setIdx++;
      }
      _phase = _Phase.working;
      _seconds = 0;
    });
  }

  void _restartTimer() {
    if (_phase != _Phase.resting) return;
    _timer?.cancel();
    setState(() => _seconds = _restDuration);
    _startTimer(); // aggiorna anche _restEndTime
  }

  void _skipRest() {
    if (_phase != _Phase.resting) return;
    NotificationService.instance.cancelNotification(100);
    _onRestDone();
  }

  void _confirmEnd() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Terminare l allenamento?',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Le serie completate finora sono state salvate correttamente nel tuo storico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CONTINUA',
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/training');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text(
              'CHIUDI ORA',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _executionTimer?.cancel();
    _pulseCtrl?.dispose();
    NotificationService.instance.cancelAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        if (state is TrainingLoaded) {
          final d = int.tryParse(state.settings['rest_timer'] ?? '90') ?? 90;
          if (_restDuration != d) {
            _restDuration = d;
            if (_phase != _Phase.resting) _seconds = d;
          }
        }
        if (_phase == _Phase.completed) {
          return WorkoutCompletedScreen(
            routineTitle: widget.routine?.title ?? 'Allenamento',
          );
        }
        if (_exercises.isEmpty) return const EmptyRoutineScreen();
        final ex = _curEx!;
        final prog = _restDuration > 0 ? (_seconds / _restDuration) : 0.0;
        final isResting = _phase == _Phase.resting;
        final accentColor = isResting
            ? const Color(0xFFFFA07A)
            : theme.colorScheme.primary;

        final unitStr = state is TrainingLoaded
            ? (state.settings['units'] ?? 'KG')
            : 'KG';
        final isImperial = unitStr == 'LB';
        final weightUnit = isImperial ? WeightUnit.lb : WeightUnit.kg;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: const GymHeader(),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TrainingHeader(
                    routineTitle: widget.routine?.title ?? 'Allenamento',
                    execTimeStr: _execTimeStr,
                    accentColor: accentColor,
                    isPaused: _isPaused,
                    onTogglePause: _togglePause,
                    onConfirmEnd: _confirmEnd,
                    exerciseIndex: _exIdx,
                    exerciseCount: _exercises.length,
                    progress: _progress,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // ── MAIN CONTENT (NO SCROLL) ──
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            // ── EXERCISE CARD ──
                            Expanded(
                              flex: 5,
                              child: ExerciseProgressCard(
                                exercise: ex,
                                setIndex: _setIdx,
                                totalSets: _totalSets,
                                unit: weightUnit,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── ACTION BUTTONS ──
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: isResting
                                      ? null
                                      : LinearGradient(
                                          colors: [
                                            theme.colorScheme.tertiary,
                                            theme.colorScheme.tertiary
                                                .withValues(alpha: 0.8),
                                          ],
                                        ),
                                  color: isResting
                                      ? theme.colorScheme.surfaceContainerHigh
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _phase == _Phase.working
                                        ? _completeSet
                                        : null,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isResting
                                                ? Icons.timer
                                                : Icons.check_circle_rounded,
                                            size: 22,
                                            color: isResting
                                                ? theme.colorScheme.outline
                                                : Colors.black,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            isResting
                                                ? 'RECUPERO IN CORSO...'
                                                : 'SEGNA SET COMPLETATO',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1,
                                              fontSize: 14,
                                              fontFamily: 'Lexend',
                                              color: isResting
                                                  ? theme.colorScheme.outline
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── NEXT UP ──
                            NextUpCard(
                              isLastSet: _isLastSet,
                              currentExercise: ex,
                              nextExercise: _isLastEx
                                  ? null
                                  : _exercises[_exIdx + 1],
                              setIndex: _setIdx,
                              totalSets: _totalSets,
                              unit: weightUnit,
                              accent: accentColor,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // ── TIMER MODAL OVERLAY ──
                      if (isResting)
                        RestTimerOverlay(
                          pulseController: _pulseCtrl,
                          progress: prog,
                          secondsRemaining: _seconds,
                          accentColor: accentColor,
                          onRestart: _restartTimer,
                          onSkip: _skipRest,
                          onConfirmEnd: _confirmEnd,
                        ),

                      // ── PAUSE OVERLAY ──
                      if (_isPaused)
                        PauseOverlay(
                          accentColor: accentColor,
                          onResume: _togglePause,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
