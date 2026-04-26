import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('migra il vecchio campo name in firstName e lastName', () {
      final user = UserEntity.fromJson(const {
        'id': 'u1',
        'name': 'Mario Rossi',
        'email': 'mario@example.com',
      });

      expect(user.firstName, 'Mario');
      expect(user.lastName, 'Rossi');
      expect(user.fullName, 'Mario Rossi');
    });

    test('serializza e deserializza i campi profilo completi', () {
      final birthDate = DateTime(1994, 6, 12);
      final lastLoginDate = DateTime(2026, 4, 26, 10, 30);
      final consentDate = DateTime(2026, 4, 26, 12);
      final user = UserEntity(
        id: 'u1',
        email: 'mario@example.com',
        firstName: 'Mario',
        lastName: 'Rossi',
        username: 'mario_rossi',
        gender: 'Uomo',
        weight: 80,
        height: 180,
        birthDate: birthDate,
        trainingObjective: 'Forza',
        lastLoginDate: lastLoginDate,
        lastLoginDevice: 'Pixel',
        termsAcceptedAt: consentDate,
        privacyAcceptedAt: consentDate,
        legalVersion: '2026-04-26',
        marketingConsent: true,
        marketingConsentUpdatedAt: consentDate,
        profilingConsentUpdatedAt: consentDate,
        authProviders: const ['password'],
        loginHistory: [
          LoginEntry(date: lastLoginDate, device: 'Pixel'),
        ],
      );

      final parsed = UserEntity.fromJson(user.toJson());

      expect(parsed, user);
      expect(parsed.toJson()['birthDate'], birthDate.toIso8601String());
      expect(
        parsed.toJson()['termsAcceptedAt'],
        consentDate.toIso8601String(),
      );
      expect(parsed.marketingConsent, isTrue);
      expect(parsed.profilingConsent, isFalse);
      expect(parsed.loginHistory.single.device, 'Pixel');
    });

    test('copyWith aggiorna i campi e puo cancellare il peso', () {
      const user = UserEntity(
        id: 'u1',
        email: 'mario@example.com',
        firstName: 'Mario',
        weight: 80,
      );

      final updated = user.copyWith(
        username: 'mario_rossi',
        gender: 'Uomo',
        marketingConsent: true,
        clearWeight: true,
      );

      expect(updated.firstName, 'Mario');
      expect(updated.username, 'mario_rossi');
      expect(updated.gender, 'Uomo');
      expect(updated.marketingConsent, isTrue);
      expect(updated.profilingConsent, isFalse);
      expect(updated.weight, isNull);
    });
  });
}
