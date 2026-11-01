import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/data/data_source/auth_data_source.dart';
import 'package:attendance_flutter/features/auth/data/model/auth_api_model.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthDataSource _authDataSource;

  const AuthRepositoryImpl({required this._authDataSource});

  @override
  Future<Either<Failure, AuthEntity>> createUser(AuthEntity user) async {
    try {
      final model = AuthApiModel.fromEntity(user);

      final result = await _authDataSource.createUser(model);

      return Right(result.data.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      final result = await _authDataSource.loginUser(
        phone: phone,
        password: password,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left((ServerFailure(message: e.toString())));
    }
  }
}
