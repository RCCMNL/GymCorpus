import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get userStream;
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> checkSession();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, UserEntity>> signInWithGoogle({
    bool acceptedTerms = false,
    bool acceptedPrivacy = false,
    bool marketingConsent = false,
    bool profilingConsent = false,
  });
  Future<Either<Failure, UserEntity>> signInWithApple({
    bool acceptedTerms = false,
    bool acceptedPrivacy = false,
    bool marketingConsent = false,
    bool profilingConsent = false,
  });
  Future<Either<Failure, UserEntity>> updateProfileImage(String filePath);
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
    bool syncWeightHistory = false,
  });
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
  Future<Either<Failure, void>> deleteAccount({String? currentPassword});
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled({required bool enabled});
}
