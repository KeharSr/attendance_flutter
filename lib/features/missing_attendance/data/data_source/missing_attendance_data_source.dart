import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';

import 'package:attendance_flutter/features/missing_attendance/data/data_source/abstract_miss_attendance_data_source.dart';
import 'package:attendance_flutter/features/missing_attendance/data/model/missing_attendance_api_model.dart';

class MissingAttendanceDataSource implements IMissingAttendanceDataSource {
  final ApiClient _apiClient;

  MissingAttendanceDataSource({required this._apiClient});

  @override
  Future<MissingAttendanceApiModel> createMissingAttendance({
    required String missingDate,
    required String requestedCheckIn,
    required String requestedCheckOut,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.createMissingAttendance,
      data: {
        "missingDate": missingDate,
        "requestedCheckIn": requestedCheckIn,
        "requestedCheckOut": requestedCheckOut,
        "reason": reason,
      },
    );

    final jsonData = response.data['data'] as Map<String, dynamic>;
    return MissingAttendanceApiModel.fromJson(jsonData);
  }

  @override
  Future<List<MissingAttendanceApiModel>> getMissingAttendance() async {
    final response = await _apiClient.get(ApiEndpoints.fetchMissingAttendance);

    final jsonList = response.data["data"] as List;

    final jsonData = jsonList
        .map(
          (json) =>
              MissingAttendanceApiModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    return jsonData;
  }
}
