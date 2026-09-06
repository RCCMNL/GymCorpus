import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_corpus/core/service_locator.dart' as di;
import 'package:gym_corpus/core/services/app_lock_controller.dart';
import 'package:gym_corpus/core/services/notification_service.dart';
import 'package:gym_corpus/core/theme/app_theme.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/cardio_history_screen.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/cardio_session_detail_screen.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/daily_activity_screen.dart';
import 'package:gym_corpus/features/analytics/presentation/screens/progress_screen.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_event.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/auth/presentation/router/auth_redirect.dart';
import 'package:gym_corpus/features/auth/presentation/screens/lock_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/profile_onboarding_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:gym_corpus/features/auth/presentation/screens/splash_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/custom_exercise_form_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/exercises_screen.dart';
import 'package:gym_corpus/features/exercises/presentation/screens/favorite_exercises_screen.dart';
import 'package:gym_corpus/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:gym_corpus/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:gym_corpus/features/profile/domain/repositories/cycle_repository.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_bloc.dart';
import 'package:gym_corpus/features/profile/presentation/bloc/cycle_event.dart';
import 'package:gym_corpus/features/profile/presentation/screens/cycle_calendar_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/integrations_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/legal_screens.dart';
import 'package:gym_corpus/features/profile/presentation/screens/profile_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/records_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/security_screen.dart';
import 'package:gym_corpus/features/profile/presentation/screens/trophy_board_screen.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_activity.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_goal.dart';
import 'package:gym_corpus/features/training/domain/entities/cardio_session.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/screens/article_detail_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/cardio_tracker_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/custom_workouts_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/manual_cardio_entry_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/nutrition_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/root_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_dashboard_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/training_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_detail_screen.dart';
import 'package:gym_corpus/features/training/presentation/screens/workout_page.dart';
import 'package:gym_corpus/features/training/presentation/screens/yoga_screen.dart';
import 'package:gym_corpus/firebase_options.dart';

/// Lexend e Inter sono impacchettati nell'app sotto licenza OFL, che
/// richiede di distribuire il testo della licenza insieme ai font.
/// Registrandoli qui compaiono nella pagina delle licenze di Flutter.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final font in ['Lexend', 'Inter']) {
      final license = await rootBundle.loadString('assets/fonts/$font-OFL.txt');
      yield LicenseEntryWithLineBreaks([font], license);
    }
  });
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  _registerFontLicenses();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // In debug usa il provider "debug" (token da registrare in console, vedi
  // https://firebase.google.com/docs/app-check/flutter/debug-provider),
  // altrimenti le build di sviluppo verrebbero rifiutate da Play
  // Integrity/App Attest che richiedono un binario firmato e distribuito.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await di.configureDependencies();
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  runApp(const GymApp());
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Permette di mostrare messaggi di errore da qualunque schermata, anche da
/// quelle spinte sul navigator root che non stanno sotto lo shell delle tab.
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Legge `state.extra` solo se e' davvero del tipo atteso.
///
/// Il cast diretto `state.extra as T?` non protegge da un extra presente ma
/// di tipo diverso: in quel caso lancia un TypeError e la rotta crasha. Puo'
/// succedere con uno stato GoRouter ripristinato dopo la terminazione del
/// processo, o dopo un refactor che cambia il tipo passato a una rotta.
T? _extraOf<T extends Object>(GoRouterState state) {
  final extra = state.extra;
  return extra is T ? extra : null;
}

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

