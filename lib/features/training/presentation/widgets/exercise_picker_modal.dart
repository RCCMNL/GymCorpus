import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/features/exercises/domain/equipment_tags.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/difficulty_badge.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_filters_sheet.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_thumbnail.dart';
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
  String _selectedDifficulty = kAllDifficultiesFilter;
  Set<String> _selectedEquipment = {};
  final List<ExerciseEntity> _tempSelected = [];

  bool get _hasActiveFilters =>
      _selectedDifficulty != kAllDifficultiesFilter ||
      _selectedEquipment.isNotEmpty;

  void _toggleExercise(ExerciseEntity ex) {
    setState(() {
      if (_tempSelected.contains(ex)) {
        _tempSelected.remove(ex);
      } else {
        _tempSelected.add(ex);
      }
    });
  }

  Future<void> _openFilters() async {
    final result = await showExerciseFiltersSheet(
      context,
      initialDifficulty: _selectedDifficulty,
      initialEquipment: _selectedEquipment,
    );
    if (result != null) {
      setState(() {
        _selectedDifficulty = result.difficulty;
        _selectedEquipment = result.equipment;
      });
    }
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
        body: SheetSurface(
          gap: 0,
          child: Column(
            children: [
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Cerca per nome o muscolo...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHigh,
                              border: const OutlineInputBorder(
                                borderRadius: AppRadius.md,
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: AppRadius.md,
                          child: InkWell(
                            borderRadius: AppRadius.md,
                            onTap: _openFilters,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Badge(
                                isLabelVisible: _hasActiveFilters,
                                smallSize: 8,
                                backgroundColor: theme.colorScheme.primary,
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      final filtered = state.exercises.where((e) {
                        final matchesSearch =
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
                            );
                        final matchesDifficulty =
                            _selectedDifficulty == kAllDifficultiesFilter ||
                            e.difficulty == _selectedDifficulty;
                        final matchesEquipment =
                            _selectedEquipment.isEmpty ||
                            equipmentTagsFor(
                              e,
                            ).any(_selectedEquipment.contains);
                        return matchesSearch &&
                            matchesDifficulty &&
                            matchesEquipment;
                      }).toList();

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
                            borderRadius: AppRadius.md,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected && !isAlreadyAdded
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                    : theme.colorScheme.surfaceContainerHigh,
                                borderRadius: AppRadius.md,
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
                                  ExerciseThumbnail(
                                    exercise: ex,
                                    borderRadius: AppRadius.sm,
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
                                            // L'elenco delle categorie puo'
                                            // essere lungo quanto vuole:
                                            // qui cede invece di uscire.
                                            Expanded(
                                              child: Text(
                                                isAlreadyAdded
                                                    ? 'GIÀ AGGIUNTO'
                                                    : ex.categories
                                                          .join(' • ')
                                                          .toUpperCase(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: isSelected
                                                          ? theme
                                                                .colorScheme
                                                                .primary
                                                          : theme
                                                                .colorScheme
                                                                .outline,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 10,
                                                      letterSpacing: 0.5,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (ex.difficulty != null) ...[
                                          const SizedBox(height: 6),
                                          DifficultyBadge(
                                            difficulty: ex.difficulty!,
                                          ),
                                        ],
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
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lg,
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
