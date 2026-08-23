import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/exercise_set.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/set_input_cell.dart';

/// Card espandibile per un esercizio selezionato in WorkoutPage: elenco
/// delle serie modificabili, aggiunta/rimozione serie e riordino.
class SelectedExerciseTile extends StatefulWidget {
  const SelectedExerciseTile({
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
  State<SelectedExerciseTile> createState() => _SelectedExerciseTileState();
}

class _SelectedExerciseTileState extends State<SelectedExerciseTile> {
  late List<ExerciseSet> sets;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;
  bool isCollapsed = true;

  bool get _isBodyweight => widget.exercise.exercise.isBodyweight;

  @override
  void initState() {
    super.initState();
    sets = [];
    if (widget.exercise.setsData != null) {
      try {
        final decoded = jsonDecode(widget.exercise.setsData!) as List<dynamic>;
        sets = decoded.map((dynamic s) {
          final map = s as Map<String, dynamic>;
          return ExerciseSet(
            weight: (map['weight'] as num).toDouble(),
            reps: map['reps'] as int,
          );
        }).toList();
      } catch (e) {
        debugPrint('WorkoutPage _SelectedExerciseTile init error: $e');
        sets = [ExerciseSet(weight: 0, reps: 0)];
      }
    }

    if (sets.isEmpty) {
      sets = [ExerciseSet(weight: 0, reps: 0)];
    }

    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    if (isImperial) {
      for (final s in sets) {
        s.weight = UnitConverter.kgToLb(s.weight);
      }
    }

    if (_isBodyweight) {
      for (final s in sets) {
        s.weight = 0;
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
          (s) =>
              TextEditingController(text: s.reps == 0 ? '' : s.reps.toString()),
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
        TextEditingController(text: lastReps == 0 ? '' : lastReps.toString()),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1.5,
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
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
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
                        overflow: TextOverflow
                            .visible, // Permettiamo al nome di respirare
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: widget.onRemove,
                        child: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error.withValues(alpha: 0.8),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.reorder_rounded,
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.8,
                          ),
                          size: 18,
                        ),
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
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(sets.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _isBodyweight
                                ? SetInputCell(
                                    controller: repsControllers[index],
                                    label: 'REPS',
                                    onChanged: (v) {
                                      sets[index].reps = int.tryParse(v) ?? 0;
                                      widget.onSetsUpdated(sets);
                                    },
                                  )
                                : SetInputCell(
                                    controller: weightControllers[index],
                                    label:
                                        (context.read<TrainingBloc>().state
                                                is TrainingLoaded &&
                                            (context.read<TrainingBloc>().state
                                                        as TrainingLoaded)
                                                    .settings['units'] ==
                                                'LB')
                                        ? 'LB'
                                        : 'KG',
                                    onChanged: (v) {
                                      sets[index].weight =
                                          double.tryParse(v) ?? 0;
                                      widget.onSetsUpdated(sets);
                                    },
                                  ),
                          ),
                          if (!_isBodyweight) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: SetInputCell(
                                controller: repsControllers[index],
                                label: 'REPS',
                                onChanged: (v) {
                                  sets[index].reps = int.tryParse(v) ?? 0;
                                  widget.onSetsUpdated(sets);
                                },
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeSet(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _addSet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AGGIUNGI UNA SERIE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
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
