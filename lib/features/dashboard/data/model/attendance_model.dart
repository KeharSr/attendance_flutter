import 'package:attendance_flutter/features/auth/data/model/auth_api_model.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'attendance_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AttendanceModel {
  final int id;
  final int userId;
  final String checkIn;
  final String? checkOut;
  final String workDate;
  final double checkInLatitude;
  final double checkInLongitude;
  final num checkInAccuracyM;
  final double? checkOutLatitude;
  final double? checkoutLongitude;
  final double? checkoutAccuracyM;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.checkIn,
    this.checkOut,
    required this.workDate,
    required this.checkInLatitude,
    required this.checkInLongitude,
    required this.checkInAccuracyM,
    this.checkOutLatitude,
    this.checkoutLongitude,
    this.checkoutAccuracyM,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  AttendanceEntity toEntity() {
    return AttendanceEntity(
      id: id,
      userId: userId,
      checkIn: checkIn,
      checkInLatitude: checkInLatitude,
      checkInLongitude: checkInLongitude,
      checkInAccuracyM: checkInAccuracyM,
      workDate: workDate,
      checkoutLatitude: checkOutLatitude,
      checkoutLongitude: checkoutLongitude,
      checkout: checkOut,
      checkoutOutAccuracyM: checkoutAccuracyM,
    );
  }
}
