import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/utils/biometric_messages.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

void main() {
  String messageFor(String code) =>
      biometricErrorMessage(PlatformException(code: code));

  test('distingue il blocco temporaneo da quello permanente', () {
    // Erano il caso peggiore del vecchio comportamento: entrambi finivano in
    // un ramo vuoto e l'utente vedeva il pulsante semplicemente non reagire.
    expect(messageFor(auth_error.lockedOut), contains('qualche istante'));
    expect(
      messageFor(auth_error.permanentlyLockedOut),
      contains('Sblocca il dispositivo'),
    );
    expect(
      messageFor(auth_error.lockedOut),
      isNot(messageFor(auth_error.permanentlyLockedOut)),
    );
  });

  test('spiega come rimediare quando manca la configurazione', () {
    expect(messageFor(auth_error.notEnrolled), contains('impostazioni'));
    expect(messageFor(auth_error.passcodeNotSet), contains('codice di blocco'));
  });

  test('ha un messaggio di riserva per i codici sconosciuti', () {
    final message = messageFor('QualcosaDiInatteso');

    expect(message, isNotEmpty);
    expect(message, isNot(contains('QualcosaDiInatteso')));
  });

  test('ogni codice noto ha un messaggio non vuoto', () {
    const codes = [
      auth_error.notAvailable,
      auth_error.notEnrolled,
      auth_error.passcodeNotSet,
      auth_error.lockedOut,
      auth_error.permanentlyLockedOut,
      auth_error.otherOperatingSystem,
      auth_error.biometricOnlyNotSupported,
    ];

    for (final code in codes) {
      expect(messageFor(code), isNotEmpty, reason: 'codice $code');
    }
  });
}
