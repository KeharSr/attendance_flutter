import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/features/overtime/data/data_source/abstract_ovetime_data_source.dart';
import 'package:attendance_flutter/features/overtime/data/model/overtime_api_model.dart';

class OvertimeDataSource implements IAbstractOvertimeDataSource {
  final ApiClient _apiClient;
  OvertimeDataSource({required this._apiClient});

  @override
  Future<OvertimeApiModel> addOvertime({
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.overtimeRequest,
      data: {
        'workDate': workDate,
        'overtimeStartTime': overtimeStartTime,
        'overtimeEndTime': overtimeEndTime,
        'reason': reason,
      },
    );

    final json = response.data['data'];

    return OvertimeApiModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<OvertimeApiModel>> getAllOvertime() async {
    final response = await _apiClient.get(ApiEndpoints.fetchAllOvertime);

    final jsonList = response.data['data'] as List;

    final result = jsonList
        .map((json) => OvertimeApiModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return result;
  }

  @override
  Future<OvertimeApiModel> editOvertime({
    required String overtimeId,
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.editOvertime(overtimeId),
      data: {
        'workDate': workDate,
        'overtimeStartTime': overtimeStartTime,
        'overtimeEndTime': overtimeEndTime,
        'reason': reason,
      },
    );
    final json = response.data['data'] as Map<String, dynamic>;
    final convertedJson = OvertimeApiModel.fromJson(json);
    return convertedJson;
  }

  @override
  Future<void> deleteOvertimeRequest({required String overtimeId}) async {
    await _apiClient.delete(ApiEndpoints.deleteOvertime(overtimeId));
  }
}
