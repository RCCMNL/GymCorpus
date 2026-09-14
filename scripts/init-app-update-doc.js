#!/usr/bin/env node
// Crea/sovrascrive app_update/android con la versione attualmente installata
// dagli utenti, senza bloccare nessuno: serve solo a far partire il
// meccanismo di controllo aggiornamenti (lib/features/app_update) prima
// ancora che esista una release passata da scripts/release.js.
//
// apkUrl resta vuoto di proposito: il repository non lo legge quando
// currentVersionCode >= latestVersionCode (vedi
// AppUpdateRepositoryImpl.checkForUpdate), che e' sempre il caso finche'
// questo e' l'unico documento mai scritto. La prima release vera fatta con
// `node scripts/release.js` lo sovrascrive con un link reale.
//
// Uso: node scripts/init-app-update-doc.js
// Richiede scripts/service-account.json (vedi scripts/README.md).

const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');
const serviceAccountPath = path.join(__dirname, 'service-account.json');

function readPubspecVersion() {
  const pubspec = fs.readFileSync(path.join(repoRoot, 'pubspec.yaml'), 'utf8');
  const match = pubspec.match(/^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m);
  if (!match) {
    throw new Error("Non trovo una riga 'version: X.Y.Z+N' in pubspec.yaml");
  }
  return { versionName: match[1], versionCode: Number.parseInt(match[2], 10) };
}

async function main() {
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Manca ${serviceAccountPath}: vedi scripts/README.md per generarlo.`,
    );
  }

  const { versionName, versionCode } = readPubspecVersion();

  const admin = require('firebase-admin');
  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
  });

  const docRef = admin.firestore().collection('app_update').doc('android');
  await docRef.set({
    latestVersionCode: versionCode,
    latestVersionName: versionName,
    minSupportedVersionCode: versionCode,
    apkUrl: '',
    changelog: '',
    releasedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`app_update/android creato: versione ${versionName}+${versionCode}, nessuno bloccato.`);
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exitCode = 1;
});
