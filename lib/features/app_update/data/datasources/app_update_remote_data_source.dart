import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_corpus/features/app_update/domain/entities/app_update_info.dart';
import 'package:injectable/injectable.dart';

// ignore: one_member_abstracts
abstract class AppUpdateRemoteDataSource {
  /// Legge la configurazione di rilascio corrente, o `null` se non e' mai
  /// stata pubblicata (prima installazione dello schema, o documento
  /// cancellato).
  Future<AppUpdateInfo?> fetchLatest();
}

@LazySingleton(as: AppUpdateRemoteDataSource)
class AppUpdateRemoteDataSourceImpl implements AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collection = 'app_update';
  // Solo Android e' distribuito fuori store (apk diretto): iOS non ha un
  // meccanismo di aggiornamento equivalente, quindi non legge questo doc.
  static const _docId = 'android';

  @override
  Future<AppUpdateInfo?> fetchLatest() async {
    final doc = await _firestore.collection(_collection).doc(_docId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return AppUpdateInfo.fromJson(data);
  }
}
