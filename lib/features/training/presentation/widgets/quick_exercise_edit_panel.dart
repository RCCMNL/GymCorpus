import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/utils/unit_converter.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/exercise_set.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/mini_input.dart';

/// Foglio modale per modificare rapidamente le serie di un esercizio gia'
/// presente in una routine, senza aprire l'intero editor del workout.
class QuickExerciseEditPanel extends StatefulWidget {
  const QuickExerciseEditPanel({
    required this.re,
    required this.routine,
    super.key,
  });

  final RoutineExerciseEntity re;
  final RoutineEntity routine;

  @override
  State<QuickExerciseEditPanel> createState() => _QuickExerciseEditPanelState();
}

class _QuickExerciseEditPanelState extends State<QuickExerciseEditPanel> {
  late List<ExerciseSet> sets;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> repsControllers;
  bool isSaving = false;

  bool get _isBodyweight => widget.re.exercise.isBodyweight;

  @override
  void initState() {
    super.initState();
    sets = [];
    if (widget.re.setsData != null) {
      try {
        final decoded = jsonDecode(widget.re.setsData!);
        sets = (decoded as List).map((dynamic s) {
          final map = s as Map<String, dynamic>;
          return ExerciseSet(
            weight: (map['weight'] as num).toDouble(),
            reps: map['reps'] as int,
          );
        }).toList();
      } catch (e) {
        debugPrint('WorkoutDetailScreen quick edit parse error: $e');
        sets = [ExerciseSet(weight: 0, reps: 0)];
      }
    }
    if (sets.isEmpty) sets = [ExerciseSet(weight: 0, reps: 0)];

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

  Future<void> _save() async {
    setState(() => isSaving = true);

    final trainingState = context.read<TrainingBloc>().state;
    final settings = trainingState is TrainingLoaded
        ? trainingState.settings
        : <String, String>{};
    final isImperial = (settings['units'] ?? 'KG') == 'LB';

    final setsToSave = sets.map((s) {
      var w = _isBodyweight ? 0.0 : s.weight;
      if (isImperial) w = UnitConverter.lbToKg(w);
      return {'weight': w, 'reps': s.reps};
    }).toList();

    final updatedSetsJson = jsonEncode(setsToSave);

    var firstWeight = _isBodyweight ? 0.0 : sets.first.weight;
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
      AppSnackBar.showSuccess(context, 'Salvataggio completato!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SheetSurface(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.tertiary.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
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
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
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
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
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
                              child: _isBodyweight
                                  ? MiniInput(
                                      controller: repsControllers[idx],
                                      label: 'RIP.',
                                      onChanged: (v) =>
                                          sets[idx].reps = int.tryParse(v) ?? 0,
                                    )
                                  : MiniInput(
                                      controller: weightControllers[idx],
                                      label:
                                          (context.read<TrainingBloc>().state
                                                  is TrainingLoaded &&
                                              (context
                                                              .read<
                                                                TrainingBloc
                                                              >()
                                                              .state
                                                          as TrainingLoaded)
                                                      .settings['units'] ==
                                                  'LB')
                                          ? 'PESO LB'
                                          : 'PESO KG',
                                      onChanged: (v) => sets[idx].weight =
                                          double.tryParse(v) ?? 0,
                                    ),
                            ),
                            if (!_isBodyweight) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: MiniInput(
                                  controller: repsControllers[idx],
                                  label: 'RIP.',
                                  onChanged: (v) =>
                                      sets[idx].reps = int.tryParse(v) ?? 0,
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline_rounded,
                                size: 22,
                                color: Colors.orangeAccent.withValues(
                                  alpha: 0.5,
                                ),
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
                        sets.add(ExerciseSet(weight: lastW, reps: lastR));
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
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.orangeAccent,
                      ),
                      label: const Text(
                        'AGGIUNGI SERIE',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orangeAccent.withValues(
                          alpha: 0.1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.sm,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.lg,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
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
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.lg,
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
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                fontSize: 14,
                              ),
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
