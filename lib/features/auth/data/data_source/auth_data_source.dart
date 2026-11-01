import 'package:attendance_flutter/core/api/api_exception.dart';
import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/api/api_response.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/auth/data/data_source/abstract_auth_data_source.dart';
import 'package:attendance_flutter/features/auth/data/model/auth_api_model.dart';

class AuthDataSource implements IAuthDataSource {
  AuthDataSource({
    required ApiClient apiClient,
    required AppSharedPrefs appSharedPrefs,
  }) : _apiClient = apiClient,
       _appSharedPrefs = appSharedPrefs;

  final ApiClient _apiClient;
  final AppSharedPrefs _appSharedPrefs;

  @override
  Future<ApiResponse<AuthApiModel>> createUser(AuthApiModel model) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.createUser,
      data: model.toJson(),
    );
    final json = response.data;
    if (json == null) {
      throw ApiException(
        message: 'Failure from server',
        statusCode: response.statusCode,
        data: json,
      );
    }

    final data = json['data'];
    return ApiResponse(
      data: AuthApiModel.fromJson(data is Map<String, dynamic> ? data : json),
      message: _message(json),
      statusCode: response.statusCode,
    );
  }

  String _message(Map<String, dynamic> json) {
    final message = json['message'] ?? json['msg'];
    return message is String && message.isNotEmpty
        ? message
        : 'Request completed successfully';
  }

  @override
  Future<AuthApiModel> loginUser({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.loginUser,
      data: {"phone": phone, "password": password},
    );

    final extractedToken = response.data['data']["token"];
    _apiClient.setAuthToken(extractedToken);
    await _appSharedPrefs.saveAuthToken(extractedToken);
    return AuthApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
