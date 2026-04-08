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
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Cerca esercizi...',
                    hintStyle: TextStyle(color: theme.colorScheme.outline.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                        final exercises = grouped[section] ?? [];
                        final isExpanded = _expandedCategories.contains(section);
                        final displayedExercises = isExpanded ? exercises : exercises.take(3).toList();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 24),
                              child: InkWell(
                                onTap: () => _toggleCategory(section),
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.orangeAccent, Colors.deepOrange],
                                              ),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: ShaderMask(
                                              shaderCallback: (bounds) => LinearGradient(
                                                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                                              ).createShader(bounds),
                                              child: Text(
                                                section,
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 22,
                                                  fontFamily: 'Lexend',
                                                  color: Colors.white,
                                                  letterSpacing: -0.5,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (exercises.length > 3) ...[
                                      const SizedBox(width: 8),
                                      Row(
                                        children: [
                                          Text(
                                            isExpanded ? 'MOSTRA MENO' : 'VEDI TUTTI ${exercises.length}',
                                            style: TextStyle(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                            size: 14,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Text(
                                        '${exercises.length} ESERCIZI',
                                        style: TextStyle(
                                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            ...displayedExercises.map((e) => _ExerciseTile(exercise: e)),
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surfaceContainerHigh,
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fitness_center_rounded, 
                  size: 28, 
                  color: exercise.targetMuscle.contains('Petto') 
                      ? Colors.orangeAccent 
                      : (exercise.targetMuscle.contains('Schiena') ? theme.colorScheme.tertiary : theme.colorScheme.primary)
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
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 12, color: Colors.orangeAccent),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              exercise.equipment?.toUpperCase() ?? 'CORPO LIBERO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.orangeAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
