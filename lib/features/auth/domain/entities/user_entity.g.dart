// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      username: json['username'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      trainingObjective: json['trainingObjective'] as String?,
      lastLoginDate: json['lastLoginDate'] == null
          ? null
          : DateTime.parse(json['lastLoginDate'] as String),
      lastLoginDevice: json['lastLoginDevice'] as String?,
      authProviders: (json['authProviders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'username': instance.username,
      'weight': instance.weight,
      'height': instance.height,
      'birthDate': instance.birthDate?.toIso8601String(),
      'trainingObjective': instance.trainingObjective,
      'lastLoginDate': instance.lastLoginDate?.toIso8601String(),
      'lastLoginDevice': instance.lastLoginDevice,
      'authProviders': instance.authProviders,
    };
