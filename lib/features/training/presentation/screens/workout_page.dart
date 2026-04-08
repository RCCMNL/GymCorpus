import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({this.routineToEdit, super.key});

  final RoutineEntity? routineToEdit;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late final TextEditingController _nameController;
  final List<RoutineExerciseEntity> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routineToEdit?.title ?? '');
    if (widget.routineToEdit != null) {
      _selectedExercises.addAll(widget.routineToEdit!.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _saveRoutine() {
    var routineName = _nameController.text.trim();
    if (routineName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Inserisci il nome della routine',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    if (routineName.isNotEmpty) {
      routineName = routineName[0].toUpperCase() + routineName.substring(1);
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.fitness_center_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aggiungi almeno un esercizio',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Lexend', fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded ? trainingState.settings : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    // Se siamo in imperiale, riconvertiamo tutto in KG per il database
    final exercisesToSave = _selectedExercises.map((re) {
      if (!isImperial) return re;
      
      List<dynamic> setsList = [];
      try {
        setsList = jsonDecode(re.setsData!) as List<dynamic>;
        final convertedSets = setsList.map((s) {
          final w = (s['weight'] as num).toDouble();
          return {
            'weight': UnitConverter.lbToKg(w),
            'reps': s['reps'],
          };
        }).toList();
        
        return re.copyWith(
          weight: UnitConverter.lbToKg(re.weight),
          setsData: jsonEncode(convertedSets),
        );
      } catch (_) {
        return re;
      }
    }).toList();

    if (widget.routineToEdit != null) {
      context.read<TrainingBloc>().add(
            UpdateRoutineEvent(
              id: widget.routineToEdit!.id,
              title: routineName,
              exercises: exercisesToSave,
              estDuration: widget.routineToEdit!.estimatedDuration,
            ),
          );
    } else {
      context.read<TrainingBloc>().add(
            AddRoutineEvent(
              title: routineName,
              exercises: exercisesToSave,
            ),
          );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.routineToEdit != null ? 'Modifica Routine' : 'Nuova Routine',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.mode_edit_outline,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Routine Title Input Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          cursorColor: theme.colorScheme.primary,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Lexend',
                            fontSize: 28,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nome workout',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Aesthetic Underline
                        Container(
                          height: 2,
                          width: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Exercises Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PIANO ESERCIZI',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_selectedExercises.length} esercizi aggiunti',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () => _showExercisePicker(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Aggiungi',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            foregroundColor: theme.colorScheme.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (_selectedExercises.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.fitness_center_outlined,
                                size: 48,
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nessun esercizio aggiunto',
                                style:
                                    TextStyle(color: theme.colorScheme.outline),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedExercises.length,
                        onReorder: (oldIndex, originalNewIndex) {
                          var newIndex = originalNewIndex;
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _selectedExercises.removeAt(oldIndex);
                            _selectedExercises.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final re = _selectedExercises[index];
                          // Usiamo una chiave stabile basata sulla posizione iniziale o ID univoco
                          // per evitare che la scheda venga distrutta quando cambiano i dati interni
                          final stableKey = ValueKey('exercise_${re.exercise.id}_$index');
                          
                          return _SelectedExerciseTile(
                            key: stableKey,
                            exercise: re,
                            index: index,
                            onRemove: () => _removeExercise(index),
                            onSetsUpdated: (newSets) {
                              setState(() {
                                if (newSets.isNotEmpty) {
                                  _selectedExercises[index] = RoutineExerciseEntity(
                                    id: re.id,
                                    routineId: re.routineId,
                                    exercise: re.exercise,
                                    sets: newSets.length,
                                    reps: newSets.first.reps,
                                    weight: newSets.first.weight,
                                    orderIndex: re.orderIndex,
                                    setsData: jsonEncode(
                                      newSets
                                          .map((s) => {
                                                'weight': s.weight,
                                                'reps': s.reps,
                                                },
                                              )
                                          .toList(),
                                    ),
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'SALVA ROUTINE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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

  void _addExercises(List<ExerciseEntity> exercises) {
    setState(() {
      for (final ex in exercises) {
        // Prevent adding same exercise multiple times in the same batch if not desired
        // but user might want it, so we add all
        _selectedExercises.add(
          RoutineExerciseEntity(
            id: 0,
            routineId: 0,
            exercise: ex,
            sets: 3,
            reps: 0,
            weight: 0,
            orderIndex: _selectedExercises.length,
            setsData: jsonEncode([
              {'weight': 0, 'reps': 0},
            ],),
          ),
        );
      }
    });
  }

  void _showExercisePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExercisePickerModal(
        onConfirm: _addExercises,
        alreadySelected: _selectedExercises.map((e) => e.exercise).toList(),
      ),
    );
  }
}

class _SelectedExerciseTile extends StatefulWidget {
  const _SelectedExerciseTile({
    required this.exercise,
    required this.onRemove,
    required this.onSetsUpdated,
    required this.index,
    super.key,
  });

  final RoutineExerciseEntity exercise;
  final VoidCallback onRemove;
  final void Function(List<ExerciseSet>) onSetsUpdated;
  final int index;

  @override
  State<_SelectedExerciseTile> createState() => _SelectedExerciseTileState();
}

class _SelectedExerciseTileState extends State<_SelectedExerciseTile> {
  late List<ExerciseSet> sets;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;
  bool isCollapsed = false;

  @override
  void initState() {
    super.initState();
    sets = [];
    if (widget.exercise.setsData != null) {
      try {
        final decoded =
            jsonDecode(widget.exercise.setsData!) as List<dynamic>;
        sets = decoded
            .map((dynamic s) {
              final map = s as Map<String, dynamic>;
              return ExerciseSet(
                weight: (map['weight'] as num).toDouble(),
                reps: map['reps'] as int,
              );
            })
            .toList();
      } catch (e) {
        sets = [ExerciseSet(weight: 0, reps: 0)];
      }
    }
    
    if (sets.isEmpty) {
      sets = [ExerciseSet(weight: 0, reps: 0)];
    }

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
        .map((s) => TextEditingController(text: s.weight == 0 ? '' : s.weight.toStringAsFixed(1)))
        .toList();
    repsControllers = sets
        .map((s) => TextEditingController(text: s.reps == 0 ? '' : s.reps.toString()))
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

  void _addSet() {
    setState(() {
      final lastWeight = sets.last.weight;
      final lastReps = sets.last.reps;
      sets.add(ExerciseSet(weight: lastWeight, reps: lastReps));
      weightControllers.add(
        TextEditingController(
          text: lastWeight == 0 ? '' : lastWeight.toStringAsFixed(1),
        ),
      );
      repsControllers.add(
        TextEditingController(
          text: lastReps == 0 ? '' : lastReps.toString(),
        ),
      );
      widget.onSetsUpdated(sets);
    });
  }

  void _removeSet(int index) {
    if (sets.length <= 1) return;
    setState(() {
      sets.removeAt(index);
      weightControllers[index].dispose();
      weightControllers.removeAt(index);
      repsControllers[index].dispose();
      repsControllers.removeAt(index);
      widget.onSetsUpdated(sets);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          // Header Esercizio
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isCollapsed = !isCollapsed),
                  child: AnimatedRotation(
                    turns: isCollapsed ? -0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible, // Permettiamo al nome di respirare
                      ),
                      Text(
                        '${sets.length} serie',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error.withValues(alpha: 0.6),
                        size: 22,
                      ),
                      onPressed: widget.onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Icon(
                        Icons.reorder,
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Corpo Espandibile (Serie)
          if (!isCollapsed) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1, thickness: 0.5, color: Colors.white10),
                  const SizedBox(height: 16),
                  ...List.generate(sets.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
                                '${index + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SetInputCell(
                              controller: weightControllers[index],
                              label: (context.read<TrainingBloc>().state is TrainingLoaded && 
                                      (context.read<TrainingBloc>().state as TrainingLoaded).settings['units'] == 'LB') 
                                      ? 'LB' : 'KG',
                              onChanged: (v) {
                                sets[index].weight = double.tryParse(v) ?? 0;
                                widget.onSetsUpdated(sets);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SetInputCell(
                              controller: repsControllers[index],
                              label: 'RIP.',
                              onChanged: (v) {
                                sets[index].reps = int.tryParse(v) ?? 0;
                                widget.onSetsUpdated(sets);
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.close, size: 18, color: theme.colorScheme.error.withValues(alpha: 0.4)),
                            onPressed: () => _removeSet(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addSet,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'AGGIUNGI UNA SERIE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SetInputCell extends StatelessWidget {
  const _SetInputCell({
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '-',
                hintStyle: TextStyle(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              fontWeight: FontWeight.w900,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseSet {
  ExerciseSet({required this.weight, required this.reps});

  double weight;
  int reps;
}

class _ExercisePickerModal extends StatefulWidget {
  const _ExercisePickerModal({
    required this.onConfirm,
    required this.alreadySelected,
  });

  final void Function(List<ExerciseEntity>) onConfirm;
  final List<ExerciseEntity> alreadySelected;

  @override
  State<_ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<_ExercisePickerModal> {
  String _searchQuery = '';
  final List<ExerciseEntity> _tempSelected = [];

  void _toggleExercise(ExerciseEntity ex) {
    setState(() {
      if (_tempSelected.contains(ex)) {
        _tempSelected.remove(ex);
      } else {
        _tempSelected.add(ex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
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
                child: Column(
                  children: [
                    Text(
                      'Scegli Esercizi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cerca per nome o muscolo...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<TrainingBloc, TrainingState>(
                  builder: (context, state) {
                    if (state is TrainingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is TrainingLoaded) {
                      final filtered = state.exercises
                          .where((e) =>
                              e.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              e.targetMuscle.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                              )
                          .toList();

                      return ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ex = filtered[index];
                          final isAlreadyAdded =
                              widget.alreadySelected.contains(ex);
                          final isSelected =
                              _tempSelected.contains(ex) || isAlreadyAdded;

                          return InkWell(
                            onTap: isAlreadyAdded
                                ? null
                                : () => _toggleExercise(ex),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected && !isAlreadyAdded
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.1)
                                    : theme.colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected && !isAlreadyAdded
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.fitness_center,
                                        size: 24,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : const Color(0xFF94AAFF),
                                      ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ex.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isAlreadyAdded
                                                      ? theme.colorScheme.outline
                                                      : null,
                                                ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.hub_outlined,
                                                size: 12,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.outline,
                                              ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isAlreadyAdded
                                                  ? 'GIÀ AGGIUNTO'
                                                  : ex.targetMuscle
                                                      .toUpperCase(),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.outline,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 10,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isAlreadyAdded
                                        ? Icons.check_circle
                                        : (isSelected
                                            ? Icons.check_circle
                                            : Icons.add_circle),
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary
                                            .withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _tempSelected.isEmpty
            ? null
            : SafeArea(
                child: Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    10,
                  ), // Spazio generoso per la navbar
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 8,
                      shadowColor:
                          theme.colorScheme.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'AGGIUNGI ${_tempSelected.length} ESERCIZI',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
