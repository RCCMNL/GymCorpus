import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading({UserEntity? previousUser}) = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message, {UserEntity? previousUser}) = _Error;
}
