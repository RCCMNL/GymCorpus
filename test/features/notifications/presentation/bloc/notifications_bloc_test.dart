import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';
import 'package:gym_corpus/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepository;
  late NotificationsBloc bloc;

  final tLogs = [
    NotificationLogEntity(
      id: 1,
      title: 'Allenamento previsto',
      body: 'Oggi e giorno di allenamento.',
      timestamp: DateTime(2026, 4, 26, 9),
      isRead: false,
      type: 'training',
    ),
    NotificationLogEntity(
      id: 2,
      title: 'Stretching time',
      body: 'E il momento di fare stretching.',
      timestamp: DateTime(2026, 4, 25, 8),
      isRead: true,
      type: 'stretching',
    ),
  ];

  setUp(() {
    mockRepository = MockNotificationsRepository();

    // Stub di default per evitare MissingStubError sulle chiamate non
    // esplicitamente configurate dal singolo test.
    when(
      () => mockRepository.watchNotificationLogs(),
    ).thenAnswer((_) => const Stream.empty());

    bloc = NotificationsBloc(repository: mockRepository);
  });

  tearDown(() => bloc.close());

  group('NotificationsBloc', () {
    test('lo stato iniziale ha isLoading true e nessuna notifica', () {
      expect(bloc.state, const NotificationsState(isLoading: true));
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'LoadNotificationsEvent emette le notifiche dallo stream e azzera isLoading',
      build: () {
        when(
          () => mockRepository.watchNotificationLogs(),
        ).thenAnswer((_) => Stream.value(tLogs));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadNotificationsEvent()),
      expect: () => [NotificationsState(notifications: tLogs)],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'un secondo LoadNotificationsEvent sostituisce la sottoscrizione precedente',
      build: () {
        var callCount = 0;
        when(() => mockRepository.watchNotificationLogs()).thenAnswer((_) {
          callCount++;
          // Prima chiamata: stream che non si chiude mai (simula lo stream
          // reale del database). Seconda chiamata: la nuova sottoscrizione.
          return callCount == 1
              ? const Stream<List<NotificationLogEntity>>.empty()
              : Stream.value(tLogs);
        });
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadNotificationsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        bloc.add(LoadNotificationsEvent());
      },
      expect: () => [NotificationsState(notifications: tLogs)],
      verify: (_) {
        verify(() => mockRepository.watchNotificationLogs()).called(2);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'MarkNotificationReadEvent inoltra l id al repository',
      build: () {
        when(
          () => mockRepository.markAsRead(1),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const MarkNotificationReadEvent(1)),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(() => mockRepository.markAsRead(1)).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'MarkAllNotificationsReadEvent inoltra la richiesta al repository',
      build: () {
        when(
          mockRepository.markAllAsRead,
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(MarkAllNotificationsReadEvent()),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(mockRepository.markAllAsRead).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'DeleteNotificationEvent inoltra l id al repository',
      build: () {
        when(
          () => mockRepository.deleteNotification(2),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteNotificationEvent(2)),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(() => mockRepository.deleteNotification(2)).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'DeleteAllNotificationsEvent inoltra la richiesta al repository',
      build: () {
        when(
          mockRepository.deleteAllNotifications,
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteAllNotificationsEvent()),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(mockRepository.deleteAllNotifications).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'AddNotificationLogEvent salva titolo, corpo e tipo cosi come ricevuti',
      build: () {
        when(
          () => mockRepository.addNotificationLog(
            title: 'Titolo',
            body: 'Corpo',
            type: 'general',
          ),
        ).thenAnswer((_) async => const Right(1));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AddNotificationLogEvent(
          title: 'Titolo',
          body: 'Corpo',
          type: 'general',
        ),
      ),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(
          () => mockRepository.addNotificationLog(
            title: 'Titolo',
            body: 'Corpo',
            type: 'general',
          ),
        ).called(1);
      },
    );

    group('errore transitorio di markAsRead', () {
      // A differenza di deleteNotification e degli altri handler sotto,
      // markAsRead ora porta il fallimento in actionError invece di
      // scartare l'Either, sullo stesso schema di
      // TrainingLoaded.actionError: l'utente vede l'errore, e le notifiche
      // gia' caricate non vengono perse.
      blocTest<NotificationsBloc, NotificationsState>(
        'un fallimento emette actionError senza perdere le notifiche caricate',
        build: () {
          when(
            () => mockRepository.markAsRead(1),
          ).thenAnswer((_) async => const Left(DatabaseFailure('errore db')));
          return bloc;
        },
        seed: () => NotificationsState(notifications: tLogs),
        act: (bloc) => bloc.add(const MarkNotificationReadEvent(1)),
        expect: () => [
          NotificationsState(notifications: tLogs, actionError: 'errore db'),
        ],
        verify: (bloc) {
          expect(
            bloc.state.notifications,
            tLogs,
            reason:
                'le notifiche gia caricate devono sopravvivere al fallimento',
          );
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'ClearNotificationActionErrorEvent azzera solo l errore, non le notifiche',
        build: () => bloc,
        seed: () =>
            NotificationsState(notifications: tLogs, actionError: 'errore db'),
        act: (bloc) => bloc.add(const ClearNotificationActionErrorEvent()),
        expect: () => [NotificationsState(notifications: tLogs)],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'ClearNotificationActionErrorEvent non emette nulla se non ci sono errori',
        build: () => bloc,
        seed: () => NotificationsState(notifications: tLogs),
        act: (bloc) => bloc.add(const ClearNotificationActionErrorEvent()),
        expect: () => <NotificationsState>[],
      );
    });

    group('errori del repository sulle azioni singole', () {
      // markAllAsRead, deleteNotification e deleteAllNotifications
      // scartano ancora l'Either restituito dal repository: un fallimento
      // non produce ne' un messaggio d'errore ne' un cambio di stato.
      // Questi test documentano il comportamento attuale, non lo
      // convalidano come corretto: e' lo stesso gap gia' risolto sopra per
      // markAsRead, non ancora esteso ai handler restanti.
      blocTest<NotificationsBloc, NotificationsState>(
        'un fallimento di deleteNotification non emette alcuno stato',
        build: () {
          when(
            () => mockRepository.deleteNotification(1),
          ).thenAnswer((_) async => const Left(DatabaseFailure('errore db')));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteNotificationEvent(1)),
        expect: () => <NotificationsState>[],
      );
    });

    group('promemoria stretching', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'programma sul solo id riservato 9001 con orario scelto',
        build: () {
          when(
            () => mockRepository.scheduleDailyReminder(
              notificationId: 9001,
              title: 'Stretching time',
              body: 'E il momento di fare stretching. Anche 10 minuti aiutano.',
              hour: 7,
              minute: 30,
            ),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const ScheduleStretchingReminderEvent(hour: 7, minute: 30),
        ),
        expect: () => <NotificationsState>[],
        verify: (_) {
          verify(
            () => mockRepository.scheduleDailyReminder(
              notificationId: 9001,
              title: 'Stretching time',
              body: 'E il momento di fare stretching. Anche 10 minuti aiutano.',
              hour: 7,
              minute: 30,
            ),
          ).called(1);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'CancelStretchingReminderEvent cancella l id riservato 9001',
        build: () {
          when(
            () => mockRepository.cancelScheduledReminder(9001),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(CancelStretchingReminderEvent()),
        expect: () => <NotificationsState>[],
        verify: (_) {
          verify(() => mockRepository.cancelScheduledReminder(9001)).called(1);
        },
      );
    });

    group('promemoria allenamento', () {
      // Gli id riservati per il promemoria allenamento sono 9010-9016
      // (lun-dom): ScheduleTrainingReminderEvent usa notificationId =
      // 9010 + (giorno - 1), dove giorno e' 1=lunedi..7=domenica.
      blocTest<NotificationsBloc, NotificationsState>(
        'cancella tutti gli slot lun-dom prima di programmare solo i giorni scelti',
        build: () {
          for (var i = 0; i < 7; i++) {
            when(
              () => mockRepository.cancelScheduledReminder(9010 + i),
            ).thenAnswer((_) async => const Right(null));
          }
          when(
            () => mockRepository.scheduleWeeklyReminder(
              notificationId: 9010, // lunedi (giorno 1)
              title: 'Allenamento previsto',
              body: 'Oggi e giorno di allenamento. Preparati per la sessione.',
              dayOfWeek: 1,
              hour: 18,
              minute: 0,
            ),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockRepository.scheduleWeeklyReminder(
              notificationId: 9012, // mercoledi (giorno 3)
              title: 'Allenamento previsto',
              body: 'Oggi e giorno di allenamento. Preparati per la sessione.',
              dayOfWeek: 3,
              hour: 18,
              minute: 0,
            ),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const ScheduleTrainingReminderEvent(
            hour: 18,
            minute: 0,
            days: [1, 3],
          ),
        ),
        expect: () => <NotificationsState>[],
        verify: (_) {
          for (var i = 0; i < 7; i++) {
            verify(
              () => mockRepository.cancelScheduledReminder(9010 + i),
            ).called(1);
          }
          verify(
            () => mockRepository.scheduleWeeklyReminder(
              notificationId: 9010,
              title: 'Allenamento previsto',
              body: 'Oggi e giorno di allenamento. Preparati per la sessione.',
              dayOfWeek: 1,
              hour: 18,
              minute: 0,
            ),
          ).called(1);
          verify(
            () => mockRepository.scheduleWeeklyReminder(
              notificationId: 9012,
              title: 'Allenamento previsto',
              body: 'Oggi e giorno di allenamento. Preparati per la sessione.',
              dayOfWeek: 3,
              hour: 18,
              minute: 0,
            ),
          ).called(1);
          // Nessun giorno non selezionato deve ricevere una programmazione.
          verifyNever(
            () => mockRepository.scheduleWeeklyReminder(
              notificationId: any(named: 'notificationId'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              dayOfWeek: 2,
              hour: any(named: 'hour'),
              minute: any(named: 'minute'),
            ),
          );
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'senza giorni selezionati cancella soltanto, senza riprogrammare nulla',
        build: () {
          for (var i = 0; i < 7; i++) {
            when(
              () => mockRepository.cancelScheduledReminder(9010 + i),
            ).thenAnswer((_) async => const Right(null));
          }
          return bloc;
        },
        act: (bloc) => bloc.add(
          const ScheduleTrainingReminderEvent(hour: 18, minute: 0, days: []),
        ),
        expect: () => <NotificationsState>[],
        verify: (_) {
          for (var i = 0; i < 7; i++) {
            verify(
              () => mockRepository.cancelScheduledReminder(9010 + i),
            ).called(1);
          }
          verifyNever(
            () => mockRepository.scheduleWeeklyReminder(
              notificationId: any(named: 'notificationId'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              dayOfWeek: any(named: 'dayOfWeek'),
              hour: any(named: 'hour'),
              minute: any(named: 'minute'),
            ),
          );
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'CancelTrainingReminderEvent cancella tutti gli slot lun-dom',
        build: () {
          for (var i = 0; i < 7; i++) {
            when(
              () => mockRepository.cancelScheduledReminder(9010 + i),
            ).thenAnswer((_) async => const Right(null));
          }
          return bloc;
        },
        act: (bloc) => bloc.add(CancelTrainingReminderEvent()),
        expect: () => <NotificationsState>[],
        verify: (_) {
          for (var i = 0; i < 7; i++) {
            verify(
              () => mockRepository.cancelScheduledReminder(9010 + i),
            ).called(1);
          }
        },
      );
    });
  });

  group('NotificationsState', () {
    test('unreadCount conta solo le notifiche non lette', () {
      final state = NotificationsState(notifications: tLogs);

      expect(state.unreadCount, 1);
    });

    test('unreadCount e zero su una lista vuota', () {
      const state = NotificationsState();

      expect(state.unreadCount, 0);
    });

    test('copyWith preserva i campi non specificati', () {
      final state = NotificationsState(notifications: tLogs, isLoading: true);

      final updated = state.copyWith(isLoading: false);

      expect(updated.notifications, tLogs);
      expect(updated.isLoading, isFalse);
    });

    test('copyWith senza argomenti non modifica actionError', () {
      // Come per UserEntity.copyWith(photoUrl: ...), un semplice copyWith
      // senza clearActionError non rimuove l'errore precedente: e' per
      // questo che serve un flag esplicito invece di affidarsi a `??`.
      final state = NotificationsState(
        notifications: tLogs,
        actionError: 'errore db',
      );

      expect(state.copyWith().actionError, 'errore db');
    });

    test('clearActionError rimuove l errore preservando gli altri campi', () {
      final state = NotificationsState(
        notifications: tLogs,
        actionError: 'errore db',
      );

      final cleared = state.copyWith(clearActionError: true);

      expect(cleared.actionError, isNull);
      expect(cleared.notifications, tLogs);
    });
  });
}
