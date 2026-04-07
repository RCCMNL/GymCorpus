import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/data/datasources/auth_local_data_source.dart';
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
  AuthRepositoryImpl(this._firebaseAuth, this._localDataSource);

  final FirebaseAuth _firebaseAuth;
  final AuthLocalDataSource _localDataSource;

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? 'Atleta Gym',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
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
        final user = _mapFirebaseUser(credential.user!);
        await _localDataSource.saveUserSession(user);
        return Right(user);
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
        await _localDataSource.saveUserSession(user);
        return Right(user);
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
      if (cachedUser != null && cachedUser.id == baseUser.id) {
        // Merge Firebase status with local extended profile
        return Right(cachedUser.copyWith(
          name: firebaseUser.displayName ?? cachedUser.name,
          photoUrl: firebaseUser.photoURL ?? cachedUser.photoUrl,
        ));
      }
      return Right(baseUser);
    }

    if (cachedUser != null) {
      return Right(cachedUser);
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
        final user = _mapFirebaseUser(userCredential.user!);
        await _localDataSource.saveUserSession(user);
        return Right(user);
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
        final user = _mapFirebaseUser(userCredential.user!);
        await _localDataSource.saveUserSession(user);
        return Right(user);
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
      if (user != null) {
        if (name != null) {
          await user.updateDisplayName(name);
        }
        
        final currentUser = await _localDataSource.getUserSession() ?? _mapFirebaseUser(user);
        
        final updatedUser = UserEntity(
          id: currentUser.id,
          name: name ?? currentUser.name,
          email: currentUser.email,
          photoUrl: currentUser.photoUrl,
          username: username ?? currentUser.username,
          weight: weight ?? currentUser.weight,
          height: height ?? currentUser.height,
          birthDate: birthDate ?? currentUser.birthDate,
          trainingObjective: trainingObjective ?? currentUser.trainingObjective,
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
      
      await user.delete();
      await _localDataSource.clearSession();
      
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Errore eliminazione account'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
