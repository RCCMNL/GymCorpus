# Firebase Setup

Questa repo non usa piu' `.env` come asset Flutter per il runtime.

## File nativi

Per avviare il progetto servono i file Firebase generati per le piattaforme native:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

`firebase.json` contiene gia' il riferimento al progetto Firebase e al file di output Android.

## Google Sign-In

Il `server client id` di Google viene letto a compile time tramite `--dart-define`.

Esempio:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=996703301991-gap14vk81ourfhvkaftpnf8ntvc0g68c.apps.googleusercontent.com
```

Per build di release:

```bash
flutter build apk --dart-define=GOOGLE_SERVER_CLIENT_ID=996703301991-gap14vk81ourfhvkaftpnf8ntvc0g68c.apps.googleusercontent.com
```

## Note operative

- `.env` puo' restare locale come appunto personale, ma non viene piu' letto dall'app.
- Se `GOOGLE_SERVER_CLIENT_ID` non viene passato, il login Google fallisce con un messaggio esplicito invece di dipendere da un asset nascosto.
- Dopo la rimozione di `flutter_dotenv` dal `pubspec.yaml`, eseguire `flutter pub get` per riallineare `pubspec.lock`.
