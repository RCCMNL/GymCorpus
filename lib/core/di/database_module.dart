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

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
