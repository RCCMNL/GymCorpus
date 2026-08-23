import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

/// Foglio modale per cercare e selezionare uno o piu' esercizi da
/// aggiungere alla routine in WorkoutPage.
class ExercisePickerModal extends StatefulWidget {
  const ExercisePickerModal({
    required this.onConfirm,
    required this.alreadySelected,
    super.key,
  });

  final void Function(List<ExerciseEntity>) onConfirm;
  final List<ExerciseEntity> alreadySelected;

  @override
  State<ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<ExercisePickerModal> {
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
                          .where(
                            (e) =>
                                e.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                e.targetMuscle.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                (e.equipment?.toLowerCase().contains(
                                      _searchQuery.toLowerCase(),
                                    ) ??
                                    false) ||
                                e.categories.any(
                                  (category) => category.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
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
                          final isAlreadyAdded = widget.alreadySelected
                              .contains(ex);
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
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                    : theme.colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected && !isAlreadyAdded
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withValues(
                                          alpha: 0.05,
                                        ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
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
                                            Icon(
                                              Icons.hub_outlined,
                                              size: 12,
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.outline,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isAlreadyAdded
                                                  ? 'GIÀ AGGIUNTO'
                                                  : ex.categories
                                                        .join(' • ')
                                                        .toUpperCase(),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: isSelected
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : theme
                                                              .colorScheme
                                                              .outline,
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
                                        : theme.colorScheme.primary.withValues(
                                            alpha: 0.4,
                                          ),
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
                      shadowColor: theme.colorScheme.primary.withValues(
                        alpha: 0.4,
                      ),
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
