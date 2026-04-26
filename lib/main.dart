import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/service_locator.dart' as di;
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/cardio_history_screen.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/progress_screen.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/splash_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercises_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/integrations_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/profile_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/security_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/favorite_exercises_screen.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/screens/cardio_tracker_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/custom_workouts_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/root_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_dashboard_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_detail_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_page.dart';
import 'package:gym_corpus/firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
  late final BlocRefreshStream _routerRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(const AuthEvent.checkSessionRequested());
    _routerRefresh = BlocRefreshStream(_authBloc.stream);

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: _routerRefresh,
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
          error: (_, previousUser) {
            // If we have a previousUser, the user was authenticated
            // before the error — don't redirect to login
            if (previousUser != null) return null;

            if (state.matchedLocation != '/login' &&
                state.matchedLocation != '/signup' &&
                state.matchedLocation != '/splash') {
              return '/login';
            }
            return null;
          },
          loading: (previousUser) {
            // During loading, don't redirect anywhere
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
              builder: (context, state) => const TrainingDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'session',
                  builder: (context, state) => TrainingScreen(
                    routine: state.extra as RoutineEntity?,
                  ),
                ),
                GoRoute(
                  path: 'cardio',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => CardioTrackerScreen(
                    type: (state.extra as String?) ?? 'run',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/custom',
              builder: (context, state) => const CustomWorkoutsScreen(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final routine = _readRoutineExtra(state);
                    if (routine == null) {
                      return const _MissingRouteDataScreen(
                        title: 'Workout non disponibile',
                        message:
                            'Apri questa schermata dalla lista workout per caricare la routine corretta.',
                        fallbackRoute: '/custom',
                      );
                    }
                    return WorkoutDetailScreen(routine: routine);
                  },
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
                final exercise = _readExerciseExtra(state);
                if (exercise == null) {
                  return const _MissingRouteDataScreen(
                    title: 'Esercizio non disponibile',
                    message:
                        'Apri questa schermata dalla lista esercizi per caricare i dettagli corretti.',
                    fallbackRoute: '/exercises',
                  );
                }
                return ExerciseDetailScreen(exercise: exercise);
              },
            ),
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
              routes: [
                GoRoute(
                  path: 'cardio-history',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CardioHistoryScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'security',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SecurityScreen(),
                ),
                GoRoute(
                  path: 'integrations',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const IntegrationsScreen(),
                ),
                GoRoute(
                  path: 'progress',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const ProgressScreen(),
                ),
                GoRoute(
                  path: 'favorites',
                  builder: (context, state) => const FavoriteExercisesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RoutineEntity? _readRoutineExtra(GoRouterState state) {
    final extra = state.extra;
    return extra is RoutineEntity ? extra : null;
  }

  ExerciseEntity? _readExerciseExtra(GoRouterState state) {
    final extra = state.extra;
    return extra is ExerciseEntity ? extra : null;
  }

  @override
  void dispose() {
    _router.dispose();
    _routerRefresh.dispose();
    _authBloc.close();
    super.dispose();
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
            ..add(LoadBodyWeightLogsEvent())
            ..add(LoadSettingsEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'GYM 2.0',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: _router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
          Locale('en', 'US'),
        ],
        locale: const Locale('it', 'IT'),
      ),
    );
  }
}

class _MissingRouteDataScreen extends StatelessWidget {
  const _MissingRouteDataScreen({
    required this.title,
    required this.message,
    required this.fallbackRoute,
  });

  final String title;
  final String message;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(fallbackRoute),
                child: const Text('Torna indietro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
