import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreateUserParams extends Equatable {
  final String name;
  final String phone;
  final String password;

  const CreateUserParams({
    required this.name,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, phone, password];
}

class CreateUserUsecase
    implements UsecaseWithParams<AuthEntity, CreateUserParams> {
  final IAuthRepository _authRepository;

  CreateUserUsecase({required this._authRepository});

  @override
  Future<Either<Failure, AuthEntity>> call(CreateUserParams params) {
    return _authRepository.createUser(
      AuthEntity(
        id: null,
        name: params.name,
        phone: params.phone,
        password: params.password,
        role: null,
      ),
    );
  }
}
