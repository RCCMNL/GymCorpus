import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/core/services/notification_service.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';
import 'package:gym_corpus/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._db);

  final AppDatabase _db;

  NotificationLogEntity _toEntity(NotificationLog row) {
    return NotificationLogEntity(
      id: row.id,
      title: row.title,
      body: row.body,
      timestamp: row.timestamp,
      isRead: row.isRead,
      type: row.type,
    );
  }

  @override
  Stream<List<NotificationLogEntity>> watchNotificationLogs() {
    return _db
        .watchAllNotificationLogs()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Either<Failure, int>> addNotificationLog({
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      final id = await _db.insertNotificationLog(
        NotificationLogsCompanion(
          title: Value(title),
          body: Value(body),
          type: Value(type),
          timestamp: Value(DateTime.now()),
        ),
      );
      return Right(id);
    } catch (e) {
      debugPrint('NotificationsRepository: addNotificationLog error: $e');
      return const Left(DatabaseFailure('Errore nel salvataggio notifica.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await _db.markNotificationRead(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Errore aggiornamento notifica.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _db.markAllNotificationsRead();
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Errore aggiornamento notifiche.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int id) async {
    try {
      await _db.deleteNotificationLog(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Errore eliminazione notifica.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      await _db.deleteAllNotificationLogs();
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Errore eliminazione notifiche.'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleDailyReminder({
    required int notificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await NotificationService.instance.scheduleDailyNotification(
        id: notificationId,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        payload: const NotificationPayloadData(
          type: 'stretching',
          title: 'Promemoria stretching',
          body: 'Hai aperto il promemoria stretching giornaliero.',
          source: 'scheduled',
        ),
      );
      return const Right(null);
    } catch (e) {
      debugPrint('NotificationsRepository: scheduleDailyReminder error: $e');
      return const Left(
        DatabaseFailure('Errore nella programmazione della notifica.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> scheduleWeeklyReminder({
    required int notificationId,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    try {
      await NotificationService.instance.scheduleWeeklyNotification(
        id: notificationId,
        title: title,
        body: body,
        dayOfWeek: dayOfWeek,
        hour: hour,
        minute: minute,
        payload: const NotificationPayloadData(
          type: 'training',
          title: 'Promemoria allenamento',
          body: 'Hai aperto il promemoria del tuo allenamento programmato.',
          source: 'scheduled',
        ),
      );
      return const Right(null);
    } catch (e) {
      debugPrint('NotificationsRepository: scheduleWeeklyReminder error: $e');
      return const Left(
        DatabaseFailure('Errore nella programmazione settimanale.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelScheduledReminder(
    int notificationId,
  ) async {
    try {
      await NotificationService.instance.cancelNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return const Left(
        DatabaseFailure('Errore nella cancellazione della notifica.'),
      );
    }
  }
}
