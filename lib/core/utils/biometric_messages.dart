import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Traduce i codici di errore di `local_auth` in messaggi utili all'utente.
///
/// Senza questa distinzione un sensore bloccato da troppi tentativi risulta
/// indistinguibile da un semplice riconoscimento non riuscito, e l'utente non
/// capisce se deve riprovare, sbloccare il dispositivo o usare la password.
String biometricErrorMessage(PlatformException error) {
  switch (error.code) {
    case auth_error.notAvailable:
    case auth_error.otherOperatingSystem:
      return 'Riconoscimento biometrico non disponibile su questo dispositivo.';
    case auth_error.notEnrolled:
      return 'Nessuna impronta o volto registrato sul dispositivo. '
          'Configurali nelle impostazioni di sistema.';
    case auth_error.passcodeNotSet:
      return 'Imposta un codice di blocco sul dispositivo per usare lo '
          'sblocco biometrico.';
    case auth_error.lockedOut:
      return 'Troppi tentativi falliti. Riprova tra qualche istante.';
    case auth_error.permanentlyLockedOut:
      return 'Riconoscimento bloccato. Sblocca il dispositivo con il codice, '
          'poi riprova.';
    case auth_error.biometricOnlyNotSupported:
      return 'Questo dispositivo non supporta il solo riconoscimento '
          'biometrico.';
    default:
      return 'Non e stato possibile completare il riconoscimento.';
  }
}
