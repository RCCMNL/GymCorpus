import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_corpus/core/database/connection.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:path/path.dart' as p;

/// La cifratura del database locale, provata sulla macchina di sviluppo.
///
/// Con la libreria SQLite normale `PRAGMA key` non da' errore: semplicemente
/// non cifra. Questi test aprono davvero un file e ne leggono i byte, quindi
/// falliscono se al posto di SQLCipher e' collegato SQLite.
void main() {
  const chiave =
      '0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF';
  const altraChiave =
      'FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210';
  const intestazioneInChiaro = 'SQLite format 3\u0000';

  late Directory tempDir;
  late File file;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gym_corpus_cipher');
    file = File(p.join(tempDir.path, 'gym_db.sqlite'));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<AppDatabase> apri(String keyHex) async =>
      AppDatabase(await openEncryptedDatabase(file, keyHex: keyHex));

  String intestazioneDelFile() =>
      String.fromCharCodes(file.readAsBytesSync().take(16));

  Future<int> versioneDiSchema(AppDatabase db) async {
    final riga = await db.customSelect('PRAGMA user_version').getSingle();
    return riga.read<int>('user_version');
  }

  test('la libreria collegata e davvero SQLCipher', () async {
    final db = await apri(chiave);
    addTearDown(db.close);

    final righe = await db.customSelect('PRAGMA cipher_version').get();

    expect(righe, isNotEmpty);
  });

  test('il file su disco non si legge come un database in chiaro', () async {
    final db = await apri(chiave);
    await db.select(db.exercises).get();
    await db.close();

    expect(intestazioneDelFile(), isNot(intestazioneInChiaro));
  });

  test('riaprendo con la stessa chiave i dati si ritrovano', () async {
    final primo = await apri(chiave);
    final esercizi = await primo.select(primo.exercises).get();
    await primo.close();

    final secondo = await apri(chiave);
    addTearDown(secondo.close);

    expect(esercizi, isNotEmpty);
    expect(
      await secondo.select(secondo.exercises).get(),
      hasLength(esercizi.length),
    );
  });

  test('con un altra chiave il database non si apre', () async {
    final primo = await apri(chiave);
    await primo.select(primo.exercises).get();
    await primo.close();

    final estraneo = await apri(altraChiave);
    addTearDown(estraneo.close);

    // Non basta che fallisca: deve fallire perche' la chiave e' sbagliata,
    // non perche' manca SQLCipher.
    await expectLater(
      estraneo.select(estraneo.exercises).get(),
      throwsA(isNot(isA<StateError>())),
    );
  });

  test(
    'un database in chiaro di una versione precedente viene cifrato senza perdere dati',
    () async {
      // Il database come lo scriveva l'app prima della cifratura.
      final inChiaro = AppDatabase(NativeDatabase(file));
      final esercizi = await inChiaro.select(inChiaro.exercises).get();
      final versione = await versioneDiSchema(inChiaro);
      await inChiaro.close();
      expect(intestazioneDelFile(), intestazioneInChiaro);

      final cifrato = await apri(chiave);
      addTearDown(cifrato.close);

      expect(
        await cifrato.select(cifrato.exercises).get(),
        hasLength(esercizi.length),
      );
      expect(await versioneDiSchema(cifrato), versione);
      expect(intestazioneDelFile(), isNot(intestazioneInChiaro));
    },
  );
}
