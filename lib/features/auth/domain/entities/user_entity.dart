import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  final String id;
  final String name;
  final String email;

  @override
  List<Object> get props => [id, name, email];
}
