import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gym_corpus/features/auth/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

/// Stato di autenticazione.
///
/// Il `toString` generato e' disabilitato come per `AuthEvent`: gli stati
/// trasportano una `UserEntity` completa, con email, data di nascita, peso,
/// altezza e cronologia dei dispositivi usati per l'accesso. Oggi nessun
/// BlocObserver registra gli stati, ma bastava aggiungerne uno, o un
/// crash reporter che serializzi lo stato, per far finire quei dati nei log.
@Freezed(toStringOverride: false)
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading({UserEntity? previousUser}) = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message, {UserEntity? previousUser}) =
      _Error;
}
