import 'package:attendance_flutter/features/overtime/data/model/overtime_api_model.dart';

abstract interface class IAbstractOvertimeDataSource {
  Future<OvertimeApiModel> addOvertime({
    required String workDate,
    required double overtimeHours,
    required String reason,
  });
  Future<List<OvertimeApiModel>> getAllOvertime();
}
