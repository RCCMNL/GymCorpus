# Script di rilascio

`release.js` builda l'apk, lo carica su Firebase Storage e aggiorna il
documento Firestore che l'app legge per il controllo aggiornamenti
(`lib/features/app_update`).

## Setup una tantum

1. `npm install` (dentro questa cartella).
2. Firebase Console > Impostazioni progetto > Account di servizio > Genera
   nuova chiave privata. Salva il file come `scripts/service-account.json`.
   Non va committato: e' gia' in `.gitignore` perche', a differenza di
   `google-services.json`, da' accesso di scrittura completo al progetto.

## Uso

```bash
node scripts/release.js --changelog "Testo delle novita'"
```

Oppure con il changelog in un file:

```bash
node scripts/release.js --changelog-file changelog.txt
```

Per forzare un aggiornamento obbligatorio (blocca chi ha una versione sotto
la soglia indicata):

```bash
node scripts/release.js --changelog "Fix critico" --min-version-code 8
```

Versione e versionCode vengono letti da `version:` in `pubspec.yaml`: va
aggiornato li' prima di lanciare lo script.

## Pubblicazione automatica su push a main

`.github/workflows/release.yml` fa questi passaggi da solo a ogni push su
`main`, ma pubblica sul serio solo se `version:` in `pubspec.yaml` e'
cambiata rispetto al commit precedente. Il flusso per rilasciare una
versione diventa quindi:

1. Alza `version:` in `pubspec.yaml`.
2. Scrivi il changelog per gli utenti in `CHANGELOG_NEXT.txt` (alla radice
   del repo). Se resta vuoto il workflow fallisce con un errore, non
   pubblica una release senza changelog.
3. Committa entrambi i file insieme al resto della modifica e pusha su
   `main`.

Un push che non alza la versione non fa nulla (nessun build, nessuna
release): puoi continuare a pushare commit normali su main senza che
scattino release indesiderate.

### Setup una tantum su GitHub

Il workflow ricostruisce `android/key.properties` e
`scripts/service-account.json` da secret del repository (Settings > Secrets
and variables > Actions > New repository secret), perche' questi file sono
locali e mai committati. Da impostare, coi valori che usi in locale:

- `ANDROID_KEYSTORE_BASE64`: il file `.jks` codificato in base64
  (`base64 -w0 gymcorpus-release.jks` su Linux/Git Bash, o
  `[Convert]::ToBase64String([IO.File]::ReadAllBytes("gymcorpus-release.jks"))`
  in PowerShell).
- `ANDROID_KEYSTORE_PASSWORD`: `storePassword` da `android/key.properties`.
- `ANDROID_KEY_PASSWORD`: `keyPassword` da `android/key.properties`.
- `ANDROID_KEY_ALIAS`: `keyAlias` da `android/key.properties` (`gymcorpus`).
- `FIREBASE_SERVICE_ACCOUNT`: il contenuto intero di
  `scripts/service-account.json`.

Imposta questi secret tu stesso dal browser o con `gh secret set NOME < file`
dal tuo terminale: nessuno di questi valori deve passare da qui.
