import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gym_corpus/core/database/connection.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DatabaseModule {
  /// Il database prende la chiave di cifratura dal secure storage, quindi
  /// quest'ultimo va iniettato invece di essere istanziato qui: cosi' l'app e
  /// i test usano la stessa istanza.
  @lazySingleton
  AppDatabase appDatabase(FlutterSecureStorage storage) =>
      AppDatabase(openConnection(storage: storage));

  /// Storage sicuro con opzioni esplicite invece dei default.
  ///
  /// Custodisce la sessione utente, la preferenza di sblocco biometrico e la
  /// chiave di cifratura del database, quindi vale la pena essere espliciti:
  ///
  /// - `encryptedSharedPreferences` su Android forza il backend basato su
  ///   Keystore anziche' le SharedPreferences in chiaro delle versioni
  ///   precedenti del plugin.
  /// - `first_unlock_this_device` su iOS impedisce che il portachiavi venga
  ///   migrato su un altro dispositivo tramite backup o ripristino: la chiave
  ///   del database non deve seguire i dati altrove.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
