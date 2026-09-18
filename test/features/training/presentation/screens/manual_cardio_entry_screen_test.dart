import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gym_corpus/features/auth/presentation/bloc/auth_state.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_bloc.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_event.dart';
import 'package:gym_corpus/features/training/presentation/bloc/training_state.dart';
import 'package:gym_corpus/features/training/presentation/screens/manual_cardio_entry_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_bloc.dart';
import '../../../../helpers/mock_notifications_bloc.dart';
import '../../../../helpers/mock_training_bloc.dart';

/// Chi si dimentica di avviare il cronometro, o usa un altro dispositivo,
/// deve poter registrare la sessione a posteriori: senza, quell'allenamento
/// semplicemente non e' mai esistito per l'app.
void main() {
  late MockTrainingBloc trainingBloc;
  late MockAuthBloc authBloc;
  late MockNotificationsBloc notificationsBloc;

  setUpAll(() {
    registerFallbackValue(LoadCardioSessionsEvent());
  });

  setUp(() {
    trainingBloc = MockTrainingBloc();
    authBloc = MockAuthBloc();
    notificationsBloc = MockNotificationsBloc();

    when(() => trainingBloc.state).thenReturn(const TrainingState.loading());
    when(() => authBloc.state).thenReturn(
      const AuthState.authenticated(
        UserEntity(id: '1', email: 'a@a.com', weight: 70),
      ),
    );
    when(() => notificationsBloc.state).thenReturn(const NotificationsState());
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TrainingBloc>.value(value: trainingBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<NotificationsBloc>.value(value: notificationsBloc),
        ],
        child: const MaterialApp(home: ManualCardioEntryScreen()),
      ),
    );
  }

  SaveCardioSessionEvent capturedSave() {
    final captured = verify(() => trainingBloc.add(captureAny())).captured;
    return captured.whereType<SaveCardioSessionEvent>().last;
  }

  testWidgets('senza durata non si salva niente', (tester) async {
    await pump(tester);

    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();

    verifyNever(() => trainingBloc.add(any()));
    expect(find.textContaining('durata'), findsWidgets);
  });

  testWidgets('corretto l errore, il messaggio se ne va', (tester) async {
    await pump(tester);

    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();
    expect(find.text('Indica la durata in minuti.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('manual-duration')), '45');
    await tester.scrollUntilVisible(
      find.text('SALVA SESSIONE'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();

    expect(find.text('Indica la durata in minuti.'), findsNothing);
  });

  testWidgets('registra tipo, durata e distanza indicati', (tester) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('manual-duration')), '45');
    await tester.enterText(find.byKey(const Key('manual-distance')), '8,5');
    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();

    final event = capturedSave();
    expect(event.type, 'run');
    expect(event.duration, 45 * 60);
    expect(event.distance, 8.5);
    expect(event.date, isNotNull);
  });

  testWidgets('il passo medio viene calcolato dai valori inseriti', (
    tester,
  ) async {
    await pump(tester);

    // 10 km in 50 minuti: 5:00 al chilometro, 12 km/h di media.
    await tester.enterText(find.byKey(const Key('manual-duration')), '50');
    await tester.enterText(find.byKey(const Key('manual-distance')), '10');
    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();

    final event = capturedSave();
    expect(event.pace, '05:00');
    expect(event.avgSpeed, closeTo(12, 0.1));
  });

  testWidgets('le calorie non restano a zero', (tester) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('manual-duration')), '30');
    await tester.enterText(find.byKey(const Key('manual-distance')), '5');
    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();

    expect(capturedSave().calories, greaterThan(0));
  });

  testWidgets('per l ellittica la distanza non viene chiesta', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Ellittica'));
    await tester.pump();

    expect(find.byKey(const Key('manual-distance')), findsNothing);
  });

  testWidgets('una sessione senza percorso non inventa un percorso', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('manual-duration')), '20');
    await tester.tap(find.text('SALVA SESSIONE'));
    await tester.pump();

    expect(capturedSave().routeJson, isNull);
  });
}
