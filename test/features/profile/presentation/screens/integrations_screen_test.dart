import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/profile/presentation/screens/integrations_screen.dart';
import 'package:gym_corpus/features/training/domain/entities/exercise.dart';
import 'package:gym_corpus/features/training/domain/entities/routine.dart';
import 'package:gym_corpus/features/training/domain/repositories/training_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

/// Il repository era letto con `context.read<TrainingRepository>()`, ma
/// nessun `RepositoryProvider<TrainingRepository>` esiste nell'albero dei
/// widget dell'app: TrainingRepository e' registrato solo in GetIt. Ogni
/// tap su "Esporta" lanciava ProviderNotFoundException, catturata dal
/// catch generico e mostrata come errore vago: l'export non ha mai
/// funzionato.
void main() {
  late MockTrainingRepository repository;
  late MockNotificationsRepository notificationsRepository;
  final getIt = GetIt.instance;

  setUp(() {
    repository = MockTrainingRepository();
    notificationsRepository = MockNotificationsRepository();

    if (getIt.isRegistered<TrainingRepository>()) {
      getIt.unregister<TrainingRepository>();
    }
    getIt.registerSingleton<TrainingRepository>(repository);

    when(
      () => notificationsRepository.watchNotificationLogs(),
    ).thenAnswer((_) => const Stream.empty());

    when(() => repository.watchRoutines()).thenAnswer(
      (_) => Stream.value([
        RoutineEntity(
          id: 1,
          title: 'Push Day',
          createdAt: DateTime(2026, 4, 12),
        ),
      ]),
    );
    when(() => repository.watchWeightLogs()).thenAnswer(
      (_) => Stream.value([
        WorkoutSetEntity(
          id: 1,
          workoutId: 1,
          exerciseId: 1,
          reps: 8,
          weight: 82,
          timestamp: DateTime(2026, 4, 26),
        ),
      ]),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // GymHeader, l'appbar condivisa usata da IntegrationsScreen, legge
        // NotificationsBloc per il badge non lette: serve un provider anche
        // se non e' l'oggetto di questo test.
        home: BlocProvider<NotificationsBloc>(
          create: (_) => NotificationsBloc(repository: notificationsRepository),
          child: const IntegrationsScreen(),
        ),
      ),
    );
  }

  group('IntegrationsScreen', () {
    testWidgets("l'export JSON legge il repository da GetIt invece di lanciare "
        'ProviderNotFoundException', (tester) async {
      await pumpScreen(tester);

      await tester.ensureVisible(find.text('Esporta Raw Data (JSON)'));
      await tester.tap(find.text('Esporta Raw Data (JSON)'));
      await tester.pump();
      // Lascia scorrere gli await interni (lettura stream, scrittura file).
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => repository.watchRoutines()).called(1);
      verify(() => repository.watchWeightLogs()).called(1);
      expect(find.textContaining('ProviderNotFoundException'), findsNothing);
    });
  });
}
