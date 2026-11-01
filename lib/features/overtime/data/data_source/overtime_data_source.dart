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
    required double overtimeHours,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.overtimeRequest,
      data: {
        'workDate': workDate,
        'overtimeHours': overtimeHours,
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
}
