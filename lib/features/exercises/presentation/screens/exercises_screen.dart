import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _searchQuery = '';
  String _selectedMuscle = 'Tutti';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cerca esercizi...',
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.outline),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Muscle Group Chips (Horizontal Scroll)
            BlocBuilder<TrainingBloc, TrainingState>(
              builder: (context, state) {
                if (state is TrainingLoaded) {
                  final muscleGroups = ['Tutti', 'Preferiti', ...{for (final e in state.exercises) e.targetMuscle}.toList()..sort()];
                  return SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: muscleGroups.length,
                      itemBuilder: (context, index) {
                        final muscle = muscleGroups[index];
                        final isSelected = _selectedMuscle == muscle;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(muscle),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedMuscle = muscle),
                            backgroundColor: theme.colorScheme.surfaceContainerHigh,
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            showCheckmark: false,
                            side: BorderSide.none,
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 8),

            // Exercise List
            Expanded(
              child: BlocBuilder<TrainingBloc, TrainingState>(
                builder: (context, state) {
                  if (state is TrainingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TrainingLoaded) {
                    final filteredExercises = state.exercises.where((e) {
                      final matchesSearch = e.name.toLowerCase().contains(_searchQuery.toLowerCase());
                      if (_selectedMuscle == 'Preferiti' && !e.isFavorite) return false;
                      final matchesMuscle = _selectedMuscle == 'Tutti' || _selectedMuscle == 'Preferiti' || e.targetMuscle == _selectedMuscle;
                      return matchesSearch && matchesMuscle;
                    }).toList();

                    if (filteredExercises.isEmpty) {
                      return Center(
                        child: Text(
                          'Nessun esercizio trovato',
                          style: TextStyle(color: theme.colorScheme.outline),
                        ),
                      );
                    }

                    // Grouping for the list view
                    final grouped = <String, List<ExerciseEntity>>{};
                    for (final ex in filteredExercises) {
                      grouped.putIfAbsent(ex.targetMuscle, () => []).add(ex);
                    }
                    final sections = grouped.keys.toList()..sort();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        final section = sections[index];
                        final exercises = grouped[section]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      section,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Vedi tutti ${exercises.length}',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...exercises.map((e) => _ExerciseTile(exercise: e)),
                          ],
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
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/exercises/detail', extra: exercise),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, size: 32, color: Color(0xFF94AAFF)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.home_outlined, size: 14, color: theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.equipment ?? 'Corpo libero',
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
