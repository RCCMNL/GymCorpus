import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<void> saveUserProfile(UserEntity user);
  Future<UserEntity?> getUserProfile(String userId);
  Future<void> deleteUser(String userId);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';

  @override
  Future<void> saveUserProfile(UserEntity user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserEntity.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_usersCollection).doc(userId).delete();
  }
}
