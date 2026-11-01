// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvertimeApiModel _$OvertimeApiModelFromJson(Map<String, dynamic> json) =>
    OvertimeApiModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      workDate: json['work_date'] as String,
      overtimeHours: (json['overtime_hours'] as num).toDouble(),
      reason: json['reason'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$OvertimeApiModelToJson(OvertimeApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'work_date': instance.workDate,
      'overtime_hours': instance.overtimeHours,
      'reason': instance.reason,
      'status': instance.status,
    };
