# GymCorpus

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg?style=for-the-badge)](LICENSE)

GymCorpus e una app Flutter per la gestione di allenamenti, esercizi, progressi e profilo utente con persistenza locale e integrazione Firebase.

## Stack

- Flutter + Dart
- flutter_bloc
- GoRouter
- Drift / SQLite
- Firebase Auth
- Injectable / GetIt

## Struttura

```text
lib/
|-- core/
|   |-- database/
|   |-- di/
|   |-- error/
|   |-- router/
|   |-- theme/
|   |-- utils/
|   `-- widgets/
|-- features/
|   |-- analytics/
|   |-- auth/
|   |-- exercises/
|   |-- profile/
|   `-- training/
|-- firebase_options.dart
`-- main.dart
```

## Setup locale

1. Installa Flutter SDK e gli strumenti della piattaforma che ti servono.
2. Recupera le dipendenze:

```bash
flutter pub get
```

3. Rigenera i file generati quando cambi modelli, Drift o Freezed:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Avvia l'app:

```bash
flutter run
```

## Firebase

La configurazione Firebase non e inclusa nel repository.

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`
- Google Sign-In server client id: passa `GOOGLE_SERVER_CLIENT_ID` via `--dart-define`

Dettagli completi in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

## Qualita

Comandi utili prima di aprire una PR o creare una release:

```bash
flutter analyze
flutter test
```

## Documentazione interna

- [AGENTS.md](AGENTS.md): convenzioni operative per agenti e automazioni
- [AUDIT_FIXES.md](AUDIT_FIXES.md): piano di bonifica tecnica e audit
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md): setup Firebase per ambienti locali e CI

## Licenza

Questo progetto e distribuito con licenza proprietaria. Vedi [LICENSE](LICENSE).
