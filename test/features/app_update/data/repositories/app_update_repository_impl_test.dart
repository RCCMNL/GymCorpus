import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/app_update/data/datasources/app_update_remote_data_source.dart';
import 'package:gym_corpus/features/app_update/data/repositories/app_update_repository_impl.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_info.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_status.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppUpdateRemoteDataSource extends Mock
    implements AppUpdateRemoteDataSource {}

void main() {
  late _MockAppUpdateRemoteDataSource remoteDataSource;
  late AppUpdateRepositoryImpl repository;

  const info = AppUpdateInfo(
    latestVersionCode: 10,
    latestVersionName: '1.3.0',
    minSupportedVersionCode: 8,
    apkUrl: 'https://example.com/app.apk',
    changelog: 'Novita e correzioni.',
  );

  setUp(() {
    remoteDataSource = _MockAppUpdateRemoteDataSource();
    repository = AppUpdateRepositoryImpl(remoteDataSource);
  });

  group('checkForUpdate', () {
    test('sotto la soglia minima: aggiornamento obbligatorio', () async {
      when(remoteDataSource.fetchLatest).thenAnswer((_) async => info);

      final result = await repository.checkForUpdate(currentVersionCode: 7);

      expect(
        result,
        const Right<Failure, AppUpdateStatus>(
          AppUpdateStatus(urgency: AppUpdateUrgency.required, info: info),
        ),
      );
    });

    test(
      'alla soglia minima ma sotto l ultima: aggiornamento facoltativo',
      () async {
        when(remoteDataSource.fetchLatest).thenAnswer((_) async => info);

        final result = await repository.checkForUpdate(currentVersionCode: 8);

        expect(
          result,
          const Right<Failure, AppUpdateStatus>(
            AppUpdateStatus(urgency: AppUpdateUrgency.optional, info: info),
          ),
        );
      },
    );

    test('gia sull ultima versione: nessun aggiornamento', () async {
      when(remoteDataSource.fetchLatest).thenAnswer((_) async => info);

      final result = await repository.checkForUpdate(currentVersionCode: 10);

      expect(
        result,
        const Right<Failure, AppUpdateStatus>(AppUpdateStatus.none()),
      );
    });

    test('oltre l ultima versione (build locale): nessun aggiornamento', () async {
      when(remoteDataSource.fetchLatest).thenAnswer((_) async => info);

      final result = await repository.checkForUpdate(currentVersionCode: 11);

      expect(
        result,
        const Right<Failure, AppUpdateStatus>(AppUpdateStatus.none()),
      );
    });

    test('nessuna configurazione pubblicata: nessun aggiornamento', () async {
      when(remoteDataSource.fetchLatest).thenAnswer((_) async => null);

      final result = await repository.checkForUpdate(currentVersionCode: 1);

      expect(
        result,
        const Right<Failure, AppUpdateStatus>(AppUpdateStatus.none()),
      );
    });

    test('errore di rete: fail-open con Failure, non un eccezione', () async {
      when(remoteDataSource.fetchLatest).thenThrow(Exception('offline'));

      final result = await repository.checkForUpdate(currentVersionCode: 1);

      expect(result.isLeft(), isTrue);
      expect(result, isA<Left<Failure, AppUpdateStatus>>());
    });
  });
}
