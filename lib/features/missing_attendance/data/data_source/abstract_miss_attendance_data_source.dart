import 'package:attendance_flutter/core/data/model/request_list_model.dart';
import 'package:attendance_flutter/features/missing_attendance/data/model/missing_attendance_api_model.dart';

abstract interface class IMissingAttendanceDataSource {
  Future<MissingAttendanceApiModel> createMissingAttendance({
    required String missingDate,
    required String requestedCheckIn,
    required String requestedCheckOut,
    required String reason,
  });

  Future<RequestListModel<MissingAttendanceApiModel>> getMissingAttendance({
    required int year,
    required int month,
  });
  Future<MissingAttendanceApiModel> editMissingAttendance({
    required String requestId,
    required String missingDate,
    required String? requestedCheckIn,
    required String? requestedCheckOut,
    required String reason,
  });

  Future<void> deleteMissingAttendance({required String requestId});
}
