// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_attendance_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MissingAttendanceApiModel _$MissingAttendanceApiModelFromJson(
  Map<String, dynamic> json,
) => MissingAttendanceApiModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  missingDate: json['missing_date'] as String,
  requestedCheckIn: json['requested_check_in'] as String,
  requestCheckOut: json['request_check_out'] as String,
  reason: json['reason'] as String,
  status: json['status'] as String,
  adminComment: json['admin_comment'] as String?,
);

Map<String, dynamic> _$MissingAttendanceApiModelToJson(
  MissingAttendanceApiModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'missing_date': instance.missingDate,
  'requested_check_in': instance.requestedCheckIn,
  'request_check_out': instance.requestCheckOut,
  'reason': instance.reason,
  'status': instance.status,
  'admin_comment': instance.adminComment,
};
