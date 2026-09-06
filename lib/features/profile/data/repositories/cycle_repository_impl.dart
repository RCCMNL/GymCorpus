import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/profile/domain/entities/cycle_log.dart';
import 'package:gym_corpus/features/profile/domain/repositories/cycle_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CycleRepository)
class CycleRepositoryImpl implements CycleRepository {
  CycleRepositoryImpl({required this.database});

  final AppDatabase database;

  @override
  Stream<List<CycleLogEntity>> watchCycleLogs() {
    return database.watchAllCycleLogs().map(
      (logs) => logs
          .map(
            (log) => CycleLogEntity(
              id: log.id,
              startDate: log.startDate,
              endDate: log.endDate,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Either<Failure, int>> startPeriod(DateTime date) async {
    try {
      final id = await database.insertCycleLog(
        CycleLogsCompanion.insert(startDate: date),
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endPeriod({
    required int id,
    required DateTime date,
  }) async {
    try {
      await database.closeCycleLog(id, date);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCycleLog(int id) async {
    try {
      await database.deleteCycleLog(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCycleLog({
    required int id,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      await database.updateCycleLog(id, startDate, endDate);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  /// Il promemoria vive tra le impostazioni locali come tutte le altre
  /// preferenze: non ha bisogno di una tabella propria.
  @override
  Stream<bool> watchReminderEnabled() =>
      database.watchSetting(_reminderKey).map((value) => value == 'true');

  @override
  Future<Either<Failure, void>> setReminderEnabled({
    required bool enabled,
  }) async {
    try {
      await database.updateSetting(_reminderKey, enabled.toString());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  static const _reminderKey = 'cycle_reminder';
}
