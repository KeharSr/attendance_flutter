import 'package:attendance_flutter/core/data/model/request_list_model.dart';
import 'package:attendance_flutter/features/leave/data/model/leave_model.dart';

abstract interface class ILeaveDataSource {
  Future<LeaveModel> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });

  Future<RequestListModel<LeaveModel>> getAllLeaves({
    required int year,
    required int month,
  });

  Future<LeaveModel> editLeave({
    required String leaveRequestId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });
  Future<void> deleteLeave({required String leaveRequestId});
}
