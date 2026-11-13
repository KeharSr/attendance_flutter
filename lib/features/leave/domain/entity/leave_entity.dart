import 'package:equatable/equatable.dart';

class LeaveEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final String? rejectionReason;

  const LeaveEntity({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
    id,
    startDate,
    endDate,
    reason,
    status,
    rejectionReason,
  ];
}
