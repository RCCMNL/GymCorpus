import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:injectable/injectable.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserSession(UserEntity user);
  Future<UserEntity?> getUserSession();
  Future<void> clearSession();
  Future<void> saveLocalDataOwner(String userId);
  Future<String?> getLocalDataOwner();
  Future<void> clearLocalDataOwner();
  Future<void> setBiometricEnabled({required bool enabled});
  Future<bool> isBiometricEnabled();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _userKey = 'cached_user_session';
  static const _localDataOwnerKey = 'local_data_owner_id';
  static const _biometricKey = 'biometric_enabled';

  @override
  Future<void> saveUserSession(UserEntity user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: jsonString);
  }

  @override
  Future<UserEntity?> getUserSession() async {
    final jsonString = await _storage.read(key: _userKey);
    if (jsonString != null) {
      try {
        final userMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserEntity.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _userKey);
  }

  @override
  Future<void> saveLocalDataOwner(String userId) async {
    await _storage.write(key: _localDataOwnerKey, value: userId);
  }

  @override
  Future<String?> getLocalDataOwner() {
    return _storage.read(key: _localDataOwnerKey);
  }

  @override
  Future<void> clearLocalDataOwner() async {
    await _storage.delete(key: _localDataOwnerKey);
  }

  @override
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);
    return value == 'true';
  }
}
