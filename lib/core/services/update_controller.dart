import 'package:flutter/foundation.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_status.dart';
import 'package:gym_corpus/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Tiene lo stato del controllo aggiornamenti fatto all'avvio.
///
/// Il confronto vive nel repository (testabile a parte); questo controller
/// si occupa solo di leggere il versionCode installato e di notificare il
/// router, sullo stesso schema di `AppLockController`: entra nel
/// `Listenable.merge` che pilota i redirect di GoRouter.
class UpdateController extends ChangeNotifier {
  UpdateController(this._repository);

  final AppUpdateRepository _repository;

  AppUpdateStatus _status = const AppUpdateStatus.none();

  AppUpdateStatus get status => _status;

  bool get isUpdateRequired => _status.urgency == AppUpdateUrgency.required;

  /// Vero anche per l'urgenza [AppUpdateUrgency.required]: chi vuole solo il
  /// promemoria dismissibile deve escludere [isUpdateRequired] a parte.
  bool get isUpdateAvailable => _status.urgency != AppUpdateUrgency.none;

  /// Controlla la versione pubblicata. Fallisce in modo silenzioso: un
  /// errore di rete lascia lo stato a [AppUpdateStatus.none], non deve mai
  /// impedire l'uso dell'app.
  Future<void> checkForUpdate() async {
    final int currentVersionCode;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersionCode = int.parse(packageInfo.buildNumber);
    } catch (e) {
      debugPrint('UpdateController.checkForUpdate: versione locale illeggibile: $e');
      return;
    }

    final result = await _repository.checkForUpdate(
      currentVersionCode: currentVersionCode,
    );
    result.fold(
      (failure) => debugPrint('UpdateController.checkForUpdate: ${failure.message}'),
      (status) {
        _status = status;
        notifyListeners();
      },
    );
  }
}
