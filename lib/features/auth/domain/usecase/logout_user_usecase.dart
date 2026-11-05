import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUserUsecase implements UsecaseWithOutParams<String> {
  const LogoutUserUsecase({required this._authRepository});
  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, String>> call() => _authRepository.logoutUser();
}
