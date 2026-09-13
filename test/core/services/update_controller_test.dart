import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/core/services/update_controller.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_info.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_status.dart';
import 'package:gym_corpus/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockAppUpdateRepository extends Mock implements AppUpdateRepository {}

void main() {
  late _MockAppUpdateRepository repository;
  late UpdateController controller;

  const info = AppUpdateInfo(
    latestVersionCode: 10,
    latestVersionName: '1.3.0',
    minSupportedVersionCode: 8,
    apkUrl: 'https://example.com/app.apk',
    changelog: 'Novita.',
  );

  setUp(() {
    repository = _MockAppUpdateRepository();
    controller = UpdateController(repository);

    PackageInfo.setMockInitialValues(
      appName: 'GymCorpus',
      packageName: 'it.rccmnl.gymcorpus',
      version: '1.2.0',
      buildNumber: '7',
      buildSignature: '',
    );
  });

  test('stato iniziale: nessun aggiornamento', () {
    expect(controller.isUpdateRequired, isFalse);
    expect(controller.isUpdateAvailable, isFalse);
  });

  test('aggiornamento obbligatorio: aggiorna stato e notifica', () async {
    when(
      () => repository.checkForUpdate(currentVersionCode: 7),
    ).thenAnswer(
      (_) async =>
          const Right(AppUpdateStatus(urgency: AppUpdateUrgency.required, info: info)),
    );

    var notified = false;
    controller.addListener(() => notified = true);

    await controller.checkForUpdate();

    expect(controller.isUpdateRequired, isTrue);
    expect(controller.isUpdateAvailable, isTrue);
    expect(controller.status.info, info);
    expect(notified, isTrue);
  });

  test('aggiornamento facoltativo: disponibile ma non obbligatorio', () async {
    when(
      () => repository.checkForUpdate(currentVersionCode: 7),
    ).thenAnswer(
      (_) async =>
          const Right(AppUpdateStatus(urgency: AppUpdateUrgency.optional, info: info)),
    );

    await controller.checkForUpdate();

    expect(controller.isUpdateRequired, isFalse);
    expect(controller.isUpdateAvailable, isTrue);
  });

  test('errore dal repository: fail-open, nessuna notifica', () async {
    when(
      () => repository.checkForUpdate(currentVersionCode: 7),
    ).thenAnswer((_) async => const Left(ServerFailure('offline')));

    var notified = false;
    controller.addListener(() => notified = true);

    await controller.checkForUpdate();

    expect(controller.isUpdateRequired, isFalse);
    expect(notified, isFalse);
  });
}
