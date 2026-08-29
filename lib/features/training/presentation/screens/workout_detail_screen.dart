import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/quick_exercise_edit_panel.dart';
import 'package:gym_corpus/features/training/presentation/widgets/quick_tip_box.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_detail_header.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_exercise_list_item.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({required this.routine, super.key});

  final RoutineEntity routine;

  void _removeSingleExercise(
    BuildContext context,
    RoutineExerciseEntity exerciseToRemove,
    RoutineEntity currentRoutine,
  ) {
    final updatedList = currentRoutine.exercises
        .where((e) => e.id != exerciseToRemove.id)
        .toList();
    context.read<TrainingBloc>().add(
      UpdateRoutineEvent(
        id: currentRoutine.id,
        title: currentRoutine.title,
        exercises: updatedList,
        estDuration: currentRoutine.estimatedDuration,
      ),
    );
  }

  void _showEditExerciseSheet(
    BuildContext context,
    RoutineExerciseEntity re,
    RoutineEntity currentRoutine,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          QuickExerciseEditPanel(re: re, routine: currentRoutine),
    );
  }

  void _copyRoutine(BuildContext context) {
    context.read<TrainingBloc>().add(CopyRoutineEvent(routine.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Routine copiata in "I tuoi workout"')),
    );
    context.pop();
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Elimina Routine',
          style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
        ),
        content: const Text(
          'Sei sicuro di voler eliminare questa routine? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ANNULLA',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TrainingBloc>().add(DeleteRoutineEvent(routine.id));
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back from detail screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'ELIMINA PERMANENTEMENTE',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
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
        var currentUnit = 'KG';
        if (state is TrainingLoaded) {
          try {
            currentRoutine = state.routines.firstWhere(
              (r) => r.id == routine.id,
            );
          } catch (e) {
            debugPrint('WorkoutDetailScreen routine refresh error: $e');
          }
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
                RoutineDetailHeader(
                  title: currentRoutine.title,
                  exerciseCount: exercises.length,
                  estimatedDuration: currentRoutine.estimatedDuration,
                  isSystem: currentRoutine.isSystem,
                ),
                if (currentRoutine.isSystem) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _copyRoutine(context),
                      icon: const Icon(Icons.content_copy_rounded),
                      label: const Text('COPIA QUESTA ROUTINE'),
                    ),
                  ),
                ],
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
                      return RoutineExerciseListItem(
                        exercise: re,
                        isImperial: isImperial,
                        isReadOnly: currentRoutine.isSystem,
                        onEdit: () =>
                            _showEditExerciseSheet(context, re, currentRoutine),
                        onRemove: () =>
                            _removeSingleExercise(context, re, currentRoutine),
                        onDeleteRoutine: () => _showDeleteDialog(context),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 32),
                // Quick Tip Box
                const QuickTipBox(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
