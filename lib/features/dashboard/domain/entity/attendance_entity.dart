import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final int id;
  final int userId;
  final String checkIn;
  final String? checkout;
  final String workDate;
  final double checkInLatitude;
  final double checkInLongitude;
  final num checkInAccuracyM;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final double? checkoutOutAccuracyM;

  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.checkIn,
    this.checkout,
    required this.checkInLatitude,
    required this.checkInLongitude,
    required this.checkInAccuracyM,
    required this.workDate,
    this.checkoutLatitude,
    this.checkoutLongitude,
    this.checkoutOutAccuracyM,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    checkIn,
    checkout,
    workDate,
    checkInLatitude,
    checkInLongitude,
    checkInAccuracyM,
    workDate,
    checkoutLatitude,
  ];
}
