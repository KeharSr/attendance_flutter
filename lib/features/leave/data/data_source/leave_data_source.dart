import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/leave/data/data_source/abstract_leave_data_source.dart';
import 'package:attendance_flutter/features/leave/data/model/leave_model.dart';

class LeaveDataSource implements ILeaveDataSource {
  final ApiClient _apiClient;

  LeaveDataSource({required this._apiClient});

  @override
  Future<LeaveModel> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final request = await _apiClient.post(
      ApiEndpoints.leaveRequest,
      data: {
        'startDate': DateTimeUtils.dateOnly(startDate),
        'endDate': DateTimeUtils.dateOnly(endDate),
        'reason': reason,
      },
    );

    final json = request.data['data'];

    final result = LeaveModel.fromJson(json as Map<String, dynamic>);
    return result;
  }

  @override
  Future<List<LeaveModel>> getAllLeaves() async {
    final response = await _apiClient.get(ApiEndpoints.allLeaveRequest);

    final jsonList = response.data['data'] as List;

    final result = jsonList
        .map((json) => LeaveModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return result;
  }
}
