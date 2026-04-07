import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.username,
    this.weight,
    this.height,
    this.birthDate,
    this.trainingObjective,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Atleta',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        username: json['username'] as String?,
        weight: (json['weight'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate'] as String) : null,
        trainingObjective: json['trainingObjective'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'username': username,
        'weight': weight,
        'height': height,
        'birthDate': birthDate?.toIso8601String(),
        'trainingObjective': trainingObjective,
      };

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? username;
  final double? weight;
  final double? height;
  final DateTime? birthDate;
  final String? trainingObjective;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? username,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      username: username ?? this.username,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      trainingObjective: trainingObjective ?? this.trainingObjective,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        username,
        weight,
        height,
        birthDate,
        trainingObjective,
      ];
}
