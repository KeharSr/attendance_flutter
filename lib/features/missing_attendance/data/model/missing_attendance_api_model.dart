import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'missing_attendance_api_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MissingAttendanceApiModel {
  final String id;
  final String userId;
  final String missingDate;
  final String requestedCheckIn;
  final String requestCheckOut;
  final String reason;
  final String status;
  final String? adminComment;
  final String? overtimeApprovedStartTime;
  final String? overtimeApprovedEndTime;
  final num? overtimeRequestedHours;
  final num? overtimeAcceptedHours;

  const MissingAttendanceApiModel({
    required this.id,
    required this.userId,
    required this.missingDate,
    required this.requestedCheckIn,
    required this.requestCheckOut,
    required this.reason,
    required this.status,
    this.adminComment,
    this.overtimeApprovedStartTime,
    this.overtimeApprovedEndTime,
    this.overtimeRequestedHours,
    this.overtimeAcceptedHours,
  });

  factory MissingAttendanceApiModel.fromJson(Map<String, dynamic> json) {
    return MissingAttendanceApiModel(
      id: _parseString(json['id']),
      userId: _parseString(json['user_id']),
      missingDate: _parseString(json['missing_date']),
      requestedCheckIn: _parseString(json['requested_check_in']),
      requestCheckOut: _parseString(
        json['requested_check_out'] ?? json['request_check_out'],
      ),
      reason: _parseString(json['reason']),
      status: _parseString(json['status'], fallback: 'Pending'),
      adminComment: _parseString(
        json['admin_comment'] ?? json['reject_reason'],
      ),
      overtimeApprovedStartTime: json['overtime_approve_start_time'] as String?,
      overtimeApprovedEndTime: json['overtime_approve_end_time'] as String?,
      overtimeRequestedHours: json['overtime_requested_hours'] as num?,
      overtimeAcceptedHours: json['overtime_accepted_hours'] as num?,
    );
  }

  Map<String, dynamic> toJson() => _$MissingAttendanceApiModelToJson(this);

  // from entity
  factory MissingAttendanceApiModel.fromEntity(MissingAttendanceEntity entity) {
    return MissingAttendanceApiModel(
      id: entity.id,
      userId: entity.userId,
      missingDate: entity.missingDate,
      requestedCheckIn: entity.requestedCheckIn,
      requestCheckOut: entity.requestCheckOut,
      reason: entity.reason,
      status: entity.status,
      adminComment: entity.rejectReason ?? '',
    );
  }

  // to Entity
  MissingAttendanceEntity toEntity() {
    return MissingAttendanceEntity(
      id: id,
      userId: userId,
      missingDate: missingDate,
      requestedCheckIn: requestedCheckIn,
      requestCheckOut: requestCheckOut,
      reason: reason,
      status: status,
      rejectReason: adminComment,
    );
  }

  // to Entity list

  static List<MissingAttendanceEntity> toEntityList(
    List<MissingAttendanceApiModel> models,
  ) => models.map((model) => model.toEntity()).toList();
}

int _parseInt(Object? value, String fieldName) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }

  throw FormatException(
    'Expected $fieldName to be an integer, received $value.',
  );
}

String _parseString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}