class _GymAppState extends State<GymApp> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final BlocRefreshStream _routerRefresh;
  late final AppLockController _appLock;
  late final Listenable _routerListenable;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authBloc = di.sl<AuthBloc>()..add(const AuthEvent.checkSessionRequested());
    _routerRefresh = BlocRefreshStream(_authBloc.stream);
    _appLock = AppLockController(di.sl<AuthRepository>());
    _routerListenable = Listenable.merge([_routerRefresh, _appLock]);

    // All'avvio l'app parte bloccata se l'utente ha attivato la biometria:
    // senza questo una sessione Firebase gia' presente porta dritti in
    // /training senza alcuna richiesta di riconoscimento.
    unawaited(_appLock.lockIfEnabled());

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: _routerListenable,
      // La regola vive in auth_redirect.dart: le condizioni sono poche ma si
      // intrecciano, e li' possono essere verificate caso per caso senza
      // montare l'intera app.
      redirect: (context, state) => resolveAuthRedirect(
        authState: _authBloc.state,
        location: state.matchedLocation,
        isLocked: _appLock.isLocked,
      ),
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/lock',
          builder: (context, state) => LockScreen(controller: _appLock),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: onboardingLocation,
          builder: (context, state) => const ProfileOnboardingScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/legal/terms',
          builder: (context, state) => const TermsOfServiceScreen(),
        ),
        GoRoute(
          path: '/legal/consent',
          builder: (context, state) => const ConsentSummaryScreen(),
        ),
        GoRoute(
          path: '/legal/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/legal/cookies',
          builder: (context, state) => const CookiePolicyScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
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
                  builder: (context, state) =>
                      TrainingScreen(routine: _extraOf<RoutineEntity>(state)),
                ),
                GoRoute(
                  path: 'cardio',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    // La rotta accettava una semplice stringa con il tipo di
                    // attivita': quel formato resta leggibile, cosi' una
                    // navigazione ripristinata da una versione precedente
                    // continua ad aprire la schermata giusta.
                    final args = _extraOf<CardioLaunchArgs>(state);
                    return CardioTrackerScreen(
                      activity:
                          args?.activity ??
                          CardioActivity.fromId(_extraOf<String>(state)),
                      goal: args?.goal,
                    );
                  },
                ),
                GoRoute(
                  path: 'cardio-manual',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const ManualCardioEntryScreen(),
                ),
                GoRoute(
                  path: 'yoga',
                  builder: (context, state) => const YogaScreen(),
                ),
                GoRoute(
                  path: 'nutrition',
                  builder: (context, state) => const NutritionScreen(),
                  routes: [
                    GoRoute(
                      path: 'article',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => ArticleDetailScreen(
                        data: _extraOf<Map<String, dynamic>>(state) ?? const {},
                      ),
                    ),
                  ],
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
                    final routine = _extraOf<RoutineEntity>(state);
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
                    routineToEdit: _extraOf<RoutineEntity>(state),
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
                final exercise = _extraOf<ExerciseEntity>(state);
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
              path: '/exercises/new',
              builder: (context, state) => const CustomExerciseFormScreen(),
            ),
            GoRoute(
              path: '/exercises/edit',
              builder: (context, state) {
                final exercise = _extraOf<ExerciseEntity>(state);
                if (exercise == null) {
                  return const _MissingRouteDataScreen(
                    title: 'Esercizio non disponibile',
                    message:
                        'Apri questa schermata dal dettaglio esercizio per modificarlo.',
                    fallbackRoute: '/exercises',
                  );
                }
                return CustomExerciseFormScreen(exerciseToEdit: exercise);
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
                  routes: [
                    GoRoute(
                      path: 'session',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final session = _extraOf<CardioSessionEntity>(state);
                        if (session == null) return const CardioHistoryScreen();
                        return CardioSessionDetailScreen(session: session);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'daily-activity',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const DailyActivityScreen(),
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
                  path: 'notifications',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const NotificationSettingsScreen(),
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
                  path: 'trophies',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const TrophyBoardScreen(),
                ),
                GoRoute(
                  path: 'records',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const RecordsScreen(),
                ),
                GoRoute(
                  path: 'favorites',
                  builder: (context, state) => const FavoriteExercisesScreen(),
                ),
                GoRoute(
                  path: 'terms',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const TermsOfServiceScreen(),
                ),
                GoRoute(
                  path: 'consent',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const ConsentSummaryScreen(),
                ),
                GoRoute(
                  path: 'privacy',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const PrivacyPolicyScreen(),
                ),
                GoRoute(
                  path: 'cookies',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CookiePolicyScreen(),
                ),
                GoRoute(
                  path: 'cycle-calendar',
                  // Il bloc del ciclo vive quanto la schermata: chi non apre
                  // il calendario non mette mai in ascolto quei dati.
                  builder: (context, state) => BlocProvider(
                    create: (_) =>
                        CycleBloc(
                          repository: di.sl<CycleRepository>(),
                          notifications: di.sl<NotificationsRepository>(),
                        )
                          ..add(LoadCycleLogsEvent()),
                    child: const CycleCalendarScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Richiude il lucchetto quando l'app lascia il primo piano, cosi' chi
    // riprende in mano il telefono deve autenticarsi di nuovo. Il controller
    // ignora la richiesta mentre il prompt di sistema e' aperto, perche'
    // quello stesso prompt porta l'app in `inactive`.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_appLock.lockIfEnabled());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    _routerRefresh.dispose();
    _appLock.dispose();
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
        BlocProvider<NotificationsBloc>(
          create: (_) =>
              di.sl<NotificationsBloc>()..add(LoadNotificationsEvent()),
        ),
      ],
      child: BlocListener<TrainingBloc, TrainingState>(
        listenWhen: (previous, current) =>
            current is TrainingLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! TrainingLoaded) return;
          final message = state.actionError;
          if (message == null) return;

          // Il messaggio viene consumato subito: cosi' un secondo fallimento
          // identico torna a essere un cambio di stato osservabile.
          context.read<TrainingBloc>().add(const ClearActionErrorEvent());
          _scaffoldMessengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.darkTheme.colorScheme.error,
              ),
            );
        },
        child: MaterialApp.router(
          title: 'GYM 2.0',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: _router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
          locale: const Locale('it', 'IT'),
        ),
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
