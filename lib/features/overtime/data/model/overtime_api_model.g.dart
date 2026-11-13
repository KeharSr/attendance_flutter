// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvertimeApiModel _$OvertimeApiModelFromJson(Map<String, dynamic> json) =>
    OvertimeApiModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      overtimeStartTime: json['overtime_start_time'] as String?,
      overtimeEndTime: json['overtime_end_time'] as String?,
      workDate: json['work_date'] as String? ?? '',
      reason: json['reason'] as String,
      status: json['status'] as String,
      rejectReason: json['reject_reason'] as String?,
    );

Map<String, dynamic> _$OvertimeApiModelToJson(OvertimeApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'overtime_start_time': instance.overtimeStartTime,
      'overtime_end_time': instance.overtimeEndTime,
      'work_date': instance.workDate,
      'reason': instance.reason,
      'status': instance.status,
      'reject_reason': instance.rejectReason,
    };
