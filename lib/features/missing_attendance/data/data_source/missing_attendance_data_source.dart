import 'package:attendance_flutter/core/data/model/request_list_model.dart';
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
  Future<RequestListModel<MissingAttendanceApiModel>> getMissingAttendance({
    required int year,
    required int month,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.fetchMissingAttendance(year: year, month: month),
    );

    return RequestListModel<MissingAttendanceApiModel>.fromJson(
      response.data as Map<String, dynamic>,
      MissingAttendanceApiModel.fromJson,
    );
  }

  @override
  Future<MissingAttendanceApiModel> editMissingAttendance({
    required String requestId,
    required String missingDate,
    required String? requestedCheckIn,
    required String? requestedCheckOut,
    required String reason,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.editMissingAttendance(requestId),
      data: {
        'missingDate': missingDate,
        'requestedCheckIn': requestedCheckIn,
        'requestedCheckOut': requestedCheckOut,
        'reason': reason,
      },
    );
    return MissingAttendanceApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteMissingAttendance({required String requestId}) async {
    await _apiClient.delete(ApiEndpoints.deleteMissingAttendance(requestId));
  }
}
