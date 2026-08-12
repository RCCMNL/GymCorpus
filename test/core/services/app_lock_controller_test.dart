import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/services/app_lock_controller.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late AppLockController controller;

  setUp(() {
    authRepository = MockAuthRepository();
    controller = AppLockController(authRepository);
  });

  tearDown(() => controller.dispose());

  test('parte sbloccato', () {
    expect(controller.isLocked, isFalse);
  });

  test('non blocca se la biometria non e attiva', () async {
    when(
      () => authRepository.isBiometricEnabled(),
    ).thenAnswer((_) async => false);

    await controller.lockIfEnabled();

    expect(controller.isLocked, isFalse);
  });

  test('blocca e notifica se la biometria e attiva', () async {
    when(
      () => authRepository.isBiometricEnabled(),
    ).thenAnswer((_) async => true);
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.lockIfEnabled();

    expect(controller.isLocked, isTrue);
    expect(notifications, 1);
  });

  test('unlock sblocca e notifica una sola volta', () async {
    when(
      () => authRepository.isBiometricEnabled(),
    ).thenAnswer((_) async => true);
    await controller.lockIfEnabled();

    var notifications = 0;
    controller
      ..addListener(() => notifications++)
      ..unlock()
      ..unlock();

    expect(controller.isLocked, isFalse);
    expect(notifications, 1, reason: 'il secondo unlock non deve notificare');
  });

  test('non riblocca mentre il prompt di sistema e aperto', () async {
    when(
      () => authRepository.isBiometricEnabled(),
    ).thenAnswer((_) async => true);

    // Il prompt biometrico porta l'app in stato inactive: se il ciclo di vita
    // richiudesse il lucchetto proprio ora, l'utente resterebbe intrappolato
    // in un loop di richieste.
    controller.isAuthenticating = true;
    await controller.lockIfEnabled();

    expect(controller.isLocked, isFalse);

    controller.isAuthenticating = false;
    await controller.lockIfEnabled();

    expect(controller.isLocked, isTrue);
  });

  test('un blocco gia attivo non viene rinotificato', () async {
    when(
      () => authRepository.isBiometricEnabled(),
    ).thenAnswer((_) async => true);
    await controller.lockIfEnabled();

    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.lockIfEnabled();

    expect(notifications, 0);
  });
}
