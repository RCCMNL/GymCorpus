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
        title: const Text('Elimina Routine'),
        content: const Text(
            'Sei sicuro di voler eliminare questa routine? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              context.read<TrainingBloc>().add(DeleteRoutineEvent(routine.id));
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back from detail screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentRoutine.title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 36,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'ROUTINE ATTUALE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _HeaderTag(
                              label: '${exercises.length} ESERCIZI',
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.1),
                              textColor: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            _HeaderTag(
                              label:
                                  '${currentRoutine.estimatedDuration ?? "--"} MIN',
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              textColor: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                re.exercise.name,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${setsList.length} serie • ${re.exercise.targetMuscle.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.outline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showEditExerciseSheet(
                                      context,
                                      re,
                                      currentRoutine,
                                    );
                                  } else if (val == 'remove_exercise') {
                                    _removeSingleExercise(
                                      context,
                                      re,
                                      currentRoutine,
                                    );
                                  } else if (val == 'delete_routine') {
                                    _showDeleteDialog(context);
                                  }
                                },
                                icon: const Icon(Icons.more_vert, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_note, size: 18),
                                        SizedBox(width: 12),
                                        Text(
                                          'Modifica esercizio',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove_exercise',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Elimina esercizio',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete_routine',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Elimina intera routine',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                        ),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Text('SERIE ${idx + 1}',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                             ),
                                            const Spacer(),
                                            Text(
                                              isImperial 
                                                ? '${UnitConverter.kgToLb((setData['weight'] as num).toDouble()).toStringAsFixed(1)} LB' 
                                                : '${setData['weight']} KG',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              '${setData['reps']} RIP.',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(
              Icons.bolt,
              size: 100,
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Tip',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Focus on explosive concentric movements and 2-second eccentric phases to maximize hypertrophy and power output for this routine.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
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
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
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
            text: s.weight == 0 ? '' : s.weight.toString(),
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
          content: Text('Esercizio ${widget.re.exercise.name} aggiornato!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Modifica ${widget.re.exercise.name}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...List.generate(sets.length, (idx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniInput(
                              controller: weightControllers[idx],
                              label: (context.read<TrainingBloc>().state is TrainingLoaded && 
                                      (context.read<TrainingBloc>().state as TrainingLoaded).settings['units'] == 'LB') 
                                      ? 'LB' : 'KG',
                              onChanged: (v) =>
                                  sets[idx].weight = double.tryParse(v) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MiniInput(
                              controller: repsControllers[idx],
                              label: 'RIP.',
                              onChanged: (v) =>
                                  sets[idx].reps = int.tryParse(v) ?? 0,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                              color: Colors.grey,
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
                  TextButton.icon(
                    onPressed: () => setState(() {
                      final lastW = sets.last.weight;
                      final lastR = sets.last.reps;
                      sets.add(_ExerciseSetData(weight: lastW, reps: lastR));
                      weightControllers.add(
                        TextEditingController(
                          text: lastW == 0 ? '' : lastW.toString(),
                        ),
                      );
                      repsControllers.add(
                        TextEditingController(
                          text: lastR == 0 ? '' : lastR.toString(),
                        ),
                      );
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('AGGIUNGI SERIE'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'SALVA MODIFICHE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
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
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ExerciseSetData {
  _ExerciseSetData({required this.weight, required this.reps});

  double weight;
  int reps;
}
