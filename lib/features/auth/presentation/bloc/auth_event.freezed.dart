// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent()';
  }
}

/// @nodoc
class $AuthEventCopyWith<$Res> {
  $AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}

/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckSessionRequested value)? checkSessionRequested,
    TResult Function(_LoginRequested value)? loginRequested,
    TResult Function(_SignUpRequested value)? signUpRequested,
    TResult Function(_ForgotPasswordRequested value)? forgotPasswordRequested,
    TResult Function(_GoogleSignInRequested value)? googleSignInRequested,
    TResult Function(_AppleSignInRequested value)? appleSignInRequested,
    TResult Function(_LogoutRequested value)? logoutRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested(_that);
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested(_that);
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested(_that);
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckSessionRequested value)
        checkSessionRequested,
    required TResult Function(_LoginRequested value) loginRequested,
    required TResult Function(_SignUpRequested value) signUpRequested,
    required TResult Function(_ForgotPasswordRequested value)
        forgotPasswordRequested,
    required TResult Function(_GoogleSignInRequested value)
        googleSignInRequested,
    required TResult Function(_AppleSignInRequested value) appleSignInRequested,
    required TResult Function(_LogoutRequested value) logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested():
        return checkSessionRequested(_that);
      case _LoginRequested():
        return loginRequested(_that);
      case _SignUpRequested():
        return signUpRequested(_that);
      case _ForgotPasswordRequested():
        return forgotPasswordRequested(_that);
      case _GoogleSignInRequested():
        return googleSignInRequested(_that);
      case _AppleSignInRequested():
        return appleSignInRequested(_that);
      case _LogoutRequested():
        return logoutRequested(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckSessionRequested value)? checkSessionRequested,
    TResult? Function(_LoginRequested value)? loginRequested,
    TResult? Function(_SignUpRequested value)? signUpRequested,
    TResult? Function(_ForgotPasswordRequested value)? forgotPasswordRequested,
    TResult? Function(_GoogleSignInRequested value)? googleSignInRequested,
    TResult? Function(_AppleSignInRequested value)? appleSignInRequested,
    TResult? Function(_LogoutRequested value)? logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested(_that);
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested(_that);
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested(_that);
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkSessionRequested,
    TResult Function(String email, String password)? loginRequested,
    TResult Function(String email, String password)? signUpRequested,
    TResult Function(String email)? forgotPasswordRequested,
    TResult Function()? googleSignInRequested,
    TResult Function()? appleSignInRequested,
    TResult Function()? logoutRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested();
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that.email, _that.password);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that.email, _that.password);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that.email);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested();
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested();
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkSessionRequested,
    required TResult Function(String email, String password) loginRequested,
    required TResult Function(String email, String password) signUpRequested,
    required TResult Function(String email) forgotPasswordRequested,
    required TResult Function() googleSignInRequested,
    required TResult Function() appleSignInRequested,
    required TResult Function() logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested():
        return checkSessionRequested();
      case _LoginRequested():
        return loginRequested(_that.email, _that.password);
      case _SignUpRequested():
        return signUpRequested(_that.email, _that.password);
      case _ForgotPasswordRequested():
        return forgotPasswordRequested(_that.email);
      case _GoogleSignInRequested():
        return googleSignInRequested();
      case _AppleSignInRequested():
        return appleSignInRequested();
      case _LogoutRequested():
        return logoutRequested();
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkSessionRequested,
    TResult? Function(String email, String password)? loginRequested,
    TResult? Function(String email, String password)? signUpRequested,
    TResult? Function(String email)? forgotPasswordRequested,
    TResult? Function()? googleSignInRequested,
    TResult? Function()? appleSignInRequested,
    TResult? Function()? logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case _CheckSessionRequested() when checkSessionRequested != null:
        return checkSessionRequested();
      case _LoginRequested() when loginRequested != null:
        return loginRequested(_that.email, _that.password);
      case _SignUpRequested() when signUpRequested != null:
        return signUpRequested(_that.email, _that.password);
      case _ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that.email);
      case _GoogleSignInRequested() when googleSignInRequested != null:
        return googleSignInRequested();
      case _AppleSignInRequested() when appleSignInRequested != null:
        return appleSignInRequested();
      case _LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CheckSessionRequested implements AuthEvent {
  const _CheckSessionRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _CheckSessionRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.checkSessionRequested()';
  }
}

/// @nodoc

class _LoginRequested implements AuthEvent {
  const _LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoginRequestedCopyWith<_LoginRequested> get copyWith =>
      __$LoginRequestedCopyWithImpl<_LoginRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoginRequested &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @override
  String toString() {
    return 'AuthEvent.loginRequested(email: $email, password: $password)';
  }
}

/// @nodoc
abstract mixin class _$LoginRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$LoginRequestedCopyWith(
          _LoginRequested value, $Res Function(_LoginRequested) _then) =
      __$LoginRequestedCopyWithImpl;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$LoginRequestedCopyWithImpl<$Res>
    implements _$LoginRequestedCopyWith<$Res> {
  __$LoginRequestedCopyWithImpl(this._self, this._then);

  final _LoginRequested _self;
  final $Res Function(_LoginRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_LoginRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _SignUpRequested implements AuthEvent {
  const _SignUpRequested({required this.email, required this.password});

  final String email;
  final String password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SignUpRequestedCopyWith<_SignUpRequested> get copyWith =>
      __$SignUpRequestedCopyWithImpl<_SignUpRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SignUpRequested &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @override
  String toString() {
    return 'AuthEvent.signUpRequested(email: $email, password: $password)';
  }
}

/// @nodoc
abstract mixin class _$SignUpRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$SignUpRequestedCopyWith(
          _SignUpRequested value, $Res Function(_SignUpRequested) _then) =
      __$SignUpRequestedCopyWithImpl;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$SignUpRequestedCopyWithImpl<$Res>
    implements _$SignUpRequestedCopyWith<$Res> {
  __$SignUpRequestedCopyWithImpl(this._self, this._then);

  final _SignUpRequested _self;
  final $Res Function(_SignUpRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_SignUpRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _ForgotPasswordRequested implements AuthEvent {
  const _ForgotPasswordRequested({required this.email});

  final String email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ForgotPasswordRequestedCopyWith<_ForgotPasswordRequested> get copyWith =>
      __$ForgotPasswordRequestedCopyWithImpl<_ForgotPasswordRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ForgotPasswordRequested &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'AuthEvent.forgotPasswordRequested(email: $email)';
  }
}

/// @nodoc
abstract mixin class _$ForgotPasswordRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$ForgotPasswordRequestedCopyWith(_ForgotPasswordRequested value,
          $Res Function(_ForgotPasswordRequested) _then) =
      __$ForgotPasswordRequestedCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$ForgotPasswordRequestedCopyWithImpl<$Res>
    implements _$ForgotPasswordRequestedCopyWith<$Res> {
  __$ForgotPasswordRequestedCopyWithImpl(this._self, this._then);

  final _ForgotPasswordRequested _self;
  final $Res Function(_ForgotPasswordRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(_ForgotPasswordRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _GoogleSignInRequested implements AuthEvent {
  const _GoogleSignInRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _GoogleSignInRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.googleSignInRequested()';
  }
}

/// @nodoc

class _AppleSignInRequested implements AuthEvent {
  const _AppleSignInRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _AppleSignInRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.appleSignInRequested()';
  }
}

/// @nodoc

class _LogoutRequested implements AuthEvent {
  const _LogoutRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _LogoutRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.logoutRequested()';
  }
}

// dart format on
