import 'package:attendance_flutter/features/dashboard/data/model/attendance_model.dart';

abstract interface class IAttendanceDataSource {
  Future<AttendanceModel> clockIn({
    required double latitude,
    required double longitude,
    required num accuracy,
  });
}
