import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String name;
  final String phone;
  final String password;
  final String? role;

  const AuthEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, phone, role];
}
