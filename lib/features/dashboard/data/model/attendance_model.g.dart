// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      checkIn: json['check_in'] as String,
      checkOut: json['check_out'] as String?,
      workDate: json['work_date'] as String,
      checkInLatitude: (json['check_in_latitude'] as num).toDouble(),
      checkInLongitude: (json['check_in_longitude'] as num).toDouble(),
      checkInAccuracyM: json['check_in_accuracy_m'] as num,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'check_in': instance.checkIn,
      'check_out': instance.checkOut,
      'work_date': instance.workDate,
      'check_in_latitude': instance.checkInLatitude,
      'check_in_longitude': instance.checkInLongitude,
      'check_in_accuracy_m': instance.checkInAccuracyM,
    };
