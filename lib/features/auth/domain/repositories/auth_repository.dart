import 'package:dartz/dartz.dart';
import 'package:gym_corpus/core/error/failures.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> checkSession();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithApple();
}
