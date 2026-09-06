import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:gym_corpus/features/auth/data/local_user_data_guard.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _MockAppDatabase extends Mock implements AppDatabase {}

/// Su un dispositivo condiviso i dati del precedente utente devono sparire
/// prima che il nuovo entri. Questa regola stava dentro il repository di
/// autenticazione, dove non c'entrava e non era verificabile da sola.
void main() {
  late _MockAuthLocalDataSource localDataSource;
  late _MockAppDatabase database;
  late LocalUserDataGuard guard;

  setUp(() {
    localDataSource = _MockAuthLocalDataSource();
    database = _MockAppDatabase();

    GetIt.I.registerSingleton<AppDatabase>(database);
    guard = LocalUserDataGuard(localDataSource);

    when(database.clearLocalUserData).thenAnswer((_) async {});
    when(
      () => localDataSource.saveLocalDataOwner(any()),
    ).thenAnswer((_) async {});
    when(localDataSource.clearLocalDataOwner).thenAnswer((_) async {});
  });

  tearDown(GetIt.I.reset);

  test('se i dati sono gia dell utente non tocca niente', () async {
    when(localDataSource.getLocalDataOwner).thenAnswer((_) async => 'utente-1');

    await guard.prepareFor('utente-1');

    verifyNever(database.clearLocalUserData);
    verifyNever(() => localDataSource.saveLocalDataOwner(any()));
  });

  test('i dati di un altro utente vengono cancellati', () async {
    when(
      localDataSource.getLocalDataOwner,
    ).thenAnswer((_) async => 'utente-precedente');

    await guard.prepareFor('utente-nuovo');

    verify(database.clearLocalUserData).called(1);
    verify(() => localDataSource.saveLocalDataOwner('utente-nuovo')).called(1);
  });

  test(
    'al primo accesso su un dispositivo pulito registra il proprietario',
    () async {
      when(localDataSource.getLocalDataOwner).thenAnswer((_) async => null);

      await guard.prepareFor('utente-1');

      verify(() => localDataSource.saveLocalDataOwner('utente-1')).called(1);
    },
  );

  test('se la pulizia fallisce lo dice invece di proseguire', () async {
    // Proseguire significherebbe mostrare al nuovo utente routine,
    // allenamenti e pesi di chi lo ha preceduto.
    when(
      localDataSource.getLocalDataOwner,
    ).thenAnswer((_) async => 'utente-precedente');
    when(database.clearLocalUserData).thenThrow(Exception('database bloccato'));

    expect(
      () => guard.prepareFor('utente-nuovo'),
      throwsA(isA<LocalDataCleanupException>()),
    );
  });

  test('il proprietario non registrato non blocca la pulizia', () async {
    when(
      localDataSource.getLocalDataOwner,
    ).thenAnswer((_) async => 'utente-precedente');
    when(
      () => localDataSource.saveLocalDataOwner(any()),
    ).thenThrow(Exception('scrittura fallita'));

    expect(
      () => guard.prepareFor('utente-nuovo'),
      throwsA(isA<LocalDataCleanupException>()),
    );
  });

  test(
    'un errore nel dimenticare il proprietario non blocca l uscita',
    () async {
      when(localDataSource.clearLocalDataOwner).thenThrow(Exception('errore'));

      // Al massimo il prossimo accesso ripulira' di nuovo i dati locali:
      // impedire il logout sarebbe molto peggio.
      await expectLater(guard.clearOwner(), completes);
    },
  );
}
