// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedDurationMeta =
      const VerificationMeta('estimatedDuration');
  @override
  late final GeneratedColumn<int> estimatedDuration = GeneratedColumn<int>(
      'estimated_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, estimatedDuration, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(Insertable<Routine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('estimated_duration')) {
      context.handle(
          _estimatedDurationMeta,
          estimatedDuration.isAcceptableOrUnknown(
              data['estimated_duration']!, _estimatedDurationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      estimatedDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_duration']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  final int id;
  final String title;
  final int? estimatedDuration;
  final DateTime createdAt;
  const Routine(
      {required this.id,
      required this.title,
      this.estimatedDuration,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || estimatedDuration != null) {
      map['estimated_duration'] = Variable<int>(estimatedDuration);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      title: Value(title),
      estimatedDuration: estimatedDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDuration),
      createdAt: Value(createdAt),
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      estimatedDuration: serializer.fromJson<int?>(json['estimatedDuration']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'estimatedDuration': serializer.toJson<int?>(estimatedDuration),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Routine copyWith(
          {int? id,
          String? title,
          Value<int?> estimatedDuration = const Value.absent(),
          DateTime? createdAt}) =>
      Routine(
        id: id ?? this.id,
        title: title ?? this.title,
        estimatedDuration: estimatedDuration.present
            ? estimatedDuration.value
            : this.estimatedDuration,
        createdAt: createdAt ?? this.createdAt,
      );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      estimatedDuration: data.estimatedDuration.present
          ? data.estimatedDuration.value
          : this.estimatedDuration,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('estimatedDuration: $estimatedDuration, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, estimatedDuration, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.title == this.title &&
          other.estimatedDuration == this.estimatedDuration &&
          other.createdAt == this.createdAt);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<int> id;
  final Value<String> title;
  final Value<int?> estimatedDuration;
  final Value<DateTime> createdAt;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.estimatedDuration = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.estimatedDuration = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Routine> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? estimatedDuration,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RoutinesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<int?>? estimatedDuration,
      Value<DateTime>? createdAt}) {
    return RoutinesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (estimatedDuration.present) {
      map['estimated_duration'] = Variable<int>(estimatedDuration.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('estimatedDuration: $estimatedDuration, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
      'routine_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, date, name, routineId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(Insertable<Workout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}routine_id']),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final DateTime date;
  final String name;
  final int? routineId;
  const Workout(
      {required this.id,
      required this.date,
      required this.name,
      this.routineId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = Variable<int>(routineId);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      date: Value(date),
      name: Value(name),
      routineId: routineId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineId),
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      name: serializer.fromJson<String>(json['name']),
      routineId: serializer.fromJson<int?>(json['routineId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'name': serializer.toJson<String>(name),
      'routineId': serializer.toJson<int?>(routineId),
    };
  }

  Workout copyWith(
          {int? id,
          DateTime? date,
          String? name,
          Value<int?> routineId = const Value.absent()}) =>
      Workout(
        id: id ?? this.id,
        date: date ?? this.date,
        name: name ?? this.name,
        routineId: routineId.present ? routineId.value : this.routineId,
      );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('routineId: $routineId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, name, routineId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.date == this.date &&
          other.name == this.name &&
          other.routineId == this.routineId);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> name;
  final Value<int?> routineId;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.routineId = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String name,
    this.routineId = const Value.absent(),
  })  : date = Value(date),
        name = Value(name);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? name,
    Expression<int>? routineId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (routineId != null) 'routine_id': routineId,
    });
  }

  WorkoutsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? name,
      Value<int?>? routineId}) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      routineId: routineId ?? this.routineId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('routineId: $routineId')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetMuscleMeta =
      const VerificationMeta('targetMuscle');
  @override
  late final GeneratedColumn<String> targetMuscle = GeneratedColumn<String>(
      'target_muscle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceVideoUrlMeta =
      const VerificationMeta('referenceVideoUrl');
  @override
  late final GeneratedColumn<String> referenceVideoUrl =
      GeneratedColumn<String>('reference_video_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
      'equipment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _focusAreaMeta =
      const VerificationMeta('focusArea');
  @override
  late final GeneratedColumn<String> focusArea = GeneratedColumn<String>(
      'focus_area', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preparationMeta =
      const VerificationMeta('preparation');
  @override
  late final GeneratedColumn<String> preparation = GeneratedColumn<String>(
      'preparation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _executionMeta =
      const VerificationMeta('execution');
  @override
  late final GeneratedColumn<String> execution = GeneratedColumn<String>(
      'execution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tipsMeta = const VerificationMeta('tips');
  @override
  late final GeneratedColumn<String> tips = GeneratedColumn<String>(
      'tips', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isVectorMeta =
      const VerificationMeta('isVector');
  @override
  late final GeneratedColumn<bool> isVector = GeneratedColumn<bool>(
      'is_vector', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_vector" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        targetMuscle,
        referenceVideoUrl,
        imageUrl,
        equipment,
        focusArea,
        preparation,
        execution,
        tips,
        isVector,
        isFavorite
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<Exercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_muscle')) {
      context.handle(
          _targetMuscleMeta,
          targetMuscle.isAcceptableOrUnknown(
              data['target_muscle']!, _targetMuscleMeta));
    } else if (isInserting) {
      context.missing(_targetMuscleMeta);
    }
    if (data.containsKey('reference_video_url')) {
      context.handle(
          _referenceVideoUrlMeta,
          referenceVideoUrl.isAcceptableOrUnknown(
              data['reference_video_url']!, _referenceVideoUrlMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('equipment')) {
      context.handle(_equipmentMeta,
          equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta));
    }
    if (data.containsKey('focus_area')) {
      context.handle(_focusAreaMeta,
          focusArea.isAcceptableOrUnknown(data['focus_area']!, _focusAreaMeta));
    }
    if (data.containsKey('preparation')) {
      context.handle(
          _preparationMeta,
          preparation.isAcceptableOrUnknown(
              data['preparation']!, _preparationMeta));
    }
    if (data.containsKey('execution')) {
      context.handle(_executionMeta,
          execution.isAcceptableOrUnknown(data['execution']!, _executionMeta));
    }
    if (data.containsKey('tips')) {
      context.handle(
          _tipsMeta, tips.isAcceptableOrUnknown(data['tips']!, _tipsMeta));
    }
    if (data.containsKey('is_vector')) {
      context.handle(_isVectorMeta,
          isVector.isAcceptableOrUnknown(data['is_vector']!, _isVectorMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetMuscle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_muscle'])!,
      referenceVideoUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_video_url']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      equipment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment']),
      focusArea: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}focus_area']),
      preparation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preparation']),
      execution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}execution']),
      tips: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tips']),
      isVector: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_vector'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final String targetMuscle;
  final String? referenceVideoUrl;
  final String? imageUrl;
  final String? equipment;
  final String? focusArea;
  final String? preparation;
  final String? execution;
  final String? tips;
  final bool isVector;
  final bool isFavorite;
  const Exercise(
      {required this.id,
      required this.name,
      required this.targetMuscle,
      this.referenceVideoUrl,
      this.imageUrl,
      this.equipment,
      this.focusArea,
      this.preparation,
      this.execution,
      this.tips,
      required this.isVector,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_muscle'] = Variable<String>(targetMuscle);
    if (!nullToAbsent || referenceVideoUrl != null) {
      map['reference_video_url'] = Variable<String>(referenceVideoUrl);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || focusArea != null) {
      map['focus_area'] = Variable<String>(focusArea);
    }
    if (!nullToAbsent || preparation != null) {
      map['preparation'] = Variable<String>(preparation);
    }
    if (!nullToAbsent || execution != null) {
      map['execution'] = Variable<String>(execution);
    }
    if (!nullToAbsent || tips != null) {
      map['tips'] = Variable<String>(tips);
    }
    map['is_vector'] = Variable<bool>(isVector);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      targetMuscle: Value(targetMuscle),
      referenceVideoUrl: referenceVideoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceVideoUrl),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      focusArea: focusArea == null && nullToAbsent
          ? const Value.absent()
          : Value(focusArea),
      preparation: preparation == null && nullToAbsent
          ? const Value.absent()
          : Value(preparation),
      execution: execution == null && nullToAbsent
          ? const Value.absent()
          : Value(execution),
      tips: tips == null && nullToAbsent ? const Value.absent() : Value(tips),
      isVector: Value(isVector),
      isFavorite: Value(isFavorite),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetMuscle: serializer.fromJson<String>(json['targetMuscle']),
      referenceVideoUrl:
          serializer.fromJson<String?>(json['referenceVideoUrl']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      focusArea: serializer.fromJson<String?>(json['focusArea']),
      preparation: serializer.fromJson<String?>(json['preparation']),
      execution: serializer.fromJson<String?>(json['execution']),
      tips: serializer.fromJson<String?>(json['tips']),
      isVector: serializer.fromJson<bool>(json['isVector']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetMuscle': serializer.toJson<String>(targetMuscle),
      'referenceVideoUrl': serializer.toJson<String?>(referenceVideoUrl),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'equipment': serializer.toJson<String?>(equipment),
      'focusArea': serializer.toJson<String?>(focusArea),
      'preparation': serializer.toJson<String?>(preparation),
      'execution': serializer.toJson<String?>(execution),
      'tips': serializer.toJson<String?>(tips),
      'isVector': serializer.toJson<bool>(isVector),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  Exercise copyWith(
          {int? id,
          String? name,
          String? targetMuscle,
          Value<String?> referenceVideoUrl = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> equipment = const Value.absent(),
          Value<String?> focusArea = const Value.absent(),
          Value<String?> preparation = const Value.absent(),
          Value<String?> execution = const Value.absent(),
          Value<String?> tips = const Value.absent(),
          bool? isVector,
          bool? isFavorite}) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        targetMuscle: targetMuscle ?? this.targetMuscle,
        referenceVideoUrl: referenceVideoUrl.present
            ? referenceVideoUrl.value
            : this.referenceVideoUrl,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        equipment: equipment.present ? equipment.value : this.equipment,
        focusArea: focusArea.present ? focusArea.value : this.focusArea,
        preparation: preparation.present ? preparation.value : this.preparation,
        execution: execution.present ? execution.value : this.execution,
        tips: tips.present ? tips.value : this.tips,
        isVector: isVector ?? this.isVector,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetMuscle: data.targetMuscle.present
          ? data.targetMuscle.value
          : this.targetMuscle,
      referenceVideoUrl: data.referenceVideoUrl.present
          ? data.referenceVideoUrl.value
          : this.referenceVideoUrl,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      focusArea: data.focusArea.present ? data.focusArea.value : this.focusArea,
      preparation:
          data.preparation.present ? data.preparation.value : this.preparation,
      execution: data.execution.present ? data.execution.value : this.execution,
      tips: data.tips.present ? data.tips.value : this.tips,
      isVector: data.isVector.present ? data.isVector.value : this.isVector,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetMuscle: $targetMuscle, ')
          ..write('referenceVideoUrl: $referenceVideoUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('equipment: $equipment, ')
          ..write('focusArea: $focusArea, ')
          ..write('preparation: $preparation, ')
          ..write('execution: $execution, ')
          ..write('tips: $tips, ')
          ..write('isVector: $isVector, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      targetMuscle,
      referenceVideoUrl,
      imageUrl,
      equipment,
      focusArea,
      preparation,
      execution,
      tips,
      isVector,
      isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetMuscle == this.targetMuscle &&
          other.referenceVideoUrl == this.referenceVideoUrl &&
          other.imageUrl == this.imageUrl &&
          other.equipment == this.equipment &&
          other.focusArea == this.focusArea &&
          other.preparation == this.preparation &&
          other.execution == this.execution &&
          other.tips == this.tips &&
          other.isVector == this.isVector &&
          other.isFavorite == this.isFavorite);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> targetMuscle;
  final Value<String?> referenceVideoUrl;
  final Value<String?> imageUrl;
  final Value<String?> equipment;
  final Value<String?> focusArea;
  final Value<String?> preparation;
  final Value<String?> execution;
  final Value<String?> tips;
  final Value<bool> isVector;
  final Value<bool> isFavorite;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetMuscle = const Value.absent(),
    this.referenceVideoUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.equipment = const Value.absent(),
    this.focusArea = const Value.absent(),
    this.preparation = const Value.absent(),
    this.execution = const Value.absent(),
    this.tips = const Value.absent(),
    this.isVector = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String targetMuscle,
    this.referenceVideoUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.equipment = const Value.absent(),
    this.focusArea = const Value.absent(),
    this.preparation = const Value.absent(),
    this.execution = const Value.absent(),
    this.tips = const Value.absent(),
    this.isVector = const Value.absent(),
    this.isFavorite = const Value.absent(),
  })  : name = Value(name),
        targetMuscle = Value(targetMuscle);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? targetMuscle,
    Expression<String>? referenceVideoUrl,
    Expression<String>? imageUrl,
    Expression<String>? equipment,
    Expression<String>? focusArea,
    Expression<String>? preparation,
    Expression<String>? execution,
    Expression<String>? tips,
    Expression<bool>? isVector,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetMuscle != null) 'target_muscle': targetMuscle,
      if (referenceVideoUrl != null) 'reference_video_url': referenceVideoUrl,
      if (imageUrl != null) 'image_url': imageUrl,
      if (equipment != null) 'equipment': equipment,
      if (focusArea != null) 'focus_area': focusArea,
      if (preparation != null) 'preparation': preparation,
      if (execution != null) 'execution': execution,
      if (tips != null) 'tips': tips,
      if (isVector != null) 'is_vector': isVector,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  ExercisesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? targetMuscle,
      Value<String?>? referenceVideoUrl,
      Value<String?>? imageUrl,
      Value<String?>? equipment,
      Value<String?>? focusArea,
      Value<String?>? preparation,
      Value<String?>? execution,
      Value<String?>? tips,
      Value<bool>? isVector,
      Value<bool>? isFavorite}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      referenceVideoUrl: referenceVideoUrl ?? this.referenceVideoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      equipment: equipment ?? this.equipment,
      focusArea: focusArea ?? this.focusArea,
      preparation: preparation ?? this.preparation,
      execution: execution ?? this.execution,
      tips: tips ?? this.tips,
      isVector: isVector ?? this.isVector,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetMuscle.present) {
      map['target_muscle'] = Variable<String>(targetMuscle.value);
    }
    if (referenceVideoUrl.present) {
      map['reference_video_url'] = Variable<String>(referenceVideoUrl.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (focusArea.present) {
      map['focus_area'] = Variable<String>(focusArea.value);
    }
    if (preparation.present) {
      map['preparation'] = Variable<String>(preparation.value);
    }
    if (execution.present) {
      map['execution'] = Variable<String>(execution.value);
    }
    if (tips.present) {
      map['tips'] = Variable<String>(tips.value);
    }
    if (isVector.present) {
      map['is_vector'] = Variable<bool>(isVector.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetMuscle: $targetMuscle, ')
          ..write('referenceVideoUrl: $referenceVideoUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('equipment: $equipment, ')
          ..write('focusArea: $focusArea, ')
          ..write('preparation: $preparation, ')
          ..write('execution: $execution, ')
          ..write('tips: $tips, ')
          ..write('isVector: $isVector, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'));
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
      'rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, workoutId, exerciseId, reps, weight, rpe, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exercise_id'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rpe']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int workoutId;
  final int exerciseId;
  final int reps;
  final double weight;
  final int? rpe;
  final DateTime timestamp;
  const WorkoutSet(
      {required this.id,
      required this.workoutId,
      required this.exerciseId,
      required this.reps,
      required this.weight,
      this.rpe,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['reps'] = Variable<int>(reps);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      reps: Value(reps),
      weight: Value(weight),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      timestamp: Value(timestamp),
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      reps: serializer.fromJson<int>(json['reps']),
      weight: serializer.fromJson<double>(json['weight']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int>(workoutId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'reps': serializer.toJson<int>(reps),
      'weight': serializer.toJson<double>(weight),
      'rpe': serializer.toJson<int?>(rpe),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WorkoutSet copyWith(
          {int? id,
          int? workoutId,
          int? exerciseId,
          int? reps,
          double? weight,
          Value<int?> rpe = const Value.absent(),
          DateTime? timestamp}) =>
      WorkoutSet(
        id: id ?? this.id,
        workoutId: workoutId ?? this.workoutId,
        exerciseId: exerciseId ?? this.exerciseId,
        reps: reps ?? this.reps,
        weight: weight ?? this.weight,
        rpe: rpe.present ? rpe.value : this.rpe,
        timestamp: timestamp ?? this.timestamp,
      );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      reps: data.reps.present ? data.reps.value : this.reps,
      weight: data.weight.present ? data.weight.value : this.weight,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('rpe: $rpe, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutId, exerciseId, reps, weight, rpe, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.reps == this.reps &&
          other.weight == this.weight &&
          other.rpe == this.rpe &&
          other.timestamp == this.timestamp);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<int> exerciseId;
  final Value<int> reps;
  final Value<double> weight;
  final Value<int?> rpe;
  final Value<DateTime> timestamp;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.rpe = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required int exerciseId,
    required int reps,
    required double weight,
    this.rpe = const Value.absent(),
    required DateTime timestamp,
  })  : workoutId = Value(workoutId),
        exerciseId = Value(exerciseId),
        reps = Value(reps),
        weight = Value(weight),
        timestamp = Value(timestamp);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<int>? exerciseId,
    Expression<int>? reps,
    Expression<double>? weight,
    Expression<int>? rpe,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      if (rpe != null) 'rpe': rpe,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  WorkoutSetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? workoutId,
      Value<int>? exerciseId,
      Value<int>? reps,
      Value<double>? weight,
      Value<int?>? rpe,
      Value<DateTime>? timestamp}) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rpe: rpe ?? this.rpe,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('rpe: $rpe, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $RoutineExercisesTable extends RoutineExercises
    with TableInfo<$RoutineExercisesTable, RoutineExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES exercises (id)'));
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
      'sets', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _setsDataMeta =
      const VerificationMeta('setsData');
  @override
  late final GeneratedColumn<String> setsData = GeneratedColumn<String>(
      'sets_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, routineId, exerciseId, sets, reps, weight, orderIndex, setsData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<RoutineExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
          _setsMeta, sets.isAcceptableOrUnknown(data['sets']!, _setsMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('sets_data')) {
      context.handle(_setsDataMeta,
          setsData.isAcceptableOrUnknown(data['sets_data']!, _setsDataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}routine_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exercise_id'])!,
      sets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sets'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      setsData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sets_data']),
    );
  }

  @override
  $RoutineExercisesTable createAlias(String alias) {
    return $RoutineExercisesTable(attachedDatabase, alias);
  }
}

class RoutineExercise extends DataClass implements Insertable<RoutineExercise> {
  final int id;
  final int routineId;
  final int exerciseId;
  final int sets;
  final int reps;
  final double weight;
  final int orderIndex;
  final String? setsData;
  const RoutineExercise(
      {required this.id,
      required this.routineId,
      required this.exerciseId,
      required this.sets,
      required this.reps,
      required this.weight,
      required this.orderIndex,
      this.setsData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['sets'] = Variable<int>(sets);
    map['reps'] = Variable<int>(reps);
    map['weight'] = Variable<double>(weight);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || setsData != null) {
      map['sets_data'] = Variable<String>(setsData);
    }
    return map;
  }

  RoutineExercisesCompanion toCompanion(bool nullToAbsent) {
    return RoutineExercisesCompanion(
      id: Value(id),
      routineId: Value(routineId),
      exerciseId: Value(exerciseId),
      sets: Value(sets),
      reps: Value(reps),
      weight: Value(weight),
      orderIndex: Value(orderIndex),
      setsData: setsData == null && nullToAbsent
          ? const Value.absent()
          : Value(setsData),
    );
  }

  factory RoutineExercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineExercise(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      sets: serializer.fromJson<int>(json['sets']),
      reps: serializer.fromJson<int>(json['reps']),
      weight: serializer.fromJson<double>(json['weight']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      setsData: serializer.fromJson<String?>(json['setsData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'sets': serializer.toJson<int>(sets),
      'reps': serializer.toJson<int>(reps),
      'weight': serializer.toJson<double>(weight),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'setsData': serializer.toJson<String?>(setsData),
    };
  }

  RoutineExercise copyWith(
          {int? id,
          int? routineId,
          int? exerciseId,
          int? sets,
          int? reps,
          double? weight,
          int? orderIndex,
          Value<String?> setsData = const Value.absent()}) =>
      RoutineExercise(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        exerciseId: exerciseId ?? this.exerciseId,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        weight: weight ?? this.weight,
        orderIndex: orderIndex ?? this.orderIndex,
        setsData: setsData.present ? setsData.value : this.setsData,
      );
  RoutineExercise copyWithCompanion(RoutineExercisesCompanion data) {
    return RoutineExercise(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      sets: data.sets.present ? data.sets.value : this.sets,
      reps: data.reps.present ? data.reps.value : this.reps,
      weight: data.weight.present ? data.weight.value : this.weight,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      setsData: data.setsData.present ? data.setsData.value : this.setsData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercise(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('setsData: $setsData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, routineId, exerciseId, sets, reps, weight, orderIndex, setsData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineExercise &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.exerciseId == this.exerciseId &&
          other.sets == this.sets &&
          other.reps == this.reps &&
          other.weight == this.weight &&
          other.orderIndex == this.orderIndex &&
          other.setsData == this.setsData);
}

class RoutineExercisesCompanion extends UpdateCompanion<RoutineExercise> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<int> exerciseId;
  final Value<int> sets;
  final Value<int> reps;
  final Value<double> weight;
  final Value<int> orderIndex;
  final Value<String?> setsData;
  const RoutineExercisesCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.setsData = const Value.absent(),
  });
  RoutineExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required int exerciseId,
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.setsData = const Value.absent(),
  })  : routineId = Value(routineId),
        exerciseId = Value(exerciseId);
  static Insertable<RoutineExercise> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<int>? exerciseId,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<double>? weight,
    Expression<int>? orderIndex,
    Expression<String>? setsData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      if (orderIndex != null) 'order_index': orderIndex,
      if (setsData != null) 'sets_data': setsData,
    });
  }

  RoutineExercisesCompanion copyWith(
      {Value<int>? id,
      Value<int>? routineId,
      Value<int>? exerciseId,
      Value<int>? sets,
      Value<int>? reps,
      Value<double>? weight,
      Value<int>? orderIndex,
      Value<String?>? setsData}) {
    return RoutineExercisesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      orderIndex: orderIndex ?? this.orderIndex,
      setsData: setsData ?? this.setsData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (setsData.present) {
      map['sets_data'] = Variable<String>(setsData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercisesCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('setsData: $setsData')
          ..write(')'))
        .toString();
  }
}

class $WeightLogsTable extends WeightLogs
    with TableInfo<$WeightLogsTable, WeightLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, weight, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_logs';
  @override
  VerificationContext validateIntegrity(Insertable<WeightLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $WeightLogsTable createAlias(String alias) {
    return $WeightLogsTable(attachedDatabase, alias);
  }
}

class WeightLog extends DataClass implements Insertable<WeightLog> {
  final int id;
  final double weight;
  final DateTime date;
  const WeightLog({required this.id, required this.weight, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weight'] = Variable<double>(weight);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  WeightLogsCompanion toCompanion(bool nullToAbsent) {
    return WeightLogsCompanion(
      id: Value(id),
      weight: Value(weight),
      date: Value(date),
    );
  }

  factory WeightLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightLog(
      id: serializer.fromJson<int>(json['id']),
      weight: serializer.fromJson<double>(json['weight']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weight': serializer.toJson<double>(weight),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  WeightLog copyWith({int? id, double? weight, DateTime? date}) => WeightLog(
        id: id ?? this.id,
        weight: weight ?? this.weight,
        date: date ?? this.date,
      );
  WeightLog copyWithCompanion(WeightLogsCompanion data) {
    return WeightLog(
      id: data.id.present ? data.id.value : this.id,
      weight: data.weight.present ? data.weight.value : this.weight,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightLog(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weight, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightLog &&
          other.id == this.id &&
          other.weight == this.weight &&
          other.date == this.date);
}

class WeightLogsCompanion extends UpdateCompanion<WeightLog> {
  final Value<int> id;
  final Value<double> weight;
  final Value<DateTime> date;
  const WeightLogsCompanion({
    this.id = const Value.absent(),
    this.weight = const Value.absent(),
    this.date = const Value.absent(),
  });
  WeightLogsCompanion.insert({
    this.id = const Value.absent(),
    required double weight,
    required DateTime date,
  })  : weight = Value(weight),
        date = Value(date);
  static Insertable<WeightLog> custom({
    Expression<int>? id,
    Expression<double>? weight,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weight != null) 'weight': weight,
      if (date != null) 'date': date,
    });
  }

  WeightLogsCompanion copyWith(
      {Value<int>? id, Value<double>? weight, Value<DateTime>? date}) {
    return WeightLogsCompanion(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $RoutineExercisesTable routineExercises =
      $RoutineExercisesTable(this);
  late final $WeightLogsTable weightLogs = $WeightLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        routines,
        workouts,
        exercises,
        workoutSets,
        routineExercises,
        weightLogs,
        appSettings
      ];
}

typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  Value<int> id,
  required String title,
  Value<int?> estimatedDuration,
  Value<DateTime> createdAt,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<int?> estimatedDuration,
  Value<DateTime> createdAt,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutsTable, List<Workout>> _workoutsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workouts,
          aliasName:
              $_aliasNameGenerator(db.routines.id, db.workouts.routineId));

  $$WorkoutsTableProcessedTableManager get workoutsRefs {
    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
      _routineExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.routineExercises,
              aliasName: $_aliasNameGenerator(
                  db.routines.id, db.routineExercises.routineId));

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager =
        $$RoutineExercisesTableTableManager($_db, $_db.routineExercises)
            .filter((f) => f.routineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_routineExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutsRefs(
      Expression<bool> Function($$WorkoutsTableFilterComposer f) f) {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.routineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> routineExercisesRefs(
      Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routineExercises,
        getReferencedColumn: (t) => t.routineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutineExercisesTableFilterComposer(
              $db: $db,
              $table: $db.routineExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> workoutsRefs<T extends Object>(
      Expression<T> Function($$WorkoutsTableAnnotationComposer a) f) {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.routineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> routineExercisesRefs<T extends Object>(
      Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routineExercises,
        getReferencedColumn: (t) => t.routineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutineExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.routineExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoutinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoutinesTable,
    Routine,
    $$RoutinesTableFilterComposer,
    $$RoutinesTableOrderingComposer,
    $$RoutinesTableAnnotationComposer,
    $$RoutinesTableCreateCompanionBuilder,
    $$RoutinesTableUpdateCompanionBuilder,
    (Routine, $$RoutinesTableReferences),
    Routine,
    PrefetchHooks Function({bool workoutsRefs, bool routineExercisesRefs})> {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int?> estimatedDuration = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RoutinesCompanion(
            id: id,
            title: title,
            estimatedDuration: estimatedDuration,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<int?> estimatedDuration = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RoutinesCompanion.insert(
            id: id,
            title: title,
            estimatedDuration: estimatedDuration,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoutinesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workoutsRefs = false, routineExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutsRefs) db.workouts,
                if (routineExercisesRefs) db.routineExercises
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutsRefs)
                    await $_getPrefetchedData<Routine, $RoutinesTable, Workout>(
                        currentTable: table,
                        referencedTable:
                            $$RoutinesTableReferences._workoutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoutinesTableReferences(db, table, p0)
                                .workoutsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.routineId == item.id),
                        typedResults: items),
                  if (routineExercisesRefs)
                    await $_getPrefetchedData<Routine, $RoutinesTable,
                            RoutineExercise>(
                        currentTable: table,
                        referencedTable: $$RoutinesTableReferences
                            ._routineExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoutinesTableReferences(db, table, p0)
                                .routineExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.routineId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoutinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoutinesTable,
    Routine,
    $$RoutinesTableFilterComposer,
    $$RoutinesTableOrderingComposer,
    $$RoutinesTableAnnotationComposer,
    $$RoutinesTableCreateCompanionBuilder,
    $$RoutinesTableUpdateCompanionBuilder,
    (Routine, $$RoutinesTableReferences),
    Routine,
    PrefetchHooks Function({bool workoutsRefs, bool routineExercisesRefs})>;
typedef $$WorkoutsTableCreateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  required DateTime date,
  required String name,
  Value<int?> routineId,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> name,
  Value<int?> routineId,
});

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) => db.routines
      .createAlias($_aliasNameGenerator(db.workouts.routineId, db.routines.id));

  $$RoutinesTableProcessedTableManager? get routineId {
    final $_column = $_itemColumn<int>('routine_id');
    if ($_column == null) return null;
    final manager = $$RoutinesTableTableManager($_db, $_db.routines)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
      _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.workoutSets,
          aliasName:
              $_aliasNameGenerator(db.workouts.id, db.workoutSets.workoutId));

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableFilterComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> workoutSetsRefs(
      Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableOrderingComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(
      Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function({bool routineId, bool workoutSetsRefs})> {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> routineId = const Value.absent(),
          }) =>
              WorkoutsCompanion(
            id: id,
            date: date,
            name: name,
            routineId: routineId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String name,
            Value<int?> routineId = const Value.absent(),
          }) =>
              WorkoutsCompanion.insert(
            id: id,
            date: date,
            name: name,
            routineId: routineId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WorkoutsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {routineId = false, workoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSetsRefs) db.workoutSets],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (routineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.routineId,
                    referencedTable:
                        $$WorkoutsTableReferences._routineIdTable(db),
                    referencedColumn:
                        $$WorkoutsTableReferences._routineIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            WorkoutSet>(
                        currentTable: table,
                        referencedTable:
                            $$WorkoutsTableReferences._workoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .workoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function({bool routineId, bool workoutSetsRefs})>;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  required String name,
  required String targetMuscle,
  Value<String?> referenceVideoUrl,
  Value<String?> imageUrl,
  Value<String?> equipment,
  Value<String?> focusArea,
  Value<String?> preparation,
  Value<String?> execution,
  Value<String?> tips,
  Value<bool> isVector,
  Value<bool> isFavorite,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> targetMuscle,
  Value<String?> referenceVideoUrl,
  Value<String?> imageUrl,
  Value<String?> equipment,
  Value<String?> focusArea,
  Value<String?> preparation,
  Value<String?> execution,
  Value<String?> tips,
  Value<bool> isVector,
  Value<bool> isFavorite,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
      _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.workoutSets,
          aliasName:
              $_aliasNameGenerator(db.exercises.id, db.workoutSets.exerciseId));

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
      _routineExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.routineExercises,
              aliasName: $_aliasNameGenerator(
                  db.exercises.id, db.routineExercises.exerciseId));

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager =
        $$RoutineExercisesTableTableManager($_db, $_db.routineExercises)
            .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_routineExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetMuscle => $composableBuilder(
      column: $table.targetMuscle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceVideoUrl => $composableBuilder(
      column: $table.referenceVideoUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get focusArea => $composableBuilder(
      column: $table.focusArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preparation => $composableBuilder(
      column: $table.preparation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get execution => $composableBuilder(
      column: $table.execution, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tips => $composableBuilder(
      column: $table.tips, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVector => $composableBuilder(
      column: $table.isVector, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutSetsRefs(
      Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> routineExercisesRefs(
      Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routineExercises,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutineExercisesTableFilterComposer(
              $db: $db,
              $table: $db.routineExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetMuscle => $composableBuilder(
      column: $table.targetMuscle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceVideoUrl => $composableBuilder(
      column: $table.referenceVideoUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get focusArea => $composableBuilder(
      column: $table.focusArea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preparation => $composableBuilder(
      column: $table.preparation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get execution => $composableBuilder(
      column: $table.execution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tips => $composableBuilder(
      column: $table.tips, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVector => $composableBuilder(
      column: $table.isVector, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get targetMuscle => $composableBuilder(
      column: $table.targetMuscle, builder: (column) => column);

  GeneratedColumn<String> get referenceVideoUrl => $composableBuilder(
      column: $table.referenceVideoUrl, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get focusArea =>
      $composableBuilder(column: $table.focusArea, builder: (column) => column);

  GeneratedColumn<String> get preparation => $composableBuilder(
      column: $table.preparation, builder: (column) => column);

  GeneratedColumn<String> get execution =>
      $composableBuilder(column: $table.execution, builder: (column) => column);

  GeneratedColumn<String> get tips =>
      $composableBuilder(column: $table.tips, builder: (column) => column);

  GeneratedColumn<bool> get isVector =>
      $composableBuilder(column: $table.isVector, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  Expression<T> workoutSetsRefs<T extends Object>(
      Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> routineExercisesRefs<T extends Object>(
      Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routineExercises,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutineExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.routineExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (Exercise, $$ExercisesTableReferences),
    Exercise,
    PrefetchHooks Function({bool workoutSetsRefs, bool routineExercisesRefs})> {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> targetMuscle = const Value.absent(),
            Value<String?> referenceVideoUrl = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> equipment = const Value.absent(),
            Value<String?> focusArea = const Value.absent(),
            Value<String?> preparation = const Value.absent(),
            Value<String?> execution = const Value.absent(),
            Value<String?> tips = const Value.absent(),
            Value<bool> isVector = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            name: name,
            targetMuscle: targetMuscle,
            referenceVideoUrl: referenceVideoUrl,
            imageUrl: imageUrl,
            equipment: equipment,
            focusArea: focusArea,
            preparation: preparation,
            execution: execution,
            tips: tips,
            isVector: isVector,
            isFavorite: isFavorite,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String targetMuscle,
            Value<String?> referenceVideoUrl = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> equipment = const Value.absent(),
            Value<String?> focusArea = const Value.absent(),
            Value<String?> preparation = const Value.absent(),
            Value<String?> execution = const Value.absent(),
            Value<String?> tips = const Value.absent(),
            Value<bool> isVector = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              ExercisesCompanion.insert(
            id: id,
            name: name,
            targetMuscle: targetMuscle,
            referenceVideoUrl: referenceVideoUrl,
            imageUrl: imageUrl,
            equipment: equipment,
            focusArea: focusArea,
            preparation: preparation,
            execution: execution,
            tips: tips,
            isVector: isVector,
            isFavorite: isFavorite,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workoutSetsRefs = false, routineExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutSetsRefs) db.workoutSets,
                if (routineExercisesRefs) db.routineExercises
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<Exercise, $ExercisesTable,
                            WorkoutSet>(
                        currentTable: table,
                        referencedTable: $$ExercisesTableReferences
                            ._workoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExercisesTableReferences(db, table, p0)
                                .workoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items),
                  if (routineExercisesRefs)
                    await $_getPrefetchedData<Exercise, $ExercisesTable,
                            RoutineExercise>(
                        currentTable: table,
                        referencedTable: $$ExercisesTableReferences
                            ._routineExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExercisesTableReferences(db, table, p0)
                                .routineExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (Exercise, $$ExercisesTableReferences),
    Exercise,
    PrefetchHooks Function({bool workoutSetsRefs, bool routineExercisesRefs})>;
typedef $$WorkoutSetsTableCreateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  required int workoutId,
  required int exerciseId,
  required int reps,
  required double weight,
  Value<int?> rpe,
  required DateTime timestamp,
});
typedef $$WorkoutSetsTableUpdateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  Value<int> workoutId,
  Value<int> exerciseId,
  Value<int> reps,
  Value<double> weight,
  Value<int?> rpe,
  Value<DateTime> timestamp,
});

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
          $_aliasNameGenerator(db.workoutSets.workoutId, db.workouts.id));

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
          $_aliasNameGenerator(db.workoutSets.exerciseId, db.exercises.id));

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableFilterComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool workoutId, bool exerciseId})> {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<int> exerciseId = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<int?> rpe = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              WorkoutSetsCompanion(
            id: id,
            workoutId: workoutId,
            exerciseId: exerciseId,
            reps: reps,
            weight: weight,
            rpe: rpe,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workoutId,
            required int exerciseId,
            required int reps,
            required double weight,
            Value<int?> rpe = const Value.absent(),
            required DateTime timestamp,
          }) =>
              WorkoutSetsCompanion.insert(
            id: id,
            workoutId: workoutId,
            exerciseId: exerciseId,
            reps: reps,
            weight: weight,
            rpe: rpe,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$WorkoutSetsTableReferences._workoutIdTable(db),
                    referencedColumn:
                        $$WorkoutSetsTableReferences._workoutIdTable(db).id,
                  ) as T;
                }
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable:
                        $$WorkoutSetsTableReferences._exerciseIdTable(db),
                    referencedColumn:
                        $$WorkoutSetsTableReferences._exerciseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkoutSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool workoutId, bool exerciseId})>;
typedef $$RoutineExercisesTableCreateCompanionBuilder
    = RoutineExercisesCompanion Function({
  Value<int> id,
  required int routineId,
  required int exerciseId,
  Value<int> sets,
  Value<int> reps,
  Value<double> weight,
  Value<int> orderIndex,
  Value<String?> setsData,
});
typedef $$RoutineExercisesTableUpdateCompanionBuilder
    = RoutineExercisesCompanion Function({
  Value<int> id,
  Value<int> routineId,
  Value<int> exerciseId,
  Value<int> sets,
  Value<int> reps,
  Value<double> weight,
  Value<int> orderIndex,
  Value<String?> setsData,
});

final class $$RoutineExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $RoutineExercisesTable, RoutineExercise> {
  $$RoutineExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias(
          $_aliasNameGenerator(db.routineExercises.routineId, db.routines.id));

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<int>('routine_id')!;

    final manager = $$RoutinesTableTableManager($_db, $_db.routines)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias($_aliasNameGenerator(
          db.routineExercises.exerciseId, db.exercises.id));

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager($_db, $_db.exercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoutineExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sets => $composableBuilder(
      column: $table.sets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setsData => $composableBuilder(
      column: $table.setsData, builder: (column) => ColumnFilters(column));

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableFilterComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableFilterComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoutineExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sets => $composableBuilder(
      column: $table.sets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setsData => $composableBuilder(
      column: $table.setsData, builder: (column) => ColumnOrderings(column));

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableOrderingComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoutineExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get setsData =>
      $composableBuilder(column: $table.setsData, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoutineExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoutineExercisesTable,
    RoutineExercise,
    $$RoutineExercisesTableFilterComposer,
    $$RoutineExercisesTableOrderingComposer,
    $$RoutineExercisesTableAnnotationComposer,
    $$RoutineExercisesTableCreateCompanionBuilder,
    $$RoutineExercisesTableUpdateCompanionBuilder,
    (RoutineExercise, $$RoutineExercisesTableReferences),
    RoutineExercise,
    PrefetchHooks Function({bool routineId, bool exerciseId})> {
  $$RoutineExercisesTableTableManager(
      _$AppDatabase db, $RoutineExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> routineId = const Value.absent(),
            Value<int> exerciseId = const Value.absent(),
            Value<int> sets = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String?> setsData = const Value.absent(),
          }) =>
              RoutineExercisesCompanion(
            id: id,
            routineId: routineId,
            exerciseId: exerciseId,
            sets: sets,
            reps: reps,
            weight: weight,
            orderIndex: orderIndex,
            setsData: setsData,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int routineId,
            required int exerciseId,
            Value<int> sets = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String?> setsData = const Value.absent(),
          }) =>
              RoutineExercisesCompanion.insert(
            id: id,
            routineId: routineId,
            exerciseId: exerciseId,
            sets: sets,
            reps: reps,
            weight: weight,
            orderIndex: orderIndex,
            setsData: setsData,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoutineExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({routineId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (routineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.routineId,
                    referencedTable:
                        $$RoutineExercisesTableReferences._routineIdTable(db),
                    referencedColumn: $$RoutineExercisesTableReferences
                        ._routineIdTable(db)
                        .id,
                  ) as T;
                }
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable:
                        $$RoutineExercisesTableReferences._exerciseIdTable(db),
                    referencedColumn: $$RoutineExercisesTableReferences
                        ._exerciseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoutineExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoutineExercisesTable,
    RoutineExercise,
    $$RoutineExercisesTableFilterComposer,
    $$RoutineExercisesTableOrderingComposer,
    $$RoutineExercisesTableAnnotationComposer,
    $$RoutineExercisesTableCreateCompanionBuilder,
    $$RoutineExercisesTableUpdateCompanionBuilder,
    (RoutineExercise, $$RoutineExercisesTableReferences),
    RoutineExercise,
    PrefetchHooks Function({bool routineId, bool exerciseId})>;
typedef $$WeightLogsTableCreateCompanionBuilder = WeightLogsCompanion Function({
  Value<int> id,
  required double weight,
  required DateTime date,
});
typedef $$WeightLogsTableUpdateCompanionBuilder = WeightLogsCompanion Function({
  Value<int> id,
  Value<double> weight,
  Value<DateTime> date,
});

class $$WeightLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));
}

class $$WeightLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));
}

class $$WeightLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$WeightLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeightLogsTable,
    WeightLog,
    $$WeightLogsTableFilterComposer,
    $$WeightLogsTableOrderingComposer,
    $$WeightLogsTableAnnotationComposer,
    $$WeightLogsTableCreateCompanionBuilder,
    $$WeightLogsTableUpdateCompanionBuilder,
    (WeightLog, BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLog>),
    WeightLog,
    PrefetchHooks Function()> {
  $$WeightLogsTableTableManager(_$AppDatabase db, $WeightLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              WeightLogsCompanion(
            id: id,
            weight: weight,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double weight,
            required DateTime date,
          }) =>
              WeightLogsCompanion.insert(
            id: id,
            weight: weight,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeightLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeightLogsTable,
    WeightLog,
    $$WeightLogsTableFilterComposer,
    $$WeightLogsTableOrderingComposer,
    $$WeightLogsTableAnnotationComposer,
    $$WeightLogsTableCreateCompanionBuilder,
    $$WeightLogsTableUpdateCompanionBuilder,
    (WeightLog, BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLog>),
    WeightLog,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(_db, _db.routineExercises);
  $$WeightLogsTableTableManager get weightLogs =>
      $$WeightLogsTableTableManager(_db, _db.weightLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
