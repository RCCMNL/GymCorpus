import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    String? firstName;
    String? lastName;

    if (user.displayName != null) {
      final parts = user.displayName!.split(' ');
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    return UserEntity(
      id: user.uid,
      firstName: firstName ?? 'Atleta',
      lastName: lastName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      authProviders: user.providerData.map((info) => info.providerId).toList(),
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
    try {
      await _remoteDataSource.saveUserProfile(updatedUser).timeout(const Duration(seconds: 5));
    } catch (_) {}
    try {
      await _localDataSource.saveUserSession(updatedUser);
    } catch (_) {}
    return updatedUser;
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final baseUser = _mapFirebaseUser(credential.user!);
        final remoteUser = await _remoteDataSource.getUserProfile(baseUser.id);
        final user = (remoteUser ?? baseUser)
            .copyWith(authProviders: baseUser.authProviders);

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
    String email,
    String password,
  ) async {
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
      UserEntity? mergedUser =
          cachedUser != null && cachedUser.id == baseUser.id
              ? cachedUser
              : baseUser;

      try {
        final remoteUser = await _remoteDataSource
            .getUserProfile(baseUser.id)
            .timeout(const Duration(seconds: 5));
        if (remoteUser != null) {
          mergedUser = remoteUser;
          await _localDataSource.saveUserSession(remoteUser);
        }
      } catch (e) {
        // Fallback to local/base if remote fails, logging could go here
      }

      final finalUser = mergedUser!;
      final updatedSessionUser = finalUser.copyWith(
        firstName: firebaseUser.displayName != null
            ? firebaseUser.displayName!.split(' ').first
            : finalUser.firstName,
        lastName: firebaseUser.displayName != null &&
                firebaseUser.displayName!.contains(' ')
            ? firebaseUser.displayName!.split(' ').sublist(1).join(' ')
            : finalUser.lastName,
        photoUrl: firebaseUser.photoURL ?? finalUser.photoUrl,
        authProviders: baseUser.authProviders,
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
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );

      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['openid', 'email', 'profile']);
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
        final user = (remoteUser ?? baseUser)
            .copyWith(authProviders: baseUser.authProviders);

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
        final user = (remoteUser ?? baseUser)
            .copyWith(authProviders: baseUser.authProviders);

        final finalUser = await _updateLoginHistory(user);
        return Right(finalUser);
      }
      return const Left(AuthFailure('Impossibile accedere con Apple'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfileImage(
      String filePath,) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(filePath);
        await user.reload();

        final currentUser =
            await _localDataSource.getUserSession() ?? _mapFirebaseUser(user);
        final updatedUser = currentUser.copyWith(
          photoUrl: filePath,
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
    String? firstName,
    String? lastName,
    String? username,
    String? gender,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Utente non autenticato'));
      }

      if (firstName != null && firstName.isNotEmpty) {
        final fullName = '$firstName ${lastName ?? ''}'.trim();
        await user
            .updateDisplayName(fullName)
            .timeout(const Duration(seconds: 5));
      }

      final localUser = await _localDataSource.getUserSession();
      final remoteUser = await _remoteDataSource
          .getUserProfile(user.uid)
          .timeout(const Duration(seconds: 5));
      final currentUser = localUser ?? remoteUser ?? _mapFirebaseUser(user);

      final updatedUser = currentUser.copyWith(
        firstName: firstName ?? currentUser.firstName,
        lastName: lastName ?? currentUser.lastName,
        username: (username != null && username.isNotEmpty)
            ? username
            : currentUser.username,
        gender: gender ?? currentUser.gender,
        weight: weight ?? currentUser.weight,
        height: height ?? currentUser.height,
        birthDate: birthDate ?? currentUser.birthDate,
        trainingObjective: trainingObjective ?? currentUser.trainingObjective,
      );

      // Save locally first for speed
      await _localDataSource.saveUserSession(updatedUser);
      // Then sync to remote
      await _remoteDataSource
          .saveUserProfile(updatedUser)
          .timeout(const Duration(seconds: 5));

      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure('Errore durante aggiornamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      String currentPassword, String newPassword,) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Nessun utente autenticato'));
      }

      final email = user.email!;
      final cred =
          EmailAuthProvider.credential(email: email, password: currentPassword);

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
      if (user == null) {
        return const Left(AuthFailure('Nessun utente autenticato'));
      }

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
