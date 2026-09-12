import 'package:flutter/material.dart';
import 'package:gym_corpus/core/widgets/section_title.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

/// Il saluto in cima al Training Hub.
class TrainingHubGreeting extends StatelessWidget {
  const TrainingHubGreeting({required this.userName, super.key});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}

/// Il riquadro delle routine dell'utente, con il pulsante per partire.
///
/// [routines] a `null` significa che stiamo ancora aspettando i dati: e' la
/// distinzione che prima si leggeva a fatica da tre rami su `TrainingState`
/// dentro il `build` della schermata.
class YourRoutinesCard extends StatelessWidget {
  const YourRoutinesCard({
    required this.routines,
    required this.onOpenRoutine,
    required this.onCreateFirst,
    required this.onStartWorkout,
    super.key,
  });

  final List<RoutineEntity>? routines;
  final void Function(RoutineEntity routine) onOpenRoutine;
  final VoidCallback onCreateFirst;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routines = this.routines;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'I TUOI ALLENAMENTI',
            tone: SectionTitleTone.muted,
          ),
          const SizedBox(height: 20),
          if (routines == null)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (routines.isEmpty)
            _EmptyRoutines(onCreateFirst: onCreateFirst)
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: routines.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return RoutineHighlightCard(
                    routine: routine,
                    onTap: () => onOpenRoutine(routine),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          _StartWorkoutButton(onTap: onStartWorkout),
        ],
      ),
    );
  }
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines({required this.onCreateFirst});

  final VoidCallback onCreateFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // Unica azione di questa schermata: un link testuale
          // comunicherebbe "opzionale", qui serve un invito esplicito.
          FilledButton.icon(
            onPressed: onCreateFirst,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('CREA LA TUA PRIMA ROUTINE'),
          ),
        ],
      ),
    );
  }
}

class _StartWorkoutButton extends StatelessWidget {
  const _StartWorkoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              'AVVIA ALLENAMENTO',
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
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
}

/// Le tre attivita' rapide sotto le routine.
class QuickActivityGrid extends StatelessWidget {
  const QuickActivityGrid({
    required this.onCardio,
    required this.onYoga,
    required this.onNutrition,
    super.key,
  });

  final VoidCallback onCardio;
  final VoidCallback onYoga;
  final VoidCallback onNutrition;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DashboardCard(
          title: 'Cardio Training',
          subtitle: 'Brucia calorie e potenzia il cuore',
          icon: Icons.directions_run,
          color: const Color(0xFFFF9494),
          onTap: onCardio,
        ),
        const SizedBox(height: 16),
        _DashboardCard(
          title: 'Yoga & Mindfulness',
          subtitle: 'Trova il tuo equilibrio interiore',
          icon: Icons.self_improvement,
          color: const Color(0xFF8DE8C7),
          isBeta: true,
          onTap: onYoga,
        ),
        const SizedBox(height: 16),
        _DashboardCard(
          title: 'Nutrizione & Dieta',
          subtitle: 'Ottimizza i tuoi risultati a tavola',
          icon: Icons.restaurant,
          color: const Color(0xFFFDE047),
          isBeta: true,
          onTap: onNutrition,
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isBeta = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isBeta;

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
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      if (isBeta) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.colorScheme.tertiary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            'BETA',
                            style: TextStyle(
                              color: theme.colorScheme.tertiary,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
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

class RoutineHighlightCard extends StatelessWidget {
  const RoutineHighlightCard({
    required this.routine,
    required this.onTap,
    this.horizontal = true,
    super.key,
  });

  final RoutineEntity routine;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final tertiary = theme.colorScheme.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: horizontal ? 240 : double.infinity,
        height: horizontal ? 180 : null,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondary.withValues(alpha: 0.2),
              primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: primary.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 80,
                color: primary.withValues(alpha: 0.05),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.bolt_rounded, color: primary, size: 20),
                    ),
                    if (routine.estimatedDuration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${routine.estimatedDuration} MIN',
                          style: TextStyle(
                            color: tertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                  ],
                ),
                if (horizontal) const Spacer() else const SizedBox(height: 24),
                Text(
                  routine.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${routine.exercises.length} ESERCIZI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
