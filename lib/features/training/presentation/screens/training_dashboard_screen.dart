import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';

class TrainingDashboardScreen extends StatelessWidget {
  const TrainingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final userName = authState.maybeWhen(
                          authenticated: (user) => user.firstName ?? 'Atleta',
                          orElse: () => 'Atleta',
                        );
                        return _buildHeader(theme, userName);
                      },
                    ),
                    const SizedBox(height: 32),

                    // NEW SECION: Your Routines
                    _buildYourRoutinesSection(context, state, theme),

                    const SizedBox(height: 40),
                    
                    // MOVED SECTION: Dashboard Grid
                    _buildSectionTitle(theme, 'ATTIVITÀ RAPIDA'),
                    const SizedBox(height: 16),
                    _buildDashboardGrid(context, theme),

                    const SizedBox(height: 40),
                    _buildStartWorkoutButton(context, theme),
                    const SizedBox(height: 120), // Extra space for nav bar
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRAINING HUB',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bentornato, $userName',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 2,
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.outline.withValues(alpha: 0.6),
        fontSize: 10,
      ),
    );
  }

  Widget _buildYourRoutinesSection(BuildContext context, TrainingState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'I TUOI ALLENAMENTI'),
        const SizedBox(height: 16),
        if (state is TrainingLoaded && state.routines.isNotEmpty)
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: state.routines.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final routine = state.routines[index];
                return _RoutineCard(
                  routine: routine,
                  onTap: () => context.go('/training/session', extra: routine),
                );
              },
            ),
          )
        else if (state is TrainingLoaded && state.routines.isEmpty)
          _buildEmptyRoutinesPlaceholder(context, theme)
        else
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildEmptyRoutinesPlaceholder(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna routine trovata',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/custom/new'),
            child: const Text('CREA LA TUA PRIMA ROUTINE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _DashboardCard(
          title: 'Yoga & Mindfulness',
          subtitle: 'Trova il tuo equilibrio interiore',
          icon: Icons.self_improvement,
          color: const Color(0xFF8DE8C7),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _DashboardCard(
          title: 'Cardio Training',
          subtitle: 'Brucia calorie e potenzia il cuore',
          icon: Icons.directions_run,
          color: const Color(0xFFFF9494),
          onTap: () => _showCardioSelector(context, theme),
        ),
        const SizedBox(height: 16),
        _DashboardCard(
          title: 'Nutrizione & Dieta',
          subtitle: 'Ottimizza i tuoi risultati a tavola',
          icon: Icons.restaurant,
          color: const Color(0xFFFDE047),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildStartWorkoutButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3367FF), Color(0xFF94AAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3367FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWorkoutSelector(context),
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Text(
              'AVVIA ALLENAMENTO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWorkoutSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _WorkoutSelectorModal(),
    );
  }

  void _showCardioSelector(BuildContext context, ThemeData theme) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(ctx).padding.bottom + 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SCEGLI ATTIVITÀ',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _CardioOptionTile(
                    icon: Icons.directions_run,
                    label: 'Corsa',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/training/cardio', extra: 'run');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CardioOptionTile(
                    icon: Icons.directions_walk,
                    label: 'Camminata',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/training/cardio', extra: 'walk');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutSelectorModal extends StatelessWidget {
  const _WorkoutSelectorModal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = MediaQuery.of(context).size.height * 0.75;
        
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seleziona Workout',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: BlocBuilder<TrainingBloc, TrainingState>(
                  builder: (context, state) {
                    if (state is TrainingLoaded) {
                      final routines = state.routines;
                      if (routines.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fitness_center_outlined,
                                size: 48,
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nessuna routine custom trovata',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.go('/custom/new');
                                },
                                child: const Text('CREA ORA'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        itemCount: routines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return _RoutineCard(
                            routine: routine,
                            horizontal: false,
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/training/session', extra: routine);
                            },
                          );
                        },
                      );
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(60),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.onTap, this.horizontal = true});

  final RoutineEntity routine;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: horizontal ? 240 : double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (horizontal) const Spacer() else const SizedBox(height: 20),
            Text(
              routine.title,
              maxLines: horizontal ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${routine.exercises.length} esercizi',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (routine.estimatedDuration != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${routine.estimatedDuration}m',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardioOptionTile extends StatelessWidget {
  const _CardioOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
