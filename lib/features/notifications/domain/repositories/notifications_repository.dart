import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/notifications/domain/entities/notification_log_entity.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationLogEntity>> watchNotificationLogs();

  Future<Either<Failure, int>> addNotificationLog({
    required String title,
    required String body,
    required String type,
  });

  Future<Either<Failure, void>> markAsRead(int id);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(int id);

  Future<Either<Failure, void>> deleteAllNotifications();

  /// Schedule a daily notification at the given hour:minute.
  Future<Either<Failure, void>> scheduleDailyReminder({
    required int notificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });

  /// Cancel a scheduled notification by its ID.
  Future<Either<Failure, void>> cancelScheduledReminder(int notificationId);
}
