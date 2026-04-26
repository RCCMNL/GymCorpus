import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
const _currentLegalVersion = '2026-04-26';

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

  final _userStreamController = StreamController<UserEntity?>.broadcast();

  @override
  Stream<UserEntity?> get userStream => _userStreamController.stream;

  bool _isPortablePhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return false;
    }
    return photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
  }

  String? _mergePhotoUrl({
    required String? remotePhotoUrl,
    required String? localPhotoUrl,
  }) {
    if (_isPortablePhotoUrl(remotePhotoUrl)) {
      return remotePhotoUrl;
    }
    if (localPhotoUrl != null && localPhotoUrl.isNotEmpty) {
      return localPhotoUrl;
    }
    return null;
  }

  UserEntity _sanitizeRemoteUser(UserEntity user) {
    if (_isPortablePhotoUrl(user.photoUrl)) {
      return user;
    }
    return user.copyWith();
  }

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
    } catch (e) {
      debugPrint('AuthRepositoryImpl._getDeviceInfo error: $e');
    }
    return 'Dispositivo Sconosciuto';
  }

  Future<UserEntity> _updateLoginHistory(UserEntity user) async {
    final device = await _getDeviceInfo();
    final now = DateTime.now();

    final newEntry = LoginEntry(date: now, device: device);

    // Seed history if empty using previous lastLogin data
    final List<LoginEntry> currentHistory = List.from(user.loginHistory);
    if (currentHistory.isEmpty && user.lastLoginDate != null) {
      currentHistory.add(
        LoginEntry(
          date: user.lastLoginDate!,
          device: user.lastLoginDevice ?? 'Dispositivo Precedente',
        ),
      );
    }

    final updatedHistory = [newEntry, ...currentHistory].take(5).toList();

    final updatedUser = user.copyWith(
      lastLoginDate: now,
      lastLoginDevice: device,
      loginHistory: updatedHistory,
    );
    try {
      await _remoteDataSource
          .saveUserProfile(_sanitizeRemoteUser(updatedUser))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint(
        'AuthRepositoryImpl._updateLoginHistory remote sync error: $e',
      );
    }
    try {
      await _localDataSource.saveUserSession(updatedUser);
    } catch (e) {
      debugPrint(
        'AuthRepositoryImpl._updateLoginHistory local cache error: $e',
      );
    }
    return updatedUser;
  }

  UserEntity _applyLegalConsents(
    UserEntity user, {
    required bool acceptedTerms,
    required bool acceptedPrivacy,
    required bool marketingConsent,
    required bool profilingConsent,
  }) {
    final now = DateTime.now();
    return user.copyWith(
      termsAcceptedAt: acceptedTerms ? now : user.termsAcceptedAt,
      privacyAcceptedAt: acceptedPrivacy ? now : user.privacyAcceptedAt,
      legalVersion:
          acceptedTerms && acceptedPrivacy ? _currentLegalVersion : null,
      marketingConsent: marketingConsent,
      profilingConsent: profilingConsent,
      marketingConsentUpdatedAt: now,
      profilingConsentUpdatedAt: now,
    );
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
        _userStreamController.add(finalUser);
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
          final mergedRemoteUser = remoteUser.copyWith(
            photoUrl: _mergePhotoUrl(
              remotePhotoUrl: firebaseUser.photoURL ?? remoteUser.photoUrl,
              localPhotoUrl: cachedUser?.photoUrl,
            ),
          );
          mergedUser = mergedRemoteUser;
          await _localDataSource.saveUserSession(mergedRemoteUser);
        }
      } catch (e) {
        debugPrint(
          'AuthRepositoryImpl.checkSession remote profile sync error: $e',
        );
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
        photoUrl: _mergePhotoUrl(
          remotePhotoUrl: firebaseUser.photoURL ?? finalUser.photoUrl,
          localPhotoUrl: cachedUser?.photoUrl,
        ),
        authProviders: baseUser.authProviders,
      );
      final finalSessionUser = await _updateLoginHistory(updatedSessionUser);
      _userStreamController.add(finalSessionUser);
      return Right(finalSessionUser);
    }

    if (cachedUser != null) {
      final finalSessionUser = await _updateLoginHistory(cachedUser);
      _userStreamController.add(finalSessionUser);
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
  Future<Either<Failure, UserEntity>> signInWithGoogle({
    bool acceptedTerms = false,
    bool acceptedPrivacy = false,
    bool marketingConsent = false,
    bool profilingConsent = false,
  }) async {
    try {
      if (_googleServerClientId.isEmpty) {
        return const Left(
          AuthFailure(
            "Configurazione Google Sign-In mancante. Avvia l'app con "
            '--dart-define=GOOGLE_SERVER_CLIENT_ID=...',
          ),
        );
      }

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: _googleServerClientId,
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
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser && (!acceptedTerms || !acceptedPrivacy)) {
          await userCredential.user!.delete();
          await _firebaseAuth.signOut();
          return const Left(
            AuthFailure(
              'Per creare un nuovo account devi accettare Termini e Privacy Policy.',
            ),
          );
        }

        final baseUser = _mapFirebaseUser(userCredential.user!);
        final remoteUser = isNewUser
            ? null
            : await _remoteDataSource.getUserProfile(baseUser.id);
        var user = (remoteUser ?? baseUser)
            .copyWith(authProviders: baseUser.authProviders);
        if (isNewUser) {
          user = _applyLegalConsents(
            user,
            acceptedTerms: acceptedTerms,
            acceptedPrivacy: acceptedPrivacy,
            marketingConsent: marketingConsent,
            profilingConsent: profilingConsent,
          );
        }

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
  Future<Either<Failure, UserEntity>> signInWithApple({
    bool acceptedTerms = false,
    bool acceptedPrivacy = false,
    bool marketingConsent = false,
    bool profilingConsent = false,
  }) async {
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
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser && (!acceptedTerms || !acceptedPrivacy)) {
          await userCredential.user!.delete();
          await _firebaseAuth.signOut();
          return const Left(
            AuthFailure(
              'Per creare un nuovo account devi accettare Termini e Privacy Policy.',
            ),
          );
        }

        final baseUser = _mapFirebaseUser(userCredential.user!);
        final remoteUser = isNewUser
            ? null
            : await _remoteDataSource.getUserProfile(baseUser.id);
        var user = (remoteUser ?? baseUser)
            .copyWith(authProviders: baseUser.authProviders);
        if (isNewUser) {
          user = _applyLegalConsents(
            user,
            acceptedTerms: acceptedTerms,
            acceptedPrivacy: acceptedPrivacy,
            marketingConsent: marketingConsent,
            profilingConsent: profilingConsent,
          );
        }

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
    String filePath,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
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
    DateTime? termsAcceptedAt,
    DateTime? privacyAcceptedAt,
    String? legalVersion,
    bool? marketingConsent,
    bool? profilingConsent,
    DateTime? marketingConsentUpdatedAt,
    DateTime? profilingConsentUpdatedAt,
    bool clearWeight = false,
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
        clearWeight: clearWeight,
        height: height ?? currentUser.height,
        birthDate: birthDate ?? currentUser.birthDate,
        trainingObjective: trainingObjective ?? currentUser.trainingObjective,
        termsAcceptedAt: termsAcceptedAt ?? currentUser.termsAcceptedAt,
        privacyAcceptedAt: privacyAcceptedAt ?? currentUser.privacyAcceptedAt,
        legalVersion: legalVersion ?? currentUser.legalVersion,
        marketingConsent: marketingConsent ?? currentUser.marketingConsent,
        profilingConsent: profilingConsent ?? currentUser.profilingConsent,
        marketingConsentUpdatedAt:
            marketingConsentUpdatedAt ?? currentUser.marketingConsentUpdatedAt,
        profilingConsentUpdatedAt:
            profilingConsentUpdatedAt ?? currentUser.profilingConsentUpdatedAt,
      );

      // Save locally first for speed
      await _localDataSource.saveUserSession(updatedUser);
      // Then sync to remote
      await _remoteDataSource
          .saveUserProfile(_sanitizeRemoteUser(updatedUser))
          .timeout(const Duration(seconds: 5));

      _userStreamController.add(updatedUser);
      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure('Errore durante aggiornamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
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
  Future<Either<Failure, void>> deleteAccount({String? currentPassword}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Nessun utente autenticato'));
      }

      final reauthResult = await _reauthenticateUser(
        user,
        currentPassword: currentPassword,
      );
      if (reauthResult.isLeft()) {
        return reauthResult;
      }

      await _remoteDataSource.deleteUser(user.uid);
      await user.delete();
      await _localDataSource.clearSession();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return const Left(
          AuthFailure(
            "Per eliminare l'account devi confermare di nuovo l'accesso e riprovare.",
          ),
        );
      }
      return Left(AuthFailure(e.message ?? 'Errore eliminazione account'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> _reauthenticateUser(
    User user, {
    String? currentPassword,
  }) async {
    try {
      final providerIds =
          user.providerData.map((info) => info.providerId).toSet();

      if (providerIds.contains('password')) {
        final email = user.email;
        if (email == null || email.isEmpty) {
          return const Left(
            AuthFailure(
              "Email account non disponibile per confermare l'operazione",
            ),
          );
        }
        if (currentPassword == null || currentPassword.isEmpty) {
          return const Left(
            AuthFailure(
              "Inserisci la password attuale per confermare l'eliminazione dell'account",
            ),
          );
        }

        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        return const Right(null);
      }

      if (providerIds.contains('google.com')) {
        if (_googleServerClientId.isEmpty) {
          return const Left(
            AuthFailure(
              "Configurazione Google Sign-In mancante. Avvia l'app con "
              '--dart-define=GOOGLE_SERVER_CLIENT_ID=...',
            ),
          );
        }

        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(
          serverClientId: _googleServerClientId,
        );

        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final authorization = await googleUser.authorizationClient
            .authorizationForScopes(['openid', 'email', 'profile']);

        final credential = GoogleAuthProvider.credential(
          accessToken: authorization?.accessToken,
          idToken: googleAuth.idToken,
        );

        await user.reauthenticateWithCredential(credential);
        return const Right(null);
      }

      if (providerIds.contains('apple.com')) {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: const <AppleIDAuthorizationScopes>[],
        );

        final credential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        await user.reauthenticateWithCredential(credential);
        return const Right(null);
      }

      return const Left(
        AuthFailure(
          'Provider di accesso non supportato per la conferma automatica. '
          'Accedi di nuovo e riprova.',
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(e.message ?? 'Errore durante la conferma account'),
      );
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
