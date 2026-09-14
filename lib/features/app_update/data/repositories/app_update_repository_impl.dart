import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/app_update/data/datasources/app_update_remote_data_source.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_status.dart';
import 'package:gym_corpus/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AppUpdateRepository)
class AppUpdateRepositoryImpl implements AppUpdateRepository {
  AppUpdateRepositoryImpl(this._remoteDataSource);

  final AppUpdateRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AppUpdateStatus>> checkForUpdate({
    required int currentVersionCode,
  }) async {
    try {
      final info = await _remoteDataSource.fetchLatest();
      if (info == null || currentVersionCode >= info.latestVersionCode) {
        return const Right(AppUpdateStatus.none());
      }
      if (currentVersionCode < info.minSupportedVersionCode) {
        return Right(
          AppUpdateStatus(urgency: AppUpdateUrgency.required, info: info),
        );
      }
      return Right(
        AppUpdateStatus(urgency: AppUpdateUrgency.optional, info: info),
      );
    } catch (e) {
      // Fail-open: un problema di rete o un documento malformato non deve
      // mai impedire di allenarsi. Il chiamante tratta il Left come "nessun
      // aggiornamento rilevato", non come un blocco.
      return Left(ServerFailure(e.toString()));
    }
  }
}
