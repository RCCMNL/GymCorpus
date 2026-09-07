import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/confirm_dialog.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_detail_header.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_guide.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({required this.exercise, super.key});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleActionButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Column(
          children: [
            Text(
              'GYM CORPUS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Dettagli Esercizio',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [_ExerciseActions(exercise: exercise)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExerciseHero(exercise: exercise),
            ExerciseGuide(exercise: exercise),
          ],
        ),
      ),
    );
  }
}

/// Le azioni della barra: modifica ed elimina solo per gli esercizi
/// dell'utente, il cuore per tutti.
///
/// Ha un BlocBuilder suo perche' il cuore deve aggiornarsi da solo: e'
/// l'unica parte della schermata che cambia dopo il primo disegno.
class _ExerciseActions extends StatelessWidget {
  const _ExerciseActions({required this.exercise});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        final current = state is TrainingLoaded
            ? state.exercises.firstWhere(
                (e) => e.id == exercise.id,
                orElse: () => exercise,
              )
            : exercise;
        final isFavorite = current.isFavorite;

        return Row(
          children: [
            if (current.isCustom) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleActionButton(
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      context.push('/exercises/edit', extra: current),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleActionButton(
                  icon: Icons.delete_outline,
                  onPressed: () =>
                      unawaited(_confirmExerciseDeletion(context, current)),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleActionButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_outline,
                onPressed: () => context.read<TrainingBloc>().add(
                  ToggleExerciseFavoriteEvent(
                    exercise.id,
                    isFavorite: !isFavorite,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _confirmExerciseDeletion(
  BuildContext context,
  ExerciseEntity exercise,
) async {
  final bloc = context.read<TrainingBloc>();
  final navigator = Navigator.of(context);

  final confirmed = await ConfirmDialog.ask(
    context,
    title: 'Elimina esercizio?',
    message:
        'Sei sicuro di voler eliminare "${exercise.name}"? Se è usato in una '
        'routine o in uno storico allenamento non potrà essere eliminato.',
  );

  if (!confirmed) return;

  bloc.add(DeleteCustomExerciseEvent(exercise.id));
  navigator.pop();
}
