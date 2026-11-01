import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String phone;
  final String password;

  const LoginParams({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}

class LoginUserUsecase implements UsecaseWithParams<AuthEntity, LoginParams> {
  final IAuthRepository _iAuthRepository;

  LoginUserUsecase({required this._iAuthRepository});
  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    return _iAuthRepository.loginUser(
      phone: params.phone,
      password: params.password,
    );
  }
}
