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

La configurazione Firebase e versionata nel repository, perche le API key lato client
non sono segreti: la protezione sta nelle regole Firestore, nelle restrizioni delle
chiavi e in App Check.

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`
- Opzioni Dart: `lib/firebase_options.dart`
- Regole Firestore: `firestore.rules`
- Google Sign-In server client id: passa `GOOGLE_SERVER_CLIENT_ID` via `--dart-define`

Dettagli completi in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

## Dati locali e cifratura

Il database locale contiene dati personali e sanitari (storico allenamenti, peso e
misure corporee, tracce GPS delle sessioni cardio) ed e cifrato con SQLCipher.

- La chiave e generata al primo avvio e custodita nel secure storage di sistema
  (Keystore su Android, Keychain su iOS). Non viene mai scritta su disco in chiaro.
- I database creati da versioni precedenti dell'app vengono convertiti
  automaticamente al primo avvio, passando da un file temporaneo.
- All'apertura viene verificato `PRAGMA cipher_version`: se SQLCipher non e
  attivo l'app fallisce con un errore esplicito invece di proseguire in chiaro.
  Con la libreria sqlite3 normale, infatti, `PRAGMA key` non da errore, semplicemente
  non ha effetto.

Come arriva SQLCipher:

- Dal pacchetto `sqlite3` versione 3, che collega la libreria nativa con i build hook
  di Dart. La scelta di SQLCipher al posto di SQLite sta in `pubspec.yaml`:

  ```yaml
  hooks:
    user_defines:
      sqlite3:
        source: sqlcipher
  ```

  Senza quella sezione verrebbe collegato SQLite normale, e l'app si fermerebbe al
  controllo su `cipher_version`. Il hook scarica binari precompilati, quindi la prima
  build richiede la rete.
- **Android**: nessun setup nel progetto nativo. Il workaround per Android 6 e
  precedenti non serve, il progetto ha `minSdk = 26`. Verificato a settembre 2026 su
  un dispositivo con Android 16: un database cifrato dalla vecchia
  `sqlcipher_flutter_libs` (SQLCipher 4.5.5) si apre con la versione 3 (SQLCipher
  4.18.0) senza conversioni, perche' dentro SQLCipher 4 il formato del file non cambia.
  Con un futuro SQLCipher 5 la prova andra' rifatta.
- **iOS e macOS**: non ancora verificati dopo il passaggio alla versione 3. Se un'altra
  libreria nativa collegasse gia' SQLite, vedi `doc/hook.md` del pacchetto `sqlite3`;
  il controllo su `cipher_version` fa emergere il problema al primo avvio.
- Non aggiungere `sqlite3_flutter_libs` ne' `sqlcipher_flutter_libs`: con la versione 3
  di `sqlite3` non servono piu', e `sqlcipher_flutter_libs` e' stato dismesso.

> Se il secure storage perde la chiave (cancellazione dati app, ripristino su un
> nuovo dispositivo) i dati locali non sono piu' recuperabili. E una conseguenza
> voluta della cifratura, coerente con `allowBackup="false"` sul manifest Android.

## Build di release

Le build di release Android sono firmate con una keystore dedicata, mai versionata.

1. Genera la keystore una sola volta e conservala con backup: se la perdi non puoi
   piu' pubblicare aggiornamenti dell'app sullo stesso listing.

```bash
keytool -genkey -v -keystore gymcorpus-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias gymcorpus
```

2. Copia `android/key.properties.example` in `android/key.properties` e compila
   percorso della keystore, alias e password.
3. Compila:

```bash
flutter build appbundle --release
```

Se `android/key.properties` non esiste, la build di release viene prodotta **non
firmata** e Gradle stampa un avviso: e' voluto, per evitare di distribuire per
sbaglio un artefatto firmato con la chiave di debug.

## Qualita

Comandi utili prima di aprire una PR o creare una release:

```bash
flutter analyze
flutter test
```

## 📧 Contatti
- **Email**: riccardiemanuele2016@outlook.it
- **LinkedIn**: [Emanuele Riccardi](https://www.linkedin.com/in/emanuele-riccardi-5819b422a/)
- **Portfolio**: https://portfolio-riccardiemanuele.vercel.app/
- **GitHub**: [@RCCMNL](https://github.com/RCCMNL/)


<p align="center">
  Sviluppato con ❤️ per la Community Fitness
</p>
## Documentazione interna

- [AGENTS.md](AGENTS.md): convenzioni operative per agenti e automazioni
- [AUDIT_FIXES.md](AUDIT_FIXES.md): piano di bonifica tecnica e audit
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md): setup Firebase per ambienti locali e CI

## Licenza

Questo progetto e distribuito con licenza proprietaria. Vedi [LICENSE](LICENSE).
