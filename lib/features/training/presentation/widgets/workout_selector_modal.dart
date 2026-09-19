import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/compact_sheet.dart';
import 'package:gym_corpus/core/widgets/empty_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/widgets/dashboard_sections.dart';

/// Il foglio che chiede quale routine avviare.
class WorkoutSelectorModal extends StatelessWidget {
  const WorkoutSelectorModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return SheetSurface(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 40,
                      ),
                      child: EmptyState(
                        icon: Icons.fitness_center_outlined,
                        title: 'Nessuna routine custom trovata',
                        message:
                            'Crea una scheda tua per poterla avviare da qui.',
                        action: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.go('/custom/new');
                          },
                          child: const Text('CREA ORA'),
                        ),
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
                      return RoutineHighlightCard(
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
  }
}
