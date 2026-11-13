import 'package:equatable/equatable.dart';

class MissingAttendanceEntity extends Equatable {
  final String id;
  final String userId;
  final String missingDate;
  final String requestedCheckIn;
  final String requestCheckOut;
  final String reason;
  final String status;
  final String? rejectReason;

  const MissingAttendanceEntity({
    required this.id,
    required this.userId,
    required this.missingDate,
    required this.requestedCheckIn,
    required this.requestCheckOut,
    required this.reason,
    required this.status,
    this.rejectReason,
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
    rejectReason,
  ];
}
