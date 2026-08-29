import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/exercises/domain/exercise_catalog_view.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/difficulty_badge.dart';
import 'package:gym_corpus/features/exercises/presentation/widgets/exercise_filters_sheet.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _searchQuery = '';
  String _selectedMuscle = kAllMusclesFilter;
  String _selectedDifficulty = kAllDifficultiesFilter;
  Set<String> _selectedEquipment = {};
  final Set<String> _expandedCategories = {};

  bool get _hasActiveFilters =>
      _selectedDifficulty != kAllDifficultiesFilter ||
      _selectedEquipment.isNotEmpty;

  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            if (state is TrainingLoaded) {
              final catalog = ExerciseCatalogView.build(
                exercises: state.exercises,
                searchQuery: _searchQuery,
                selectedMuscle: _selectedMuscle,
                selectedDifficulty: _selectedDifficulty,
                selectedEquipment: _selectedEquipment,
              );
              final sections = catalog.sections;
              final grouped = catalog.exercisesBySection;
              final muscleGroups = catalog.muscleGroups;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cerca esercizio...',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: theme.colorScheme.primary,
                                  ),
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
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(width: 12),
                          Material(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/exercises/new'),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Muscle Group Chips
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: muscleGroups.length,
                        itemBuilder: (context, index) {
                          final muscle = muscleGroups[index];
                          final isSelected = _selectedMuscle == muscle;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(muscle),
                              selected: isSelected,
                              onSelected: (val) =>
                                  setState(() => _selectedMuscle = muscle),
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHigh,
                              selectedColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              showCheckmark: false,
                              side: BorderSide.none,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Exercise List (Flattened)
                  ...sections.expand((section) {
                    final exercises = grouped[section] ?? [];
                    // Con un muscolo specifico selezionato la sezione e'
                    // l'unica in vista: mostra subito tutti gli esercizi
                    // invece di richiedere un tap su "TUTTI".
                    final isExpanded =
                        _expandedCategories.contains(section) ||
                        _selectedMuscle == section;
                    final displayedExercises = isExpanded
                        ? exercises
                        : exercises.take(3).toList();
                    // Con il muscolo selezionato la sezione e' gia' sempre
                    // espansa (vedi sopra): il toggle non avrebbe nulla da
                    // fare, quindi non ha senso mostrarlo.
                    final hasMore =
                        exercises.length > 3 && _selectedMuscle != section;

                    return [
                      // Section Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                          child: InkWell(
                            onTap: () => _toggleCategory(section),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.orangeAccent,
                                        Colors.deepOrange,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    section.toUpperCase(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          fontFamily: 'Lexend',
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                ),
                                if (hasMore)
                                  Row(
                                    children: [
                                      Text(
                                        isExpanded
                                            ? 'MENO'
                                            : 'TUTTI (${exercises.length})',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.6),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.6),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Section Items
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ExerciseTile(
                                exercise: displayedExercises[index],
                              ),
                            );
                          }, childCount: displayedExercises.length),
                        ),
                      ),
                    ];
                  }),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }

            if (state is TrainingError) {
              return Center(child: Text(state.message));
            }

            return const Center(child: CircularProgressIndicator());
          },
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          context.push('/exercises/detail', extra: exercise);
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 60,
                  height: 60,
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: exercise.imageUrl != null
                      ? Image.network(
                          exercise.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/placeholder-image.png',
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset(
                          'assets/images/placeholder-image.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
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
                    color: Colors.redAccent.withValues(alpha: 0.8),
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
