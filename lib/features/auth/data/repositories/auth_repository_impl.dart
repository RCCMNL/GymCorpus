import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';
import 'package:gym_corpus/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthFailure extends Failure {
  const AuthFailure(super.message);

  @override
  List<Object> get props => [message];
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebaseAuth,
    this._localDataSource,
    this._remoteDataSource,
  );

  final FirebaseAuth _firebaseAuth;
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? 'Atleta Gym',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}'.trim();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
    } catch (_) {}
    return 'Dispositivo Sconosciuto';
  }

  Future<UserEntity> _updateLoginHistory(UserEntity user) async {
    final device = await _getDeviceInfo();
    final updatedUser = user.copyWith(
      lastLoginDate: DateTime.now(),
      lastLoginDevice: device,
    );
    // Silent update to remote and local
    unawaited(_remoteDataSource.saveUserProfile(updatedUser));
    unawaited(_localDataSource.saveUserSession(updatedUser));
    return updatedUser;
  }

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password,) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final baseUser = _mapFirebaseUser(credential.user!);
        final remoteUser = await _remoteDataSource.getUserProfile(baseUser.id);
        final user = remoteUser ?? baseUser;
        
        final finalUser = await _updateLoginHistory(user);
        return Right(finalUser);
      }
      return const Left(
        AuthFailure('Errore durante il login: utente non trovato'),
      );
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore di autenticazione'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(
      String email, String password,) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = _mapFirebaseUser(credential.user!);
        final finalUser = await _updateLoginHistory(user);
        return Right(finalUser);
      }
      return const Left(
        AuthFailure("Errore durante la creazione dell'account"),
      );
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore di registrazione'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _firebaseAuth.signOut();
    await _localDataSource.clearSession();
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> checkSession() async {
    final firebaseUser = _firebaseAuth.currentUser;
    final cachedUser = await _localDataSource.getUserSession();

    if (firebaseUser != null) {
      final baseUser = _mapFirebaseUser(firebaseUser);
      
      // Try local cache first for instant UI response
      UserEntity? mergedUser = cachedUser != null && cachedUser.id == baseUser.id ? cachedUser : baseUser;

      try {
        final remoteUser = await _remoteDataSource.getUserProfile(baseUser.id).timeout(const Duration(seconds: 5));
        if (remoteUser != null) {
          mergedUser = remoteUser;
          await _localDataSource.saveUserSession(remoteUser);
        }
      } catch (e) {
        // Fallback to local/base if remote fails, logging could go here
      }

      final finalUser = mergedUser!;
      final updatedSessionUser = finalUser.copyWith(
        name: firebaseUser.displayName ?? finalUser.name,
        photoUrl: firebaseUser.photoURL ?? finalUser.photoUrl,
      );
      final finalSessionUser = await _updateLoginHistory(updatedSessionUser);
      return Right(finalSessionUser);
    }

    if (cachedUser != null) {
      final finalSessionUser = await _updateLoginHistory(cachedUser);
      return Right(finalSessionUser);
    }

    return const Left(AuthFailure('Nessuna sessione attiva'));
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore nel ripristino password'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId:
            '996703301991-gap14vk81ourfhvkaftpnf8ntvc0g68c.apps.googleusercontent.com',
      );

      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      final authorization = await googleUser.authorizationClient.authorizationForScopes(['openid', 'email', 'profile']);
      final accessToken = authorization?.accessToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final baseUser = _mapFirebaseUser(userCredential.user!);
        final remoteUser = await _remoteDataSource.getUserProfile(baseUser.id);
        final user = remoteUser ?? baseUser;
        
        final finalUser = await _updateLoginHistory(user);
        return Right(finalUser);
      }
      return const Left(AuthFailure('Impossibile accedere con Google'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore login Google'));
    } catch (e) {
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        return const Left(AuthFailure('Login annullato'));
      }
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final baseUser = _mapFirebaseUser(userCredential.user!);
        final remoteUser = await _remoteDataSource.getUserProfile(baseUser.id);
        final user = remoteUser ?? baseUser;
        
        final finalUser = await _updateLoginHistory(user);
        return Right(finalUser);
      }
      return const Left(AuthFailure('Impossibile accedere con Apple'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, UserEntity>> updateProfileImage(String filePath) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(filePath);
        await user.reload();
        
        final currentUser = await _localDataSource.getUserSession() ?? _mapFirebaseUser(user);
        final updatedUser = UserEntity(
          id: currentUser.id,
          name: currentUser.name,
          email: currentUser.email,
          photoUrl: filePath,
          username: currentUser.username,
          weight: currentUser.weight,
          height: currentUser.height,
          birthDate: currentUser.birthDate,
          trainingObjective: currentUser.trainingObjective,
        );
        
        await _localDataSource.saveUserSession(updatedUser);
        return Right(updatedUser);
      }
      return const Left(AuthFailure('Utente non autenticato'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfileDetails({
    String? name,
    String? username,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return const Left(AuthFailure('Utente non autenticato'));

      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name).timeout(const Duration(seconds: 5));
      }
      
      final localUser = await _localDataSource.getUserSession();
      final remoteUser = await _remoteDataSource.getUserProfile(user.uid).timeout(const Duration(seconds: 5));
      final currentUser = localUser ?? remoteUser ?? _mapFirebaseUser(user);
      
      final updatedUser = currentUser.copyWith(
        name: (name != null && name.isNotEmpty) ? name : currentUser.name,
        username: (username != null && username.isNotEmpty) ? username : currentUser.username,
        weight: weight ?? currentUser.weight,
        height: height ?? currentUser.height,
        birthDate: birthDate ?? currentUser.birthDate,
        trainingObjective: trainingObjective ?? currentUser.trainingObjective,
      );
      
      // Save locally first for speed
      await _localDataSource.saveUserSession(updatedUser);
      // Then sync to remote
      await _remoteDataSource.saveUserProfile(updatedUser).timeout(const Duration(seconds: 5));
      
      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure('Errore durante aggiornamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return const Left(AuthFailure('Nessun utente autenticato'));
      
      final email = user.email!;
      final cred = EmailAuthProvider.credential(email: email, password: currentPassword);
      
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore cambio password'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return const Left(AuthFailure('Nessun utente autenticato'));
      
      // Eliminiamo PRIMA i dati in firestore
      await _remoteDataSource.deleteUser(user.uid);
      
      await user.delete();
      await _localDataSource.clearSession();
      
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore eliminazione account'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _localDataSource.isBiometricEnabled();
  }

  @override
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _localDataSource.setBiometricEnabled(enabled: enabled);
  }
}
