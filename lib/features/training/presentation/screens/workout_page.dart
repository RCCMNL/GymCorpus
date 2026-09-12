import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/icon_badge.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/services/routine_draft.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/exercise_picker_modal.dart';
import 'package:gym_corpus/features/training/presentation/widgets/selected_exercise_tile.dart';

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
    _nameController = TextEditingController(
      text: widget.routineToEdit?.title ?? '',
    );
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
    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};

    final draft = RoutineDraft(
      name: _nameController.text,
      exercises: _selectedExercises,
      useImperialUnits: (settings['units'] ?? 'KG') == 'LB',
    );

    final problem = draft.problem;
    if (problem != null) {
      _showDraftProblem(problem);
      return;
    }

    final routineToEdit = widget.routineToEdit;
    context.read<TrainingBloc>().add(
      routineToEdit != null
          ? UpdateRoutineEvent(
              id: routineToEdit.id,
              title: draft.normalizedName,
              exercises: draft.exercisesToSave(),
              estDuration: routineToEdit.estimatedDuration,
            )
          : AddRoutineEvent(
              title: draft.normalizedName,
              exercises: draft.exercisesToSave(),
            ),
    );

    context.pop();
  }

  void _showDraftProblem(RoutineDraftProblem problem) {
    final (message, icon) = switch (problem) {
      RoutineDraftProblem.missingName => (
        'Inserisci il nome del tuo workout',
        Icons.warning_amber_rounded,
      ),
      RoutineDraftProblem.noExercises => (
        'Aggiungi almeno un esercizio',
        Icons.fitness_center_rounded,
      ),
    };

    AppSnackBar.show(
      context,
      message,
      tone: AppSnackBarTone.warning,
      icon: icon,
    );
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
                              widget.routineToEdit != null
                                  ? 'Modifica workout'
                                  : 'Nuovo workout',
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
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        cursorColor: theme.colorScheme.primary,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Lexend',
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nome del tuo workout',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          // Il riempimento lo disegna il Container che avvolge il campo.
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ),
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
                            const SectionTitle('PIANO ESERCIZI'),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_selectedExercises.length} ESERCIZI',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showExercisePicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AGGIUNGI',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
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
                              const IconBadge(
                                Icons.fitness_center_rounded,
                                size: IconBadgeSize.large,
                                circle: true,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Nessun esercizio',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aggiungi il tuo primo esercizio premendo\nil tasto in alto a destra.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
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
                          final stableKey = ValueKey(
                            'exercise_${re.exercise.id}_$index',
                          );

                          return SelectedExerciseTile(
                            key: stableKey,
                            exercise: re,
                            index: index,
                            onRemove: () => _removeExercise(index),
                            onSetsUpdated: (newSets) {
                              setState(() {
                                if (newSets.isNotEmpty) {
                                  _selectedExercises[index] =
                                      RoutineExerciseEntity(
                                        id: re.id,
                                        routineId: re.routineId,
                                        exercise: re.exercise,
                                        sets: newSets.length,
                                        reps: newSets.first.reps,
                                        weight: newSets.first.weight,
                                        orderIndex: re.orderIndex,
                                        setsData: jsonEncode(
                                          newSets
                                              .map(
                                                (s) => {
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _saveRoutine,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SALVA WORKOUT',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
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
            ]),
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
      builder: (context) => ExercisePickerModal(
        onConfirm: _addExercises,
        alreadySelected: _selectedExercises.map((e) => e.exercise).toList(),
      ),
    );
  }
}
