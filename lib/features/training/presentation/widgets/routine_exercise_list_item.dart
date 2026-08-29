import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

/// Card di un esercizio della routine in WorkoutDetailScreen: nome, tag
/// serie/muscolo, menu di azioni (modifica/rimuovi/elimina routine) ed
/// elenco delle serie configurate.
class RoutineExerciseListItem extends StatelessWidget {
  const RoutineExerciseListItem({
    required this.exercise,
    required this.isImperial,
    this.onEdit,
    this.onRemove,
    this.onDeleteRoutine,
    this.isReadOnly = false,
    super.key,
  });

  final RoutineExerciseEntity exercise;
  final bool isImperial;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onDeleteRoutine;

  /// Le routine di sistema non si possono modificare/eliminare: nasconde
  /// il menu azioni, lasciando solo la nota informativa dell'esercizio.
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final re = exercise;

    var setsList = <dynamic>[];
    if (re.setsData != null) {
      try {
        setsList = jsonDecode(re.setsData!) as List<dynamic>;
      } catch (e) {
        debugPrint('WorkoutDetailScreen sets parse error: $e');
        setsList = [];
      }
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: re.exercise.imageUrl != null
                    ? Image.network(
                        re.exercise.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.fitness_center_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      )
                    : Icon(
                        Icons.fitness_center_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
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
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${setsList.length} SERIE',
                      style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      re.exercise.targetMuscle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () =>
                      _showNotesDialog(context, re.exercise, theme),
                ),
                if (!isReadOnly)
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        onEdit?.call();
                      } else if (val == 'remove_exercise') {
                        onRemove?.call();
                      } else if (val == 'delete_routine') {
                        onDeleteRoutine?.call();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: theme.colorScheme.surfaceContainerHigh,
                    elevation: 8,
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Text(
                                'Modifica serie',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'remove_exercise',
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_circle_outline_rounded,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Rimuovi esercizio',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete_routine',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever_rounded,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Elimina routine',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (setsList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...setsList.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final setData = entry.value as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: idx.isEven
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
                                '${idx + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!re.exercise.isBodyweight)
                                  Row(
                                    children: [
                                      Text(
                                        isImperial
                                            ? UnitConverter.kgToLb(
                                                (setData['weight'] as num)
                                                    .toDouble(),
                                              ).toStringAsFixed(1)
                                            : (setData['weight'] as num)
                                                  .toDouble()
                                                  .toStringAsFixed(1),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
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
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Text(
                                      '${setData['reps']}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
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
                              ],
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
  }
}

void _showNotesDialog(
  BuildContext context,
  ExerciseEntity exercise,
  ThemeData theme,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.notes_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Le tue note',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          (exercise.userNotes != null && exercise.userNotes!.trim().isNotEmpty)
              ? exercise.userNotes!
              : "Nessuna nota presente per questo esercizio.\n\nPuoi aggiungere appunti dalla schermata dei dettagli dell'esercizio.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                (exercise.userNotes != null &&
                    exercise.userNotes!.trim().isNotEmpty)
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
            fontStyle:
                (exercise.userNotes != null &&
                    exercise.userNotes!.trim().isNotEmpty)
                ? FontStyle.normal
                : FontStyle.italic,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CHIUDI',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      );
    },
  );
}
