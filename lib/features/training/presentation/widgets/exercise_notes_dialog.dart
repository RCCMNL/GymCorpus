import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/app_dialog.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';

/// Mostra le note personali salvate per [exercise].
///
/// Lo stesso dialogo era scritto due volte, parola per parola: una in
/// ExerciseProgressCard e una in RoutineExerciseListItem. Due copie
/// identiche restano identiche finche' qualcuno non tocca una sola delle
/// due.
Future<void> showExerciseNotesDialog(
  BuildContext context,
  ExerciseEntity exercise,
) {
  final notes = exercise.userNotes?.trim() ?? '';
  final hasNotes = notes.isNotEmpty;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return AppDialog(
        title: 'Le tue note',
        icon: Icons.notes_rounded,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'CHIUDI',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
        child: Text(
          hasNotes
              ? notes
              : 'Nessuna nota presente per questo esercizio.\n\n'
                    'Puoi aggiungere appunti dalla schermata dei dettagli '
                    "dell'esercizio.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasNotes
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
            fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      );
    },
  );
}
