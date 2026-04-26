import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/services/notification_service.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

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
  late DateTime _startTime;
  bool _durationSaved = false;
  DateTime? _restEndTime; // quando scade il recupero (usato per background)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _workoutId = DateTime.now().millisecondsSinceEpoch;
    _startTime = DateTime.now();
    context.read<TrainingBloc>().add(LoadWeightLogsEvent());
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
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
  RoutineExerciseEntity? get _curEx => _exIdx < _exercises.length ? _exercises[_exIdx] : null;
  int get _totalSets => _curEx?.sets ?? 0;
  bool get _isLastSet => _setIdx + 1 >= _totalSets;
  bool get _isLastEx => _exIdx + 1 >= _exercises.length;

  double get _progress {
    if (_exercises.isEmpty) return 0;
    final total = _exercises.fold<int>(0, (s, e) => s + e.sets);
    if (total == 0) return 0;
    var done = 0;
    for (var i = 0; i < _exIdx && i < _exercises.length; i++) done += _exercises[i].sets;
    done += _setIdx;
    return done / total;
  }

  void _completeSet() {
    if (_phase != _Phase.working) return;
    final ex = _curEx;
    if (ex != null) {
      final isFirstSet = _exIdx == 0 && _setIdx == 0;
      final isLastSet = _isLastSet && _isLastEx;
      // Al primo set: salva la durata reale come rpe (secondi dall'inizio)
      // Al completamento: salva la durata finale definitiva
      int? rpePayload;
      if (isFirstSet && !_durationSaved) {
        // placeholder: lo aggiorniamo al termine
      }
      if (isLastSet && !_durationSaved) {
        rpePayload = DateTime.now().difference(_startTime).inSeconds;
        _durationSaved = true;
      }
      context.read<TrainingBloc>().add(AddSetToExercise(
        workoutId: _workoutId,
        exerciseId: ex.exercise.id,
        reps: ex.reps,
        weight: ex.weight,
        rpe: rpePayload,
      ));
    }
    if (_isLastSet && _isLastEx) { setState(() => _phase = _Phase.completed); return; }
    setState(() { _phase = _Phase.resting; _seconds = _restDuration; });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // Registra quando finisce il recupero (usato per ricalcolo al resume)
    _restEndTime = DateTime.now().add(Duration(seconds: _seconds));
    // Schedula notifica locale per quando scade il recupero
    Future.delayed(Duration(seconds: _seconds), () {
      // Spara la notifica solo se ancora in recupero (non saltato/già avanzato)
      if (mounted && _phase == _Phase.resting) {
        NotificationService.instance.showNotification(
          id: 100,
          title: 'GymCorpus - Recupero terminato',
          body: 'Inizia la serie successiva! 💪',
        );
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) { setState(() => _seconds--); } else { _onRestDone(); }
    });
  }

  void _onRestDone() {
    _timer?.cancel();
    _restEndTime = null;
    NotificationService.instance.cancelNotification(100);
    setState(() {
      if (_isLastSet) { _exIdx++; _setIdx = 0; } else { _setIdx++; }
      _phase = _Phase.working; _seconds = 0;
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

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sc = (s % 60).toString().padLeft(2, '0');
    return m + ':' + sc;
  }

  void _confirmEnd() {
    final theme = Theme.of(context);
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Terminare l allenamento?', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold)),
      content: const Text('I progressi di questa sessione andranno persi.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text('ANNULLA', style: TextStyle(color: theme.colorScheme.outline, fontWeight: FontWeight.w900))),
        TextButton(onPressed: () { Navigator.pop(ctx); context.go('/training'); },
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          child: const Text('CONFERMA', style: TextStyle(fontWeight: FontWeight.w900))),
      ],
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseCtrl?.dispose();
    NotificationService.instance.cancelAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<TrainingBloc, TrainingState>(builder: (context, state) {
      if (state is TrainingLoaded) {
        final d = int.tryParse(state.settings['rest_timer'] ?? '90') ?? 90;
        if (_restDuration != d) { _restDuration = d; if (_phase != _Phase.resting) _seconds = d; }
      }
      if (_phase == _Phase.completed) return _completedScreen(theme);
      if (_exercises.isEmpty) return _emptyScreen(theme);
      final ex = _curEx!;
      final prog = _restDuration > 0 ? (_seconds / _restDuration) : 0.0;
      final isResting = _phase == _Phase.resting;
      final accentColor = isResting ? const Color(0xFFFFA07A) : theme.colorScheme.primary;

      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: const GymHeader(),
        body: SafeArea(child: SingleChildScrollView(physics: const BouncingScrollPhysics(),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Column(children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accentColor.withValues(alpha: 0.15), accentColor.withValues(alpha: 0.03)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: accentColor.withValues(alpha: 0.1)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 4, height: 20, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [accentColor, theme.colorScheme.tertiary]), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Text(isResting ? 'RECUPERO' : 'IN ALLENAMENTO', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 10, color: accentColor)),
                ]),
                const SizedBox(height: 12),
                Text((widget.routine?.title ?? 'ALLENAMENTO').toUpperCase(), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: -0.5)),
                const SizedBox(height: 12),
                // Progress
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Esercizio ' + (_exIdx + 1).toString() + ' di ' + _exercises.length.toString(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.w700, fontSize: 10)),
                  Text((_progress * 100).toInt().toString() + '%', style: theme.textTheme.labelSmall?.copyWith(color: accentColor, fontWeight: FontWeight.w900, fontSize: 10)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _progress, minHeight: 6, backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), valueColor: AlwaysStoppedAnimation(accentColor))),
              ]),
            ),
            const SizedBox(height: 16),

            // ── EXERCISE CARD ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.08)),
              ),
              child: Column(children: [
                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: accentColor.withValues(alpha: 0.1),
                      child: ex.exercise.imageUrl != null
                          ? Image.network(
                              ex.exercise.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/placeholder-image.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/placeholder-image.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ESERCIZIO CORRENTE', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: theme.colorScheme.outline, fontSize: 8, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(ex.exercise.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', height: 1.1, fontSize: 16)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: theme.colorScheme.tertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Text('SET', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 8, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
                      Text((_setIdx + 1).toString() + '/' + _totalSets.toString(), style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                // Chips row
                Row(children: [
                  Expanded(child: _GlassChip(label: 'RIPETIZIONI', value: ex.reps.toString(), color: theme.colorScheme.primary, theme: theme)),
                  const SizedBox(width: 10),
                  Expanded(child: _GlassChip(label: 'PESO', value: ex.weight.toStringAsFixed(1) + ' kg', color: theme.colorScheme.secondary, theme: theme)),
                  if (isResting) ...[const SizedBox(width: 10),
                    Expanded(child: _GlassChip(label: 'STATO', value: 'RIPOSO', color: const Color(0xFFFFA07A), theme: theme))],
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // ── TIMER SECTION ──
            AnimatedBuilder(animation: _pulseCtrl ?? kAlwaysCompleteAnimation, builder: (context, child) {
              final scale = isResting ? 1.0 + ((_pulseCtrl?.value ?? 0.0) * 0.02) : 1.0;
              return Transform.scale(scale: scale, child: child);
            }, child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: accentColor.withValues(alpha: isResting ? 0.15 : 0.05)),
                boxShadow: isResting ? [BoxShadow(color: accentColor.withValues(alpha: 0.08), blurRadius: 30, spreadRadius: 5)] : [],
              ),
              child: Column(children: [
                // Ring
                SizedBox(width: 160, height: 160, child: Stack(alignment: Alignment.center, children: [
                  SizedBox(width: 160, height: 160, child: CustomPaint(painter: _TimerRingPainter(progress: prog, color: accentColor, trackColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)))),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(isResting ? 'RECUPERO' : 'PRONTO', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: theme.colorScheme.outline, fontSize: 8, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(_fmt(_seconds), style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 36, color: isResting ? accentColor : theme.colorScheme.onSurface)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(isResting ? 'IN CORSO' : 'IDLE', style: TextStyle(color: accentColor, fontSize: 8, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 1)),
                    ),
                  ]),
                ])),
                if (isResting) ...[const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _ActionPill(icon: Icons.refresh_rounded, label: 'Riavvia', onTap: _restartTimer, filled: false, theme: theme),
                    const SizedBox(width: 12),
                    _ActionPill(icon: Icons.skip_next_rounded, label: 'Salta', onTap: _skipRest, filled: true, theme: theme),
                  ]),
                ],
              ]),
            )),
            const SizedBox(height: 20),

            // ── ACTION BUTTONS ──
            SizedBox(width: double.infinity, child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                gradient: isResting ? null : LinearGradient(colors: [theme.colorScheme.tertiary, theme.colorScheme.tertiary.withValues(alpha: 0.8)]),
                color: isResting ? theme.colorScheme.surfaceContainerHigh : null,
              ),
              child: Material(color: Colors.transparent, child: InkWell(
                onTap: _phase == _Phase.working ? _completeSet : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(isResting ? Icons.timer : Icons.check_circle_rounded, size: 22, color: isResting ? theme.colorScheme.outline : Colors.black),
                  const SizedBox(width: 10),
                  Text(isResting ? 'RECUPERO IN CORSO...' : 'SEGNA SET COMPLETATO',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14, fontFamily: 'Lexend', color: isResting ? theme.colorScheme.outline : Colors.black)),
                ])),
              )),
            )),
            const SizedBox(height: 10),
            // End workout
            SizedBox(width: double.infinity, child: TextButton.icon(
              onPressed: _confirmEnd,
              icon: const Icon(Icons.stop_circle_outlined, size: 20),
              label: const Text('FINE ALLENAMENTO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13)),
              style: TextButton.styleFrom(backgroundColor: theme.colorScheme.surfaceContainerHigh, foregroundColor: const Color(0xFFFF9494),
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            )),
            const SizedBox(height: 20),

            // ── NEXT UP ──
            _buildNextUp(theme, accentColor),
            const SizedBox(height: 100),
          ])))),
      );
    });
  }

  Widget _buildNextUp(ThemeData theme, Color accent) {
    String nextName; String nextInfo; IconData nextIcon;
    if (!_isLastSet) {
      nextName = _curEx!.exercise.name;
      final ns = _setIdx + 2;
      nextInfo = 'Serie ' + ns.toString() + ' di ' + _totalSets.toString();
      nextIcon = Icons.replay_rounded;
    } else if (!_isLastEx) {
      final ne = _exercises[_exIdx + 1];
      nextName = ne.exercise.name;
      nextInfo = ne.sets.toString() + ' x ' + ne.reps.toString() + ' @ ' + ne.weight.toStringAsFixed(1) + ' kg';
      nextIcon = Icons.arrow_forward_rounded;
    } else {
      nextName = 'Ultimo esercizio!';
      nextInfo = 'Dopo questa serie hai finito';
      nextIcon = Icons.emoji_events_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4), theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.15)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            color: accent.withValues(alpha: 0.1),
            child: (nextName != 'Ultimo esercizio!' &&
                    _exIdx + 1 < _exercises.length)
                ? (_isLastSet
                    ? (_exercises[_exIdx + 1].exercise.imageUrl != null
                        ? Image.network(
                            _exercises[_exIdx + 1].exercise.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/placeholder-image.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/placeholder-image.png',
                            fit: BoxFit.cover,
                          ))
                    : (_curEx?.exercise.imageUrl != null
                        ? Image.network(
                            _curEx!.exercise.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/placeholder-image.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/placeholder-image.png',
                            fit: BoxFit.cover,
                          )))
                : Icon(nextIcon, color: accent, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PROSSIMO', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 8, color: theme.colorScheme.outline)),
          const SizedBox(height: 4),
          Text(nextName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 13)),
          const SizedBox(height: 2),
          Text(nextInfo, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: 9)),
        ])),
        Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.3), size: 20),
      ]),
    );
  }

  Widget _completedScreen(ThemeData theme) {
    return Scaffold(backgroundColor: theme.colorScheme.surface, appBar: const GymHeader(),
      body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 120, height: 120,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [const Color(0xFF8DE8C7).withValues(alpha: 0.25), const Color(0xFF8DE8C7).withValues(alpha: 0.05)]),
            boxShadow: [BoxShadow(color: const Color(0xFF8DE8C7).withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 10)],
          ),
          child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF8DE8C7), size: 56)),
        const SizedBox(height: 32),
        Text('ALLENAMENTO', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 12, color: const Color(0xFF8DE8C7))),
        const SizedBox(height: 4),
        Text('COMPLETATO!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', color: const Color(0xFF8DE8C7))),
        const SizedBox(height: 16),
        Text('Ottimo lavoro! Hai completato tutti gli esercizi.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
          child: Text((widget.routine?.title ?? 'Allenamento').toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11))),
        const SizedBox(height: 40),
        SizedBox(width: double.infinity, child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF3367FF), Color(0xFF94AAFF)])),
          child: Material(color: Colors.transparent, child: InkWell(onTap: () => context.go('/training'), borderRadius: BorderRadius.circular(20),
            child: const Padding(padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: Text('TORNA ALLA DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14, fontFamily: 'Lexend')))),
          )),
        )),
      ])))),
    );
  }

  Widget _emptyScreen(ThemeData theme) {
    return Scaffold(backgroundColor: theme.colorScheme.surface, appBar: const GymHeader(),
      body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.fitness_center_outlined, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        const SizedBox(height: 24),
        Text('Nessun esercizio in questa routine', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 24),
        TextButton(onPressed: () => context.go('/training'), child: const Text('TORNA INDIETRO')),
      ])))),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label, required this.value, required this.color, required this.theme});
  final String label, value; final Color color; final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 7, fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
      ]),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.icon, required this.label, required this.onTap, required this.filled, required this.theme});
  final IconData icon; final String label; final VoidCallback onTap; final bool filled; final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: filled ? const LinearGradient(colors: [Color(0xFF94AAFF), Color(0xFF3367FF)]) : null,
        color: filled ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: filled ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: filled ? Colors.white : theme.colorScheme.onSurface),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Lexend', color: filled ? Colors.white : theme.colorScheme.onSurface)),
      ]),
    ));
  }
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({required this.progress, required this.color, required this.trackColor});
  final double progress; final Color color, trackColor;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sw = 8.0;
    canvas.drawCircle(center, radius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = sw);
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, Paint()..color = color.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = sw + 6..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
