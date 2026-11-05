import 'package:attendance_flutter/features/leave/data/model/leave_model.dart';

abstract interface class ILeaveDataSource {
  Future<LeaveModel> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });

  Future<List<LeaveModel>> getAllLeaves();

  Future<LeaveModel> editLeave({
    required String leaveRequestId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });
  Future<void> deleteLeave({required String leaveRequestId});
}
