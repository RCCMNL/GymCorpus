import 'package:flutter/foundation.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';

/// Tiene lo stato del blocco applicativo protetto da biometria.
///
/// L'impostazione "Sblocco biometrico" prometteva una protezione che non
/// esisteva: il prompt biometrico viveva solo dentro `LoginScreen`, che per un
/// utente con sessione Firebase gia' attiva non viene mai mostrata. L'app si
/// apriva quindi direttamente su `/training`, mostrando allenamenti, dati di
/// salute e profilo a chiunque avesse in mano il telefono sbloccato.
///
/// Il controller espone lo stato di blocco al redirect di GoRouter, che
/// dirotta su `/lock` finche' l'utente non si autentica.
class AppLockController extends ChangeNotifier {
  AppLockController(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLocked = false;

  /// Vero mentre e' aperto il prompt di sistema per il riconoscimento.
  ///
  /// Il prompt porta l'app in stato `inactive`: senza questa guardia il
  /// listener del ciclo di vita richiuderebbe il lucchetto proprio mentre
  /// l'utente si sta autenticando, creando un loop da cui non si esce.
  bool isAuthenticating = false;

  bool get isLocked => _isLocked;

  /// Attiva il blocco, ma solo se l'utente ha abilitato la biometria.
  Future<void> lockIfEnabled() async {
    if (_isLocked || isAuthenticating) return;

    final enabled = await _authRepository.isBiometricEnabled();
    // Ricontrollato dopo l'await: nel frattempo lo stato puo' essere cambiato.
    if (!enabled || _isLocked || isAuthenticating) return;

    _isLocked = true;
    notifyListeners();
  }

  void unlock() {
    if (!_isLocked) return;
    _isLocked = false;
    notifyListeners();
  }
}
