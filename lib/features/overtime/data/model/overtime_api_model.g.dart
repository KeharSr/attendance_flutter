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
      overtimeApproveStartTime: json['overtime_approve_start_time'] as String?,
      overtimeApproveEndTime: json['overtime_approve_end_time'] as String?,
      overtimeRequestedHours: (json['overtime_requested_hours'] as num?)
          ?.toDouble(),
      overtimeAcceptedHours: (json['overtime_accepted_hours'] as num?)
          ?.toDouble(),
      adminComment: json['admin_comment'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
      'overtime_approve_start_time': instance.overtimeApproveStartTime,
      'overtime_approve_end_time': instance.overtimeApproveEndTime,
      'overtime_requested_hours': instance.overtimeRequestedHours,
      'overtime_accepted_hours': instance.overtimeAcceptedHours,
      'admin_comment': instance.adminComment,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
