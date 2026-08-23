# Firebase Setup

## File nativi

I file di configurazione Firebase sono **versionati di proposito**:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist` (da generare al primo setup iOS)
- `lib/firebase_options.dart`

`firebase.json` contiene gia' il riferimento al progetto Firebase e al file di output Android.

Per rigenerarli dopo un cambio di progetto o di package name:

```bash
flutterfire configure
```

### Perche' sono nel repository

Le API key contenute in questi file sono **identificatori pubblici lato client**, non
segreti: Google le progetta per essere incorporate nell'app e chiunque puo' estrarle da
un APK. Tenerle nel repo rende la build riproducibile senza passaggi manuali.

La protezione reale non sta nel nasconderle, ma in tre controlli lato server che vanno
configurati e verificati nella console Firebase/Google Cloud:

1. **Regole Firestore** — vedi `firestore.rules` nel repo. Sono la difesa principale:
   senza regole corrette, chiunque abbia l'API key puo' leggere e scrivere i dati.
2. **Restrizioni delle chiavi API** — su Google Cloud Console limita ogni chiave per
   applicazione (SHA-1 del certificato Android, bundle id iOS) e per API abilitate.
3. **App Check** — verifica che le richieste arrivino davvero dalla tua app e non da
   uno script esterno. E' la mitigazione contro abuso di quota e signup di massa.

> Non aggiungere questi file a `.gitignore`. In passato le regole c'erano ma i file
> erano gia' tracciati: le regole non avevano alcun effetto e davano una falsa
> impressione di protezione.

## Segreti compile-time (`dart_defines.json`)

Le variabili sensibili vengono iniettate a **compile-time** tramite `--dart-define-from-file`.
Questo approccio e' preferito rispetto a `.env` perche' i valori vengono incorporati nel
binario compilato invece di essere caricati come asset leggibile nel pacchetto.

### Setup iniziale

1. Copia il template:

```bash
cp dart_defines.example.json dart_defines.json
```

2. Compila `dart_defines.json` con i tuoi valori reali:

```json
{
  "GOOGLE_SERVER_CLIENT_ID": "tuo-id.apps.googleusercontent.com"
}
```

> **IMPORTANTE**: `dart_defines.json` e' nel `.gitignore` e non deve MAI essere committato.
> Solo `dart_defines.example.json` (con valori placeholder) e' tracciato da Git.

### Avvio da terminale

```bash
flutter run --dart-define-from-file=dart_defines.json
```

### Avvio da VS Code / Antigravity

Le configurazioni in `.vscode/launch.json` includono gia' il parametro
`--dart-define-from-file=dart_defines.json`. Basta premere **F5** o usare
il pannello Run & Debug.

### Build di release

```bash
flutter build apk --dart-define-from-file=dart_defines.json
flutter build appbundle --dart-define-from-file=dart_defines.json
flutter build ios --dart-define-from-file=dart_defines.json
```

### CI/CD

Nella pipeline di CI/CD, genera `dart_defines.json` al volo dai Secrets della piattaforma:

```yaml
# Esempio GitHub Actions
- name: Create dart_defines.json
  run: |
    echo '{
      "GOOGLE_SERVER_CLIENT_ID": "${{ secrets.GOOGLE_SERVER_CLIENT_ID }}"
    }' > dart_defines.json
```

## Note operative

- `.env` puo' restare locale come appunto personale, ma non viene letto dall'app.
- Se `GOOGLE_SERVER_CLIENT_ID` non viene passato, il login Google fallisce con un messaggio esplicito.
- Per aggiungere nuove variabili compile-time, aggiungi la chiave sia in `dart_defines.json`
  (locale) sia in `dart_defines.example.json` (con placeholder) e accedile nel codice con
  `const String.fromEnvironment('CHIAVE')`.
