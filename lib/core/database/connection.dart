import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

const _databaseFileName = 'gym_db.sqlite';

/// Chiave di cifratura del database, custodita nel secure storage di sistema
/// (Keystore su Android, Keychain su iOS).
const _encryptionKeyStorageKey = 'db_encryption_key_hex';

/// I primi 16 byte di un file SQLite non cifrato. In un file SQLCipher anche
/// l'header e' cifrato, quindi questa firma distingue i due casi.
final _plaintextHeader = latin1.encode('SQLite format 3\u0000');

/// Registra SQLCipher come implementazione sqlite3.
///
/// Su Android il pacchetto `sqlite3` aprirebbe altrimenti la libreria di
/// sistema, che non conosce le PRAGMA di cifratura. Sulle altre piattaforme
/// la libreria corretta viene collegata in fase di build.
void registerSqlCipher() {
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}

/// Apre il database locale cifrato con SQLCipher.
///
/// Il database contiene dati personali e sanitari: storico allenamenti, peso e
/// misure corporee, tracce GPS delle sessioni cardio. Prima veniva scritto in
/// chiaro nella cartella documenti dell'app, quindi era leggibile da un
/// dispositivo con permessi di root, da un backup o con accesso fisico.
///
/// Nota: l'apertura avviene sull'isolate principale e non piu' in background.
/// La chiave arriva dal secure storage, raggiungibile solo tramite i canali di
/// piattaforma, che non sono disponibili in un isolate secondario.
LazyDatabase openConnection({FlutterSecureStorage? storage}) {
  final secureStorage = storage ?? const FlutterSecureStorage();

  return LazyDatabase(() async {
    registerSqlCipher();

    final keyHex = await _obtainEncryptionKey(secureStorage);
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, _databaseFileName));

    await _encryptExistingPlaintextDatabase(file, keyHex);

    return NativeDatabase(file, setup: (db) => _unlock(db, keyHex));
  });
}

/// Recupera la chiave esistente o ne genera una nuova al primo avvio.
Future<String> _obtainEncryptionKey(FlutterSecureStorage storage) async {
  final existing = await storage.read(key: _encryptionKeyStorageKey);
  if (existing != null && existing.length == 64) {
    return existing;
  }

  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  final keyHex =
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

  await storage.write(key: _encryptionKeyStorageKey, value: keyHex);
  return keyHex;
}

/// Sblocca una connessione appena aperta.
void _unlock(Database db, String keyHex) {
  _assertSqlCipherAvailable(db);
  // Forma "raw key": i 32 byte vengono usati direttamente come chiave, senza
  // derivazione, corretto per una chiave gia' generata in modo casuale.
  db.execute('PRAGMA key = "x\'$keyHex\'";');
}

/// Verifica che si stia davvero girando su SQLCipher.
///
/// E' il controllo piu' importante di questo file: con la libreria sqlite3
/// normale la PRAGMA di cifratura non produce alcun errore, si limita a non
/// avere effetto. Senza questa verifica un errore di collegamento delle
/// librerie native, tipico su iOS quando un altro pod collega sqlite3,
/// lascerebbe il database in chiaro dando l'impressione che sia protetto.
void _assertSqlCipherAvailable(Database db) {
  if (db.select('PRAGMA cipher_version;').isEmpty) {
    throw StateError(
      'SQLCipher non disponibile: il database resterebbe in chiaro. '
      'Su iOS e macOS verificare che nessun altro pod colleghi sqlite3 e '
      'aggiungere "-framework SQLCipher" agli Other Linker Flags.',
    );
  }
}

/// Converte in un database cifrato un file lasciato in chiaro da una versione
/// precedente dell'app.
///
/// La conversione passa da un file temporaneo e sostituisce l'originale solo a
/// esportazione riuscita, cosi' un'interruzione a meta' non distrugge i dati.
Future<void> _encryptExistingPlaintextDatabase(File file, String keyHex) async {
  if (!file.existsSync() || !await _isPlaintextDatabase(file)) return;

  final encryptedPath = '${file.path}.migrating';
  final encryptedFile = File(encryptedPath);
  if (encryptedFile.existsSync()) {
    encryptedFile.deleteSync();
  }

  final db = sqlite3.open(file.path);
  try {
    _assertSqlCipherAvailable(db);

    // user_version tiene lo schemaVersion di Drift e non viene copiato da
    // sqlcipher_export. Senza riportarlo, il database cifrato risulterebbe
    // alla versione 0 e Drift proverebbe a ricreare tabelle gia' esistenti.
    final userVersion = db.select('PRAGMA user_version;').first.values.first;

    db
      ..execute(
        'ATTACH DATABASE \'$encryptedPath\' AS encrypted KEY "x\'$keyHex\'";',
      )
      ..execute("SELECT sqlcipher_export('encrypted');")
      ..execute('PRAGMA encrypted.user_version = $userVersion;')
      ..execute('DETACH DATABASE encrypted;');
  } catch (e) {
    if (encryptedFile.existsSync()) {
      encryptedFile.deleteSync();
    }
    debugPrint('[Database] Cifratura del database esistente fallita: $e');
    rethrow;
  } finally {
    db.dispose();
  }

  await file.delete();
  await encryptedFile.rename(file.path);
  debugPrint('[Database] Database locale convertito in formato cifrato.');
}

Future<bool> _isPlaintextDatabase(File file) async {
  final handle = await file.open();
  try {
    final header = await handle.read(_plaintextHeader.length);
    if (header.length < _plaintextHeader.length) return false;

    for (var i = 0; i < _plaintextHeader.length; i++) {
      if (header[i] != _plaintextHeader[i]) return false;
    }
    return true;
  } finally {
    await handle.close();
  }
}
