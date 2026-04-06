import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gym_corpus/core/database/connection.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase(openConnection());

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
}
