import 'package:attendance_flutter/core/data/model/request_list_model.dart';
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
  Future<RequestListModel<LeaveModel>> getAllLeaves({
    required int year,
    required int month,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.allLeaveRequest(year: year, month: month),
    );

    return RequestListModel<LeaveModel>.fromJson(
      response.data as Map<String, dynamic>,
      LeaveModel.fromJson,
    );
  }

  @override
  Future<LeaveModel> editLeave({
    required String leaveRequestId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.editLeave(leaveRequestId),
      data: {
        'startDate': DateTimeUtils.dateOnly(startDate),
        'endDate': DateTimeUtils.dateOnly(endDate),
        'reason': reason,
      },
    );
    return LeaveModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteLeave({required String leaveRequestId}) async {
    await _apiClient.delete(ApiEndpoints.deleteLeave(leaveRequestId));
  }
}
