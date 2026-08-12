import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gym_corpus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockUser extends Mock implements User {}

/// Su un dispositivo condiviso i dati locali del precedente utente devono
/// sparire prima che il nuovo completi l'accesso. Se la pulizia fallisce
/// l'accesso non deve proseguire: prima l'errore veniva solo loggato e il
/// nuovo utente si ritrovava routine, allenamenti e pesi altrui.
void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockAuthLocalDataSource localDataSource;
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAppDatabase database;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const UserEntity(id: 'fallback', email: 'fallback@example.com'),
    );
  });

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    localDataSource = MockAuthLocalDataSource();
    remoteDataSource = MockAuthRemoteDataSource();
    database = MockAppDatabase();

    GetIt.I.registerSingleton<AppDatabase>(database);

    repository = AuthRepositoryImpl(
      firebaseAuth,
      localDataSource,
      remoteDataSource,
    );
  });

  tearDown(GetIt.I.reset);

  User buildUser(String uid) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn('nuovo@example.com');
    when(() => user.displayName).thenReturn(null);
    when(() => user.photoURL).thenReturn(null);
    when(() => user.providerData).thenReturn([]);
    return user;
  }

  test(
    'checkSession fallisce e chiude la sessione se la pulizia dati non riesce',
    () async {
      final user = buildUser('utente-nuovo');
      when(() => firebaseAuth.currentUser).thenReturn(user);
      when(
        () => localDataSource.getUserSession(),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.getLocalDataOwner(),
      ).thenAnswer((_) async => 'utente-precedente');
      when(
        database.clearLocalUserData,
      ).thenThrow(Exception('database bloccato'));
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      final result = await repository.checkSession();

      expect(result.isLeft(), isTrue, reason: 'l accesso non deve riuscire');
      verify(() => firebaseAuth.signOut()).called(1);
      verifyNever(() => localDataSource.saveLocalDataOwner(any()));
    },
  );

  test(
    'checkSession non ripulisce nulla se i dati appartengono gia all utente',
    () async {
      final user = buildUser('utente-corrente');
      when(() => firebaseAuth.currentUser).thenReturn(user);
      when(
        () => localDataSource.getUserSession(),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.getLocalDataOwner(),
      ).thenAnswer((_) async => 'utente-corrente');
      when(
        () => remoteDataSource.getUserProfile(any()),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.saveUserSession(any()),
      ).thenAnswer((_) async {});

      await repository.checkSession();

      verifyNever(database.clearLocalUserData);
      verifyNever(() => firebaseAuth.signOut());
    },
  );
}
