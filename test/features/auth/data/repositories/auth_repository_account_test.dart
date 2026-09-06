import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gym_corpus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockUser extends Mock implements User {}

class _MockUserInfo extends Mock implements UserInfo {}

class _MockUserCredential extends Mock implements UserCredential {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

/// Eliminazione account e cambio password: i due punti in cui un errore non
/// si limita a mostrare un messaggio storto, ma cancella l'account di
/// qualcuno o glielo lascia aperto.
void main() {
  late _MockFirebaseAuth firebaseAuth;
  late _MockAuthLocalDataSource localDataSource;
  late _MockAuthRemoteDataSource remoteDataSource;
  late _MockAppDatabase database;
  late AuthRepositoryImpl repository;
  late _MockUser user;

  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
  });

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
    localDataSource = _MockAuthLocalDataSource();
    remoteDataSource = _MockAuthRemoteDataSource();
    database = _MockAppDatabase();
    user = _MockUser();

    GetIt.I.registerSingleton<AppDatabase>(database);

    repository = AuthRepositoryImpl(
      firebaseAuth,
      localDataSource,
      remoteDataSource,
    );

    when(() => firebaseAuth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('utente-1');
    when(() => user.email).thenReturn('mario@example.com');
    when(() => user.delete()).thenAnswer((_) async {});
    when(
      () => user.reauthenticateWithCredential(any()),
    ).thenAnswer((_) async => _MockUserCredential());
    when(() => user.updatePassword(any())).thenAnswer((_) async {});
    when(() => remoteDataSource.deleteUser(any())).thenAnswer((_) async {});
    when(database.clearLocalUserData).thenAnswer((_) async {});
    when(localDataSource.clearSession).thenAnswer((_) async {});
    when(localDataSource.clearLocalDataOwner).thenAnswer((_) async {});
  });

  tearDown(GetIt.I.reset);

  /// Account creato con email e password: per cancellarlo serve la password.
  void withPasswordProvider() {
    final info = _MockUserInfo();
    when(() => info.providerId).thenReturn('password');
    when(() => user.providerData).thenReturn([info]);
  }

  group('eliminazione account', () {
    test('senza utente autenticato non cancella niente', () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final result = await repository.deleteAccount();

      expect(result.isLeft(), isTrue);
      verifyNever(() => remoteDataSource.deleteUser(any()));
      verifyNever(() => user.delete());
    });

    test('senza la password attuale l account resta al suo posto', () async {
      // E' la protezione piu' importante di tutto il flusso: senza,
      // basterebbe premere il pulsante per perdere l'account.
      withPasswordProvider();

      final result = await repository.deleteAccount();

      expect(result.isLeft(), isTrue);
      verifyNever(() => user.reauthenticateWithCredential(any()));
      verifyNever(() => remoteDataSource.deleteUser(any()));
      verifyNever(() => user.delete());
    });

    test('con la password sbagliata non cancella niente', () async {
      withPasswordProvider();
      when(() => user.reauthenticateWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: 'errata'),
      );

      final result = await repository.deleteAccount(
        currentPassword: 'sbagliata',
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => remoteDataSource.deleteUser(any()));
      verifyNever(() => user.delete());
    });

    test('con la password giusta cancella account e dati locali', () async {
      withPasswordProvider();

      final result = await repository.deleteAccount(currentPassword: 'giusta');

      expect(result.isRight(), isTrue);
      verify(() => remoteDataSource.deleteUser('utente-1')).called(1);
      verify(() => user.delete()).called(1);
      verify(database.clearLocalUserData).called(1);
      verify(localDataSource.clearSession).called(1);
      verify(localDataSource.clearLocalDataOwner).called(1);
    });

    test(
      'se la pulizia locale fallisce la sessione viene chiusa lo stesso',
      () async {
        // L'account remoto a quel punto non esiste piu': lasciare la sessione
        // aperta significherebbe un'app che mostra i dati di un account
        // cancellato.
        withPasswordProvider();
        when(database.clearLocalUserData).thenThrow(Exception('disco pieno'));

        final result = await repository.deleteAccount(
          currentPassword: 'giusta',
        );

        expect(result.isRight(), isTrue);
        verify(localDataSource.clearSession).called(1);
      },
    );

    test('una sessione troppo vecchia chiede di riaccedere', () async {
      withPasswordProvider();
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));

      final result = await repository.deleteAccount(currentPassword: 'giusta');

      result.fold(
        (failure) =>
            expect(failure.message, contains("confermare di nuovo l'accesso")),
        (_) => fail('l eliminazione non doveva riuscire'),
      );
    });
  });

  group('cambio password', () {
    test('senza utente autenticato non cambia niente', () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final result = await repository.changePassword('vecchia', 'nuova');

      expect(result.isLeft(), isTrue);
      verifyNever(() => user.updatePassword(any()));
    });

    test('la password attuale viene verificata prima di cambiarla', () async {
      final result = await repository.changePassword('vecchia', 'nuova');

      expect(result.isRight(), isTrue);
      verifyInOrder([
        () => user.reauthenticateWithCredential(any()),
        () => user.updatePassword('nuova'),
      ]);
    });

    test('se la verifica fallisce la password non viene toccata', () async {
      when(() => user.reauthenticateWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: 'errata'),
      );

      final result = await repository.changePassword('sbagliata', 'nuova');

      expect(result.isLeft(), isTrue);
      verifyNever(() => user.updatePassword(any()));
    });
  });

  test('una password sbagliata viene detta in italiano e senza gerghi', () {
    // Il messaggio di Firebase e' in inglese e parla di "credential":
    // qui l'utente deve capire che ha solo sbagliato a digitare.
    withPasswordProvider();
    when(() => user.reauthenticateWithCredential(any())).thenThrow(
      FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid',
      ),
    );

    return repository.deleteAccount(currentPassword: 'sbagliata').then((
      result,
    ) {
      result.fold(
        (failure) => expect(failure.message, contains('non e corretta')),
        (_) => fail('l eliminazione non doveva riuscire'),
      );
    });
  });
}
