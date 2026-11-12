import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/api/api_exception.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<void> registerDevice(String installationId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.registerDevice,
      data: {'installationId': installationId},
    );
    _validate(response.data, response.statusCode);
  }

  Future<void> unregisterDevice(String installationId) async {
    final response = await apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.unregisterDevice,
      data: {'installationId': installationId},
    );
    _validate(response.data, response.statusCode);
  }

  void _validate(Map<String, dynamic>? body, int? statusCode) {
    if (body?['success'] == true) return;
    throw ApiException(
      message: body?['message'] is String
          ? body!['message'] as String
          : 'Unable to update notification registration.',
      statusCode: statusCode,
    );
  }
}
