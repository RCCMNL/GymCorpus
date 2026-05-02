import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
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
  String _selectedMuscle = 'Tutti';
  final Set<String> _expandedCategories = {};

  void _toggleCategory(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
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
              // Filtering
              final filteredExercises = state.exercises.where((e) {
                final search = _searchQuery.toLowerCase();
                final matchesSearch = e.name.toLowerCase().contains(search) ||
                    (e.equipment?.toLowerCase().contains(search) ?? false) ||
                    e.categories.any(
                      (category) => category.toLowerCase().contains(search),
                    );
                final matchesMuscle = _selectedMuscle == 'Tutti' ||
                    (_selectedMuscle == 'Preferiti' && e.isFavorite) ||
                    e.categories.contains(_selectedMuscle);
                return matchesSearch && matchesMuscle;
              }).toList();

              // Grouping
              final grouped = <String, List<ExerciseEntity>>{};
              for (final ex in filteredExercises) {
                final categories =
                    _selectedMuscle == 'Tutti' || _selectedMuscle == 'Preferiti'
                        ? ex.categories
                        : ex.categories.where((c) => c == _selectedMuscle);

                for (final category in categories) {
                  final section = category.isEmpty ? 'Altro' : category;
                  grouped.putIfAbsent(section, () => []).add(ex);
                }
              }
              final sections = grouped.keys.toList()..sort();

              // Muscle groups for the horizontal selector
              final muscleGroups = [
                'Tutti',
                'Preferiti',
                ...state.exercises
                    .expand((e) => e.categories)
                    .where((m) => m.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort(),
              ];

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Cerca esercizio...',
                            hintStyle: TextStyle(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.6)),
                            prefixIcon: Icon(Icons.search,
                                color: theme.colorScheme.primary),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
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
                                  borderRadius: BorderRadius.circular(24)),
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
                    final isExpanded = _expandedCategories.contains(section);
                    final displayedExercises =
                        isExpanded ? exercises : exercises.take(3).toList();
                    final hasMore = exercises.length > 3;

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
                                        Colors.deepOrange
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    section.toUpperCase(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
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
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExerciseTile(
                                    exercise: displayedExercises[index]),
                              );
                            },
                            childCount: displayedExercises.length,
                          ),
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
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
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
                        Icon(Icons.bolt,
                            size: 12,
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.equipment?.toUpperCase() ?? 'CORPO LIBERO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
                  padding: const EdgeInsets.all(8.0),
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
