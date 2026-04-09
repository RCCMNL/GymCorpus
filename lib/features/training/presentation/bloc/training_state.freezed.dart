// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainingState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TrainingState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TrainingState()';
  }
}

/// @nodoc
class $TrainingStateCopyWith<$Res> {
  $TrainingStateCopyWith(TrainingState _, $Res Function(TrainingState) __);
}

/// Adds pattern-matching-related methods to [TrainingState].
extension TrainingStatePatterns on TrainingState {
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
    TResult Function(TrainingLoading value)? loading,
    TResult Function(TrainingLoaded value)? loaded,
    TResult Function(TrainingError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TrainingLoading() when loading != null:
        return loading(_that);
      case TrainingLoaded() when loaded != null:
        return loaded(_that);
      case TrainingError() when error != null:
        return error(_that);
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
    required TResult Function(TrainingLoading value) loading,
    required TResult Function(TrainingLoaded value) loaded,
    required TResult Function(TrainingError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case TrainingLoading():
        return loading(_that);
      case TrainingLoaded():
        return loaded(_that);
      case TrainingError():
        return error(_that);
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
    TResult? Function(TrainingLoading value)? loading,
    TResult? Function(TrainingLoaded value)? loaded,
    TResult? Function(TrainingError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case TrainingLoading() when loading != null:
        return loading(_that);
      case TrainingLoaded() when loaded != null:
        return loaded(_that);
      case TrainingError() when error != null:
        return error(_that);
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
    TResult Function()? loading,
    TResult Function(
            List<ExerciseEntity> exercises,
            List<RoutineEntity> routines,
            List<WorkoutSetEntity> weightLogs,
            List<BodyWeightLogEntity> bodyWeightLogs,
            List<CardioSessionEntity> cardioSessions,
            Map<String, String> settings,
            double? lastEstimated1RM)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TrainingLoading() when loading != null:
        return loading();
      case TrainingLoaded() when loaded != null:
        return loaded(
            _that.exercises,
            _that.routines,
            _that.weightLogs,
            _that.bodyWeightLogs,
            _that.cardioSessions,
            _that.settings,
            _that.lastEstimated1RM);
      case TrainingError() when error != null:
        return error(_that.message);
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
    required TResult Function() loading,
    required TResult Function(
            List<ExerciseEntity> exercises,
            List<RoutineEntity> routines,
            List<WorkoutSetEntity> weightLogs,
            List<BodyWeightLogEntity> bodyWeightLogs,
            List<CardioSessionEntity> cardioSessions,
            Map<String, String> settings,
            double? lastEstimated1RM)
        loaded,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case TrainingLoading():
        return loading();
      case TrainingLoaded():
        return loaded(
            _that.exercises,
            _that.routines,
            _that.weightLogs,
            _that.bodyWeightLogs,
            _that.cardioSessions,
            _that.settings,
            _that.lastEstimated1RM);
      case TrainingError():
        return error(_that.message);
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
    TResult? Function()? loading,
    TResult? Function(
            List<ExerciseEntity> exercises,
            List<RoutineEntity> routines,
            List<WorkoutSetEntity> weightLogs,
            List<BodyWeightLogEntity> bodyWeightLogs,
            List<CardioSessionEntity> cardioSessions,
            Map<String, String> settings,
            double? lastEstimated1RM)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case TrainingLoading() when loading != null:
        return loading();
      case TrainingLoaded() when loaded != null:
        return loaded(
            _that.exercises,
            _that.routines,
            _that.weightLogs,
            _that.bodyWeightLogs,
            _that.cardioSessions,
            _that.settings,
            _that.lastEstimated1RM);
      case TrainingError() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class TrainingLoading implements TrainingState {
  const TrainingLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TrainingLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TrainingState.loading()';
  }
}

/// @nodoc

class TrainingLoaded implements TrainingState {
  const TrainingLoaded(
      {required final List<ExerciseEntity> exercises,
      final List<RoutineEntity> routines = const [],
      final List<WorkoutSetEntity> weightLogs = const [],
      final List<BodyWeightLogEntity> bodyWeightLogs = const [],
      final List<CardioSessionEntity> cardioSessions = const [],
      final Map<String, String> settings = const {},
      this.lastEstimated1RM})
      : _exercises = exercises,
        _routines = routines,
        _weightLogs = weightLogs,
        _bodyWeightLogs = bodyWeightLogs,
        _cardioSessions = cardioSessions,
        _settings = settings;

  final List<ExerciseEntity> _exercises;
  List<ExerciseEntity> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  final List<RoutineEntity> _routines;
  @JsonKey()
  List<RoutineEntity> get routines {
    if (_routines is EqualUnmodifiableListView) return _routines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routines);
  }

  final List<WorkoutSetEntity> _weightLogs;
  @JsonKey()
  List<WorkoutSetEntity> get weightLogs {
    if (_weightLogs is EqualUnmodifiableListView) return _weightLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weightLogs);
  }

  final List<BodyWeightLogEntity> _bodyWeightLogs;
  @JsonKey()
  List<BodyWeightLogEntity> get bodyWeightLogs {
    if (_bodyWeightLogs is EqualUnmodifiableListView) return _bodyWeightLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bodyWeightLogs);
  }

