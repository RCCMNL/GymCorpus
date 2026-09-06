import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('copyWith senza argomenti non modifica la foto profilo', () {
      const user = UserEntity(
        id: 'u1',
        email: 'mario@example.com',
        photoUrl: '/data/user/0/files/avatar.jpg',
      );

      // Comportamento atteso di copyWith, ma anche la ragione per cui serve
      // un flag esplicito: _sanitizeRemoteUser si affidava a copyWith() per
      // rimuovere la foto locale e in realta' non rimuoveva nulla.
      expect(user.copyWith().photoUrl, user.photoUrl);
    });

    test('clearPhotoUrl rimuove il percorso locale della foto', () {
      const user = UserEntity(
        id: 'u1',
        email: 'mario@example.com',
        photoUrl: '/data/user/0/files/avatar.jpg',
      );

      final sanitized = user.copyWith(clearPhotoUrl: true);

      expect(sanitized.photoUrl, isNull);
      expect(sanitized.id, user.id, reason: 'gli altri campi restano intatti');
      expect(sanitized.email, user.email);
    });

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
        loginHistory: [LoginEntry(date: lastLoginDate, device: 'Pixel')],
      );

      final parsed = UserEntity.fromJson(user.toJson());

      expect(parsed, user);
      expect(parsed.toJson()['birthDate'], birthDate.toIso8601String());
      expect(parsed.toJson()['termsAcceptedAt'], consentDate.toIso8601String());
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

  group('isProfileComplete', () {
    /// Le informazioni che l'app chiede a chiunque crei un profilo: senza
    /// una di queste l'utente viene riportato all'onboarding, da qualunque
    /// percorso sia entrato.
    UserEntity complete({
      String? firstName = 'Mario',
      String? lastName = 'Rossi',
      String? username = 'mario',
      DateTime? birthDate,
      String? gender = 'Uomo',
    }) {
      return UserEntity(
        id: '1',
        email: 'mario@example.com',
        firstName: firstName,
        lastName: lastName,
        username: username,
        birthDate: birthDate ?? DateTime(1990, 5, 12),
        gender: gender,
      );
    }

    test('un profilo con tutte le informazioni di base e completo', () {
      expect(complete().isProfileComplete, isTrue);
    });

    test('senza genere il profilo non e completo', () {
      // Il caso di chi entra con Google: Firebase non fornisce il sesso.
      expect(complete(gender: null).isProfileComplete, isFalse);
    });

    test('senza data di nascita il profilo non e completo', () {
      expect(
        const UserEntity(
          id: '1',
          email: 'mario@example.com',
          firstName: 'Mario',
          lastName: 'Rossi',
          username: 'mario',
          gender: 'Uomo',
        ).isProfileComplete,
        isFalse,
      );
    });

    test('senza nome, cognome o username il profilo non e completo', () {
      expect(complete(firstName: null).isProfileComplete, isFalse);
      expect(complete(lastName: null).isProfileComplete, isFalse);
      expect(complete(username: null).isProfileComplete, isFalse);
    });

    test('i campi riempiti di soli spazi non contano come compilati', () {
      // Un nome fatto di spazi passerebbe un controllo di sola nullita e
      // lascerebbe entrare un profilo di fatto vuoto.
      expect(complete(firstName: '   ').isProfileComplete, isFalse);
      expect(complete(username: ' ').isProfileComplete, isFalse);
      expect(complete(gender: '').isProfileComplete, isFalse);
    });
  });
}
