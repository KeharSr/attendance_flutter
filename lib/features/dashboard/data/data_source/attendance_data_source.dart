import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/features/dashboard/data/data_source/abstract_attendance_data_source.dart';
import 'package:attendance_flutter/features/dashboard/data/model/attendance_model.dart';

class AttendanceDataSource implements IAttendanceDataSource {
  final ApiClient _apiClient;
  AttendanceDataSource({required this._apiClient});

  @override
  Future<AttendanceModel> clockIn({
    required double latitude,
    required double longitude,
    required num accuracy,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.clockIn,
      data: {
        "location": {
          "latitude": latitude,
          "longitude": longitude,
          "accuracy": accuracy,
        },
      },
    );
    final newResponse = response.data;
    return AttendanceModel.fromJson(
      newResponse["data"] as Map<String, dynamic>,
    );
  }

  @override
  Future<AttendanceModel> clockOut({
    required double latitude,
    required double longitude,
    required num accuracy,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.clockOut,
      data: {
        "location": {
          "latitude": latitude,
          "longitude": longitude,
          "accuracy": accuracy,
        },
      },
    );
    final newResponse = response.data;
    return AttendanceModel.fromJson(
      newResponse["data"] as Map<String, dynamic>,
    );
  }
}
