import 'package:equatable/equatable.dart';

class MissingAttendanceEntity extends Equatable {
  final int id;
  final int userId;
  final String missingDate;
  final String requestedCheckIn;
  final String requestCheckOut;
  final String reason;
  final String status;

  const MissingAttendanceEntity({
    required this.id,
    required this.userId,
    required this.missingDate,
    required this.requestedCheckIn,
    required this.requestCheckOut,
    required this.reason,
    required this.status,
  });
  @override
  List<Object?> get props => [
    id,
    userId,
    missingDate,
    requestedCheckIn,
    requestCheckOut,
    reason,
    status,
  ];
}
