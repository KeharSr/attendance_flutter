import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(fromJson: _idFromJson)
  final String? id;
  final String name;
  final String phone;

  @JsonKey(name: 'password', defaultValue: '')
  final String password;
  final String? role;

  AuthApiModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
  });

  static String? _idFromJson(Object? value) => value?.toString();

  // from json
  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  // to json
  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  // from entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.id ?? "",
      name: entity.name,
      phone: entity.phone,
      password: entity.password,
      role: entity.role ?? "employee",
    );
  }

  // to entity
  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      name: name,
      phone: phone,
      password: password,
      role: role,
    );
  }
}
