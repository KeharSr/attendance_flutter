import 'package:attendance_flutter/features/overtime/data/model/overtime_api_model.dart';

abstract interface class IAbstractOvertimeDataSource {
  Future<OvertimeApiModel> addOvertime({
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  });

  Future<List<OvertimeApiModel>> getAllOvertime();

  Future<OvertimeApiModel> editOvertime({
    required String overtimeId,
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  });
  Future<void> deleteOvertimeRequest({required String overtimeId});
}
