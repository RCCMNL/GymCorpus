import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:gym_corpus/core/database/database.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart';

/// Sollevata quando i dati locali dell'account precedente non possono essere
/// rimossi prima di completare l'accesso di un altro utente.
///
/// L'accesso non deve proseguire in questo caso: su un dispositivo condiviso
/// il nuovo utente vedrebbe routine, allenamenti e pesi di chi lo ha
/// preceduto, serviti dagli stream ancora attivi sul database locale.
class LocalDataCleanupException implements Exception {
  const LocalDataCleanupException();

  @override
  String toString() =>
      'Non e stato possibile preparare i dati locali per questo account. '
      'Riprova; se il problema persiste riavvia l app.';
}

/// Custodisce la proprieta' del database locale.
///
/// Non e' autenticazione: e' persistenza. Vive fuori dal repository auth
/// perche' quel file deve restare l'implementazione dell'interfaccia
/// `AuthRepository`, e perche' questa regola merita un test suo.
class LocalUserDataGuard {
  const LocalUserDataGuard(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  /// Assicura che i dati locali appartengano a [userId].
  ///
  /// Se appartengono gia' a lui non tocca niente. Altrimenti li cancella e
  /// registra il nuovo proprietario; se la pulizia fallisce solleva
  /// [LocalDataCleanupException], e chi chiama deve interrompere l'accesso.
  Future<void> prepareFor(String userId) async {
    final ownerId = await _localDataSource.getLocalDataOwner();
    if (ownerId == userId) return;

    try {
      await GetIt.I<AppDatabase>().clearLocalUserData();
      await _localDataSource.saveLocalDataOwner(userId);
    } catch (e) {
      debugPrint('LocalUserDataGuard.prepareFor error: $e');
      throw const LocalDataCleanupException();
    }
  }

  /// Dimentica il proprietario corrente, all'uscita o alla cancellazione.
  ///
  /// Un errore qui non deve impedire il logout: al massimo il prossimo
  /// accesso ripulira' di nuovo i dati locali.
  Future<void> clearOwner() async {
    try {
      await _localDataSource.clearLocalDataOwner();
    } catch (e) {
      debugPrint('LocalUserDataGuard.clearOwner error: $e');
    }
  }
}
