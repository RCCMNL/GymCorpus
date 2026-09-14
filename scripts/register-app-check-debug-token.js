#!/usr/bin/env node
// Registra un token di debug App Check (quello stampato in logcat dal tag
// DebugAppCheckProvider su una build debug) cosi' quel device puo' leggere/
// scrivere su Firestore/Storage senza superare l'attestazione Play
// Integrity, che sulle build debug non e' disponibile.
//
// Uso:
//   node scripts/register-app-check-debug-token.js <token> <app-id> [nome]
//
// <app-id> e' il mobilesdk_app_id ("1:...:android:...") dell'app Android
// giusta: compare nello stesso messaggio di log del token, o in
// android/app/google-services.json se c'e' una sola variante installata.
//
// Richiede scripts/service-account.json (vedi scripts/README.md).

const fs = require('node:fs');
const path = require('node:path');

const serviceAccountPath = path.join(__dirname, 'service-account.json');

async function main() {
  const [token, appId, displayName] = process.argv.slice(2);
  if (!token || !appId) {
    throw new Error(
      'Uso: node scripts/register-app-check-debug-token.js <token> <app-id> [nome]',
    );
  }
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Manca ${serviceAccountPath}: vedi scripts/README.md per generarlo.`,
    );
  }

  const admin = require('firebase-admin');
  const app = admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
  });

  const { project_id: projectId } = require(serviceAccountPath);
  const accessToken = await app.options.credential.getAccessToken();
  const url = `https://firebaseappcheck.googleapis.com/v1/projects/${projectId}/apps/${appId}/debugTokens`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken.access_token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      displayName: displayName ?? `device-${new Date().toISOString().slice(0, 10)}`,
      token,
    }),
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(`App Check API ${response.status}: ${JSON.stringify(body)}`);
  }

  console.log(`Token registrato: ${body.name}`);
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exitCode = 1;
});
