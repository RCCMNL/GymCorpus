import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({required this.routine, super.key});

  final RoutineEntity routine;

  void _removeSingleExercise(BuildContext context, RoutineExerciseEntity exerciseToRemove, RoutineEntity currentRoutine) {
    final updatedList =
        currentRoutine.exercises.where((e) => e.id != exerciseToRemove.id).toList();
    context.read<TrainingBloc>().add(
          UpdateRoutineEvent(
            id: currentRoutine.id,
            title: currentRoutine.title,
            exercises: updatedList,
            estDuration: currentRoutine.estimatedDuration,
          ),
        );
  }

  void _showEditExerciseSheet(BuildContext context, RoutineExerciseEntity re, RoutineEntity currentRoutine) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickExerciseEditPanel(re: re, routine: currentRoutine),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Elimina Routine', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend')),
        content: const Text(
            'Sei sicuro di voler eliminare questa routine? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ANNULLA', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.w900)),
          ),
          TextButton(
            onPressed: () {
              context.read<TrainingBloc>().add(DeleteRoutineEvent(routine.id));
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back from detail screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINA PERMANENTEMENTE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showExerciseActionsSheet(BuildContext context, RoutineExerciseEntity re, RoutineEntity currentRoutine) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              re.exercise.name.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'Lexend', letterSpacing: 0.5),
            ),
            const SizedBox(height: 24),
            _ActionItem(
              icon: Icons.edit_note_rounded,
              label: 'Modifica serie e ripetizioni',
              onTap: () {
                Navigator.pop(context);
                _showEditExerciseSheet(context, re, currentRoutine);
              },
            ),
            _ActionItem(
              icon: Icons.remove_circle_outline_rounded,
              label: 'Rimuovi esercizio dalla routine',
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.pop(context);
                _removeSingleExercise(context, re, currentRoutine);
              },
            ),
            const Divider(height: 32),
            _ActionItem(
              icon: Icons.delete_forever_rounded,
              label: 'Elimina intera routine',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        var currentRoutine = routine;
        String currentUnit = 'KG';
        if (state is TrainingLoaded) {
          try {
            currentRoutine = state.routines.firstWhere(
              (r) => r.id == routine.id,
            );
          } catch (_) {}
          currentUnit = state.settings['units'] ?? 'KG';
        }
        final isImperial = currentUnit == 'LB';

        final theme = Theme.of(context);
        final exercises = currentRoutine.exercises;

        return Scaffold(
          appBar: const GymHeader(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.tertiary.withValues(alpha: 0.05),
                        Colors.orangeAccent.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.05)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.orangeAccent, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ROUTINE ATTUALE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary.withValues(alpha: 0.6),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                        ).createShader(bounds),
                        child: Text(
                          currentRoutine.title,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                            fontFamily: 'Lexend',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _HeaderTag(
                            icon: Icons.fitness_center_rounded,
                            label: '${exercises.length} ESERCIZI',
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            textColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          _HeaderTag(
                            icon: Icons.timer_outlined,
                            label: '${currentRoutine.estimatedDuration ?? "--"} MIN',
                            color: Colors.orangeAccent.withValues(alpha: 0.08),
                            textColor: Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // La riga degli esercizi è stata integrata nell'header sopra
                if (exercises.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Nessun esercizio in questa routine.',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    ),
                  )
                else
                  Column(
                    children: exercises.map((re) {
                      var setsList = <dynamic>[];
                      if (re.setsData != null) {
                        try {
                          setsList = jsonDecode(re.setsData!) as List<dynamic>;
                        } catch (e) {
                          setsList = [];
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary.withValues(alpha: 0.15),
                                      theme.colorScheme.tertiary.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                                ),
                                child: Icon(
                                  Icons.fitness_center_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                re.exercise.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Lexend',
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${setsList.length} SERIE',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      re.exercise.targetMuscle.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: theme.colorScheme.outline,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showEditExerciseSheet(context, re, currentRoutine);
                                  } else if (val == 'remove_exercise') {
                                    _removeSingleExercise(context, re, currentRoutine);
                                  } else if (val == 'delete_routine') {
                                    _showDeleteDialog(context);
                                  }
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                color: Color.alphaBlend(
                                  theme.colorScheme.primary.withValues(alpha: 0.15), 
                                  theme.colorScheme.surface
                                ),
                                elevation: 6,
                                icon: Icon(Icons.more_horiz_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_note_rounded, size: 20, color: theme.colorScheme.primary),
                                        const SizedBox(width: 12),
                                        const Text('Modifica serie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'remove_exercise',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.orangeAccent),
                                        const SizedBox(width: 12),
                                        const Text('Rimuovi esercizio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.orangeAccent)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete_routine',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_forever_rounded, size: 20, color: Colors.redAccent),
                                        const SizedBox(width: 12),
                                        Text('Elimina routine', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (setsList.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  children: [
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    ...setsList.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      final setData =
                                          entry.value as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text('SET ${idx + 1}',
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                        fontWeight: FontWeight.w900,
                                                        color: theme.colorScheme.primary,
                                                        fontSize: 9,
                                                        letterSpacing: 1.0,
                                                      ),
                                               ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              isImperial 
                                                ? '${UnitConverter.kgToLb((setData['weight'] as num).toDouble()).toStringAsFixed(1)}' 
                                                : '${(setData['weight'] as num).toDouble().toStringAsFixed(1)}',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isImperial ? 'LB' : 'KG',
                                              style: TextStyle(
                                                color: theme.colorScheme.outline,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(width: 24),
                                            Text(
                                              '${setData['reps']}',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'REPS',
                                              style: TextStyle(
                                                color: theme.colorScheme.outline,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),
                // Quick Tip Box
                _QuickTipBox(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickTipBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orangeAccent.withValues(alpha: 0.1),
            Colors.deepOrange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.bolt_rounded,
              size: 80,
              color: Colors.orangeAccent.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded, size: 20, color: Colors.orangeAccent),
                  const SizedBox(width: 10),
                  Text(
                    'PRO TIP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.orangeAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Focus on explosive concentric movements and 2-second eccentric phases to maximize hypertrophy and power output for this routine.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({
    this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickExerciseEditPanel extends StatefulWidget {
  const _QuickExerciseEditPanel({required this.re, required this.routine});

  final RoutineExerciseEntity re;
  final RoutineEntity routine;

  @override
  State<_QuickExerciseEditPanel> createState() => _QuickExerciseEditPanelState();
}

class _QuickExerciseEditPanelState extends State<_QuickExerciseEditPanel> {
  late List<_ExerciseSetData> sets;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    sets = [];
    if (widget.re.setsData != null) {
      try {
        final decoded = jsonDecode(widget.re.setsData!);
        sets = (decoded as List)
            .map((dynamic s) {
              final map = s as Map<String, dynamic>;
              return _ExerciseSetData(
                weight: (map['weight'] as num).toDouble(),
                reps: map['reps'] as int,
              );
            })
            .toList();
      } catch (_) {
        sets = [_ExerciseSetData(weight: 0, reps: 0)];
      }
    }
    if (sets.isEmpty) sets = [_ExerciseSetData(weight: 0, reps: 0)];

    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    if (isImperial) {
      for (final s in sets) {
        s.weight = UnitConverter.kgToLb(s.weight);
      }
    }

    _initControllers();
  }

  void _initControllers() {
    weightControllers = sets
        .map(
          (s) => TextEditingController(
            text: s.weight == 0 ? '' : s.weight.toStringAsFixed(1),
          ),
        )
        .toList();
    repsControllers = sets
        .map(
          (s) => TextEditingController(
            text: s.reps == 0 ? '' : s.reps.toString(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in weightControllers) {
      c.dispose();
    }
    for (final c in repsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final theme = Theme.of(context);
    setState(() => isSaving = true);
    
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    final setsToSave = sets.map((s) {
      double w = s.weight;
      if (isImperial) w = UnitConverter.lbToKg(w);
      return {
        'weight': w,
        'reps': s.reps,
      };
    }).toList();

    final updatedSetsJson = jsonEncode(setsToSave);

    double firstWeight = sets.first.weight;
    if (isImperial) firstWeight = UnitConverter.lbToKg(firstWeight);

    final updatedExercise = widget.re.copyWith(
      sets: sets.length,
      weight: firstWeight,
      reps: sets.first.reps,
      setsData: updatedSetsJson,
    );

    final updatedExercises = widget.routine.exercises.map((e) {
      return e.id == widget.re.id ? updatedExercise : e;
    }).toList();

    context.read<TrainingBloc>().add(
          UpdateRoutineEvent(
            id: widget.routine.id,
            title: widget.routine.title,
            exercises: updatedExercises,
            estDuration: widget.routine.estimatedDuration,
          ),
        );
        
    // Breve attesa per permettere al DB di scrivere e al Bloc di emettere
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.tertiary, theme.colorScheme.tertiary.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.onTertiary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Salvataggio completato!',
                    style: TextStyle(
                      color: theme.colorScheme.onTertiary,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lexend',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary.withValues(alpha: 0.1), theme.colorScheme.tertiary.withValues(alpha: 0.1)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.re.exercise.name.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lexend',
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Modifica parametri serie',
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Rimossa la ConstrainedBox interna per favorire lo scroll globale del pannello ed evitare overflow
                Column(
                  children: [
                    ...List.generate(sets.length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _MiniInput(
                                controller: weightControllers[idx],
                                label: (context.read<TrainingBloc>().state is TrainingLoaded && 
                                        (context.read<TrainingBloc>().state as TrainingLoaded).settings['units'] == 'LB') 
                                        ? 'PESO LB' : 'PESO KG',
                                onChanged: (v) =>
                                    sets[idx].weight = double.tryParse(v) ?? 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: _MiniInput(
                                controller: repsControllers[idx],
                                label: 'RIP.',
                                onChanged: (v) =>
                                    sets[idx].reps = int.tryParse(v) ?? 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline_rounded,
                                size: 22,
                                color: Colors.orangeAccent.withValues(alpha: 0.5),
                              ),
                              onPressed: () => setState(() {
                                if (sets.length > 1) {
                                  sets.removeAt(idx);
                                  weightControllers[idx].dispose();
                                  weightControllers.removeAt(idx);
                                  repsControllers[idx].dispose();
                                  repsControllers.removeAt(idx);
                                }
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        final lastW = sets.isNotEmpty ? sets.last.weight : 0.0;
                        final lastR = sets.isNotEmpty ? sets.last.reps : 0;
                        sets.add(_ExerciseSetData(weight: lastW, reps: lastR));
                        weightControllers.add(
                          TextEditingController(
                            text: lastW == 0 ? '' : lastW.toStringAsFixed(1),
                          ),
                        );
                        repsControllers.add(
                          TextEditingController(
                            text: lastR == 0 ? '' : lastR.toString(),
                          ),
                        );
                      }),
                      icon: const Icon(Icons.add_rounded, color: Colors.orangeAccent),
                      label: const Text(
                        'AGGIUNGI SERIE',
                        style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SALVA MODIFICHE',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniInput extends StatelessWidget {
  const _MiniInput({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.colorScheme.outline,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: '0',
          hintStyle: TextStyle(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? theme.colorScheme.onSurface,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ExerciseSetData {
  _ExerciseSetData({required this.weight, required this.reps});

  double weight;
  int reps;
}
