import 'package:attendance_flutter/features/leave/data/model/leave_model.dart';

abstract interface class ILeaveDataSource {
  Future<LeaveModel> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });

  Future<List<LeaveModel>> getAllLeaves();
}
