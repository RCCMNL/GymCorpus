import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/core/service_locator.dart' as di;
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/screens/root_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/custom_workouts_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_detail_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/profile_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercises_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_page.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const GymApp());
}

final _router = GoRouter(
  initialLocation: '/training',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return RootScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/training',
          builder: (context, state) => const TrainingScreen(),
        ),
        GoRoute(
          path: '/custom',
          builder: (context, state) => const CustomWorkoutsScreen(),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => WorkoutDetailScreen(routine: state.extra as RoutineEntity),
            ),
            GoRoute(
              path: 'edit',
              builder: (context, state) => WorkoutPage(routineToEdit: state.extra as RoutineEntity),
            ),
            GoRoute(
              path: 'new',
              builder: (context, state) => const WorkoutPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/exercises',
          builder: (context, state) => const ExercisesScreen(),
        ),
        GoRoute(
          path: '/exercises/detail',
          builder: (context, state) {
            final exercise = state.extra as ExerciseEntity;
            return ExerciseDetailScreen(exercise: exercise);
          },
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrainingBloc>(
          create: (_) => di.sl<TrainingBloc>()
            ..add(LoadExercisesEvent())
            ..add(LoadRoutinesEvent())
            ..add(LoadSettingsEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'GYM 2.0',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

