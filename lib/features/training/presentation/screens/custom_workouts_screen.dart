import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/app_snack_bar.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/routine_card.dart';

class CustomWorkoutsScreen extends StatefulWidget {
  const CustomWorkoutsScreen({super.key});

  @override
  State<CustomWorkoutsScreen> createState() => _CustomWorkoutsScreenState();
}

class _CustomWorkoutsScreenState extends State<CustomWorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrainingBloc>().add(LoadRoutinesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GymHeader(),
      body: SafeArea(
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            if (state is TrainingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TrainingLoaded) {
              final systemRoutines = state.routines
                  .where((r) => r.isSystem)
                  .toList();
              final routines = state.routines
                  .where((r) => !r.isSystem)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'I tuoi workout',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lexend',
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Protocolli di allenamento personalizzati',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${routines.length} WORKOUTS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => context.push('/custom/new'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'NUOVO',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Routine consigliate (di sistema): uguali per tutti,
                    // avviabili subito, copiabili ma non modificabili.
                    if (systemRoutines.isNotEmpty) ...[
                      Text(
                        'Routine consigliate',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: systemRoutines.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final routine = systemRoutines[index];
                          return _SystemRoutineCard(
                            routine: routine,
                            color: index.isEven
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Workouts List
                    if (routines.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 60,
                            horizontal: 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit_document,
                                  size: 48,
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nessun workout creato',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Lexend',
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tocca il pulsante "NUOVO" in alto per creare il tuo primo protocollo di allenamento personalizzato.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: routines.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return _WorkoutCard(
                            routine: routine,
                            color: index.isEven
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary,
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // Rimosso vecchio pulsante Create Workout in basso
                    const SizedBox(height: 100), // Space for Nav
                  ],
                ),
              );
            }
            return _WorkoutsLoadError(
              message: state is TrainingError
                  ? state.message
                  : 'Non e stato possibile caricare i tuoi workout.',
              onRetry: () =>
                  context.read<TrainingBloc>().add(LoadRoutinesEvent()),
            );
          },
        ),
      ),
    );
  }
}

/// Mostrato quando le routine non sono disponibili: senza questo la schermata
/// restava completamente bianca, senza spiegazione ne modo di riprovare.
class _WorkoutsLoadError extends StatelessWidget {
  const _WorkoutsLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.routine, required this.color});

  final RoutineEntity routine;
  final Color color;

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Elimina workout?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Sei sicuro di voler eliminare "${routine.title}"? Questa azione non può essere annullata.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ANNULLA',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TrainingBloc>().add(DeleteRoutineEvent(routine.id));
              Navigator.pop(context);
              AppSnackBar.show(
                context,
                'Workout "${routine.title}" eliminata',
                tone: AppSnackBarTone.error,
                icon: Icons.delete_forever_rounded,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RoutineCardShell(
      accent: color,
      onTap: () => context.push('/custom/detail', extra: routine),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoutineCardTitle(routine.title),
                const SizedBox(height: 16),
                Row(
                  children: [
                    RoutineTagChip(
                      label: '${routine.exercises.length} ESERCIZI',
                      color: color,
                      icon: Icons.fitness_center_rounded,
                    ),
                    const SizedBox(width: 8),
                    RoutineTagChip(
                      label: '${routine.estimatedDuration ?? "--"} MIN',
                      color: theme.colorScheme.tertiary,
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.edit_rounded,
                color: theme.colorScheme.primary,
                onTap: () => context.push('/custom/edit', extra: routine),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete_rounded,
                color: Colors.redAccent,
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemRoutineCard extends StatelessWidget {
  const _SystemRoutineCard({required this.routine, required this.color});

  final RoutineEntity routine;
  final Color color;

  void _copyRoutine(BuildContext context) {
    context.read<TrainingBloc>().add(CopyRoutineEvent(routine.id));
    AppSnackBar.showSuccess(context, 'Routine copiata in "I tuoi workout"');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RoutineCardShell(
      accent: color,
      onTap: () => context.push('/custom/detail', extra: routine),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoutineTagChip(
                  label: 'CONSIGLIATA',
                  color: theme.colorScheme.onSecondaryContainer,
                  background: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                RoutineCardTitle(routine.title),
                const SizedBox(height: 16),
                Row(
                  children: [
                    RoutineTagChip(
                      label: '${routine.exercises.length} ESERCIZI',
                      color: color,
                      icon: Icons.fitness_center_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.content_copy_rounded,
            color: theme.colorScheme.primary,
            onTap: () => _copyRoutine(context),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