  final List<CardioSessionEntity> _cardioSessions;
  @JsonKey()
  List<CardioSessionEntity> get cardioSessions {
    if (_cardioSessions is EqualUnmodifiableListView) return _cardioSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cardioSessions);
  }

  final Map<String, String> _settings;
  @JsonKey()
  Map<String, String> get settings {
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_settings);
  }

  final double? lastEstimated1RM;

  /// Create a copy of TrainingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrainingLoadedCopyWith<TrainingLoaded> get copyWith =>
      _$TrainingLoadedCopyWithImpl<TrainingLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrainingLoaded &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            const DeepCollectionEquality().equals(other._routines, _routines) &&
            const DeepCollectionEquality()
                .equals(other._weightLogs, _weightLogs) &&
            const DeepCollectionEquality()
                .equals(other._bodyWeightLogs, _bodyWeightLogs) &&
            const DeepCollectionEquality()
                .equals(other._cardioSessions, _cardioSessions) &&
            const DeepCollectionEquality().equals(other._settings, _settings) &&
            (identical(other.lastEstimated1RM, lastEstimated1RM) ||
                other.lastEstimated1RM == lastEstimated1RM));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_exercises),
      const DeepCollectionEquality().hash(_routines),
      const DeepCollectionEquality().hash(_weightLogs),
      const DeepCollectionEquality().hash(_bodyWeightLogs),
      const DeepCollectionEquality().hash(_cardioSessions),
      const DeepCollectionEquality().hash(_settings),
      lastEstimated1RM);

  @override
  String toString() {
    return 'TrainingState.loaded(exercises: $exercises, routines: $routines, weightLogs: $weightLogs, bodyWeightLogs: $bodyWeightLogs, cardioSessions: $cardioSessions, settings: $settings, lastEstimated1RM: $lastEstimated1RM)';
  }
}

/// @nodoc
abstract mixin class $TrainingLoadedCopyWith<$Res>
    implements $TrainingStateCopyWith<$Res> {
  factory $TrainingLoadedCopyWith(
          TrainingLoaded value, $Res Function(TrainingLoaded) _then) =
      _$TrainingLoadedCopyWithImpl;
  @useResult
  $Res call(
      {List<ExerciseEntity> exercises,
      List<RoutineEntity> routines,
      List<WorkoutSetEntity> weightLogs,
      List<BodyWeightLogEntity> bodyWeightLogs,
      List<CardioSessionEntity> cardioSessions,
      Map<String, String> settings,
      double? lastEstimated1RM});
}

/// @nodoc
class _$TrainingLoadedCopyWithImpl<$Res>
    implements $TrainingLoadedCopyWith<$Res> {
  _$TrainingLoadedCopyWithImpl(this._self, this._then);

  final TrainingLoaded _self;
  final $Res Function(TrainingLoaded) _then;

  /// Create a copy of TrainingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? exercises = null,
    Object? routines = null,
    Object? weightLogs = null,
    Object? bodyWeightLogs = null,
    Object? cardioSessions = null,
    Object? settings = null,
    Object? lastEstimated1RM = freezed,
  }) {
    return _then(TrainingLoaded(
      exercises: null == exercises
          ? _self._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseEntity>,
      routines: null == routines
          ? _self._routines
          : routines // ignore: cast_nullable_to_non_nullable
              as List<RoutineEntity>,
      weightLogs: null == weightLogs
          ? _self._weightLogs
          : weightLogs // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSetEntity>,
      bodyWeightLogs: null == bodyWeightLogs
          ? _self._bodyWeightLogs
          : bodyWeightLogs // ignore: cast_nullable_to_non_nullable
              as List<BodyWeightLogEntity>,
      cardioSessions: null == cardioSessions
          ? _self._cardioSessions
          : cardioSessions // ignore: cast_nullable_to_non_nullable
              as List<CardioSessionEntity>,
      settings: null == settings
          ? _self._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      lastEstimated1RM: freezed == lastEstimated1RM
          ? _self.lastEstimated1RM
          : lastEstimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class TrainingError implements TrainingState {
  const TrainingError(this.message);

  final String message;

  /// Create a copy of TrainingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrainingErrorCopyWith<TrainingError> get copyWith =>
      _$TrainingErrorCopyWithImpl<TrainingError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrainingError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'TrainingState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $TrainingErrorCopyWith<$Res>
    implements $TrainingStateCopyWith<$Res> {
  factory $TrainingErrorCopyWith(
          TrainingError value, $Res Function(TrainingError) _then) =
      _$TrainingErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$TrainingErrorCopyWithImpl<$Res>
    implements $TrainingErrorCopyWith<$Res> {
  _$TrainingErrorCopyWithImpl(this._self, this._then);

  final TrainingError _self;
  final $Res Function(TrainingError) _then;

  /// Create a copy of TrainingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(TrainingError(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
