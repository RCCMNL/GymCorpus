import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/widgets/gym_header.dart';
import 'package:gym_corpus/core/widgets/labels.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
// ignore: unused_import
import 'package:gym_corpus/features/training/presentation/screens/nutrition_screen.dart';
// ignore: unused_import
import 'package:gym_corpus/features/training/presentation/screens/yoga_screen.dart';
import 'package:gym_corpus/features/training/presentation/widgets/cardio_selector_sheet.dart';
import 'package:gym_corpus/features/training/presentation/widgets/dashboard_sections.dart';
import 'package:gym_corpus/features/training/presentation/widgets/workout_selector_modal.dart';

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
                        return TrainingHubGreeting(
                          userName: authState.maybeWhen(
                            authenticated: (user, _) =>
                                user.firstName ?? 'Atleta',
                            orElse: () => 'Atleta',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    YourRoutinesCard(
                      routines: state is TrainingLoaded ? state.routines : null,
                      onOpenRoutine: (routine) =>
                          context.go('/training/session', extra: routine),
                      onCreateFirst: () => context.go('/custom/new'),
                      onStartWorkout: () => _showWorkoutSelector(context),
                    ),
                    const SizedBox(height: 40),
                    const SectionTitle(
                      'ATTIVITÀ RAPIDA',
                      tone: SectionTitleTone.muted,
                    ),
                    const SizedBox(height: 16),
                    QuickActivityGrid(
                      onCardio: () => _showCardioSelector(context),
                      onYoga: () => context.go('/training/yoga'),
                      onNutrition: () => context.go('/training/nutrition'),
                    ),

                    const SizedBox(height: 60), // Space for nav bar
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showWorkoutSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const WorkoutSelectorModal(),
    );
  }

  void _showCardioSelector(BuildContext context) {
    showCardioSelectorSheet(
      context: context,
      onManualEntry: () {
        Navigator.pop(context);
        context.push('/training/cardio-manual');
      },
      onStart: (args) {
        Navigator.pop(context);
        context.go('/training/cardio', extra: args);
      },
    );
  }
}
