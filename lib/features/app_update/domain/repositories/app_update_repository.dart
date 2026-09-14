import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_status.dart';

// Un solo metodo, ma resta un'interfaccia: e' cio' che la rende sostituibile
// nei test (vedi ExternalLinks per lo stesso ragionamento).
// ignore: one_member_abstracts
abstract class AppUpdateRepository {
  /// Confronta [currentVersionCode] con l'ultima versione pubblicata.
  ///
  /// Il versionCode va passato dal chiamante (letto con `package_info_plus`)
  /// invece di essere letto qui, cosi' il confronto resta testabile senza
  /// dover simulare il canale nativo del pacchetto.
  Future<Either<Failure, AppUpdateStatus>> checkForUpdate({
    required int currentVersionCode,
  });
}
