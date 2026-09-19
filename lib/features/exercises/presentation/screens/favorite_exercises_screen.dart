import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/theme/app_radius.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/widgets/empty_state.dart';
import 'package:gym_corpus/core/widgets/gradient_title.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/skeleton.dart';
import 'package:gym_corpus/features/exercises/domain/equipment_tags.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/difficulty_badge.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_filters_sheet.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_thumbnail.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class FavoriteExercisesScreen extends StatefulWidget {
  const FavoriteExercisesScreen({super.key});

  @override
  State<FavoriteExercisesScreen> createState() =>
      _FavoriteExercisesScreenState();
}

class _FavoriteExercisesScreenState extends State<FavoriteExercisesScreen> {
  String _searchQuery = '';
  String _selectedDifficulty = kAllDifficultiesFilter;
  Set<String> _selectedEquipment = {};

  bool get _hasActiveFilters =>
      _selectedDifficulty != kAllDifficultiesFilter ||
      _selectedEquipment.isNotEmpty;

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            if (state is TrainingLoaded) {
              final favoriteExercises = state.exercises.where((e) {
                final matchesSearch = e.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
                final matchesDifficulty =
                    _selectedDifficulty == kAllDifficultiesFilter ||
                    e.difficulty == _selectedDifficulty;
                final matchesEquipment =
                    _selectedEquipment.isEmpty ||
                    equipmentTagsFor(e).any(_selectedEquipment.contains);
                return e.isFavorite &&
                    matchesSearch &&
                    matchesDifficulty &&
                    matchesEquipment;
              }).toList();

              return Column(
                children: [
                  // Header with back button and title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GradientTitle(
                                'Preferiti',
                                scale: GradientTitleScale.compact,
                              ),
                              Text(
                                'I TUOI ESERCIZI SALVATI',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.5,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh
                                  .withValues(alpha: 0.8),
                              borderRadius: AppRadius.md,
                            ),
                            child: TextField(
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cerca tra i preferiti...',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary,
                                ),
                                // Il riempimento lo disegna il Container che avvolge il campo.
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                  ),

                  Expanded(
                    child: favoriteExercises.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: favoriteExercises.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExerciseTile(
                                  exercise: favoriteExercises[index],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            if (state is TrainingError) {
              return Center(child: Text(state.message));
            }

            return const SkeletonList(rows: 6);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: EmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'Nessun preferito',
          message:
              'Aggiungi esercizi ai preferiti per trovarli '
              'rapidamente qui.',
          action: FilledButton.icon(
            onPressed: () => context.go('/exercises'),
            icon: const Icon(Icons.search),
            label: const Text('Esplora Esercizi'),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});
  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.lg,
      child: InkWell(
        onTap: () {
          context.push('/exercises/detail', extra: exercise);
        },
        borderRadius: AppRadius.lg,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: AppRadius.lg,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              ExerciseThumbnail(exercise: exercise),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lexend',
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 12,
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.equipment?.toUpperCase() ?? 'CORPO LIBERO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (exercise.difficulty != null) ...[
                      const SizedBox(height: 6),
                      DifficultyBadge(difficulty: exercise.difficulty!),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<TrainingBloc>().add(
                    ToggleExerciseFavoriteEvent(
                      exercise.id,
                      isFavorite: !exercise.isFavorite,
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    exercise.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppPalette.coral.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
