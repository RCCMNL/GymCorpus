import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_corpus/core/service_locator.dart' as di;
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/splash_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercises_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/profile_screen.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/screens/custom_workouts_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/root_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_detail_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_page.dart';
import 'package:gym_corpus/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize(
    serverClientId: '996703301991-gap14vk81ourfhvkaftpnf8ntvc0g68c.apps.googleusercontent.com',
  );
  await di.configureDependencies();
  runApp(const GymApp());
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// A [Listenable] that notifies listeners when the [AuthBloc] state changes.
/// This allows the router to re-run its redirection logic immediately.
class BlocRefreshStream extends ChangeNotifier {
  BlocRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class GymApp extends StatefulWidget {
  const GymApp({super.key});

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(const AuthEvent.checkSessionRequested());
    
    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: BlocRefreshStream(_authBloc.stream),
      redirect: (context, state) {
        final authState = _authBloc.state;
        
        return authState.maybeWhen(
          authenticated: (_) {
            if (state.matchedLocation == '/login' || 
                state.matchedLocation == '/signup' || 
                state.matchedLocation == '/splash') {
              return '/training';
            }
            return null;
          },
          unauthenticated: () {
            if (state.matchedLocation != '/login' && 
                state.matchedLocation != '/signup' && 
                state.matchedLocation != '/splash') {
              return '/login';
            }
            return null;
          },
          error: (_) {
            if (state.matchedLocation != '/login' && 
                state.matchedLocation != '/signup' && 
                state.matchedLocation != '/splash') {
              return '/login';
            }
            return null;
          },
          orElse: () => null,
        );
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
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
                  builder: (context, state) => WorkoutDetailScreen(
                    routine: (state.extra as RoutineEntity?)!,
                  ),
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => WorkoutPage(
                    routineToEdit: state.extra as RoutineEntity?,
                  ),
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
                final exercise = (state.extra as ExerciseEntity?)!;
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
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
        routerConfig: _router,
      ),
    );
  }
}
