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
