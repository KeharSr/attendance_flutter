import 'package:attendance_flutter/core/api/api_response.dart';
import 'package:attendance_flutter/features/auth/data/model/auth_api_model.dart';

abstract class IAuthDataSource {
  Future<ApiResponse<AuthApiModel>> createUser(AuthApiModel model);
  Future<AuthApiModel> loginUser({required String phone, required String password});
}
