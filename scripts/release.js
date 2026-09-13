#!/usr/bin/env node
// Pubblica una nuova release Android: builda l'apk, lo carica su Firebase
// Storage e scrive il documento Firestore che l'app legge all'avvio per
// il controllo aggiornamenti (vedi lib/features/app_update).
//
// Uso:
//   node scripts/release.js --changelog "Testo delle novita'"
//   node scripts/release.js --changelog-file changelog.txt
//   node scripts/release.js --changelog "..." --min-version-code 8
//
// --min-version-code forza la soglia minima supportata (blocca chi ha una
// versione piu' vecchia). Se omesso, resta quella gia' scritta su Firestore;
// se non esiste ancora un documento, di default e' uguale alla versione
// appena pubblicata (nessuno resta bloccato dalla prima release).
//
// Richiede scripts/service-account.json: dalla Firebase Console, Impostazioni
// progetto > Account di servizio > Genera nuova chiave privata. Non va
// committato (e' in .gitignore): da' accesso di scrittura completo al
// progetto, a differenza di google-services.json che e' un identificatore
// pubblico.
//
// Setup una tantum: `npm install` dentro scripts/.

const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');
const serviceAccountPath = path.join(__dirname, 'service-account.json');

function parseArgs(argv) {
  const args = { changelog: '', minVersionCode: null };
  for (let i = 0; i < argv.length; i += 1) {
    switch (argv[i]) {
      case '--changelog':
        args.changelog = argv[++i] ?? '';
        break;
      case '--changelog-file':
        args.changelog = fs.readFileSync(argv[++i], 'utf8').trim();
        break;
      case '--min-version-code':
        args.minVersionCode = Number.parseInt(argv[++i], 10);
        break;
      default:
        throw new Error(`Argomento sconosciuto: ${argv[i]}`);
    }
  }
  return args;
}

/** Legge `version: 1.2.0+7` da pubspec.yaml: versionName e versionCode
 * Android arrivano entrambi da qui, non c'e' un'altra fonte di verita'. */
function readPubspecVersion() {
  const pubspec = fs.readFileSync(path.join(repoRoot, 'pubspec.yaml'), 'utf8');
  const match = pubspec.match(/^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m);
  if (!match) {
    throw new Error("Non trovo una riga 'version: X.Y.Z+N' in pubspec.yaml");
  }
  return { versionName: match[1], versionCode: Number.parseInt(match[2], 10) };
}

function buildReleaseApk() {
  console.log('Build APK di release...');
  execFileSync('flutter', ['build', 'apk', '--release'], {
    cwd: repoRoot,
    stdio: 'inherit',
    shell: true,
  });
  const apkPath = path.join(
    repoRoot,
    'build',
    'app',
    'outputs',
    'flutter-apk',
    'app-release.apk',
  );
  if (!fs.existsSync(apkPath)) {
    throw new Error(`Apk non trovato dopo la build: ${apkPath}`);
  }
  return apkPath;
}

async function uploadApk(bucket, apkPath, versionName, versionCode) {
  const destination = `releases/app-${versionName}+${versionCode}.apk`;
  console.log(`Carico ${destination} su Firebase Storage...`);
  const [file] = await bucket.upload(apkPath, {
    destination,
    metadata: { contentType: 'application/vnd.android.package-archive' },
  });

  // Link firmato con scadenza lontana invece di un ACL pubblico: funziona
  // anche se il bucket ha l'accesso uniforme a livello di bucket abilitato
  // (che rende inutilizzabile makePublic()), e non richiede toccare le
  // regole di Storage.
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: '01-01-2099',
  });
  return url;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.changelog) {
    throw new Error('Serve --changelog "..." oppure --changelog-file <path>');
  }
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Manca ${serviceAccountPath}: vedi il commento in testa allo script per generarlo.`,
    );
  }

  const { versionName, versionCode } = readPubspecVersion();
  console.log(`Rilascio ${versionName}+${versionCode}`);

  const apkPath = buildReleaseApk();

  const admin = require('firebase-admin');
  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
    storageBucket: 'gymcorpus-project.firebasestorage.app',
  });

  const bucket = admin.storage().bucket();
  const apkUrl = await uploadApk(bucket, apkPath, versionName, versionCode);

  const docRef = admin.firestore().collection('app_update').doc('android');
  const existing = await docRef.get();
  const minSupportedVersionCode =
    args.minVersionCode ?? existing.data()?.minSupportedVersionCode ?? versionCode;

  await docRef.set({
    latestVersionCode: versionCode,
    latestVersionName: versionName,
    minSupportedVersionCode,
    apkUrl,
    changelog: args.changelog,
    releasedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log('Fatto.');
  console.log(`  latestVersionCode: ${versionCode}`);
  console.log(`  minSupportedVersionCode: ${minSupportedVersionCode}`);
  console.log(`  apkUrl: ${apkUrl}`);
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exitCode = 1;
});
