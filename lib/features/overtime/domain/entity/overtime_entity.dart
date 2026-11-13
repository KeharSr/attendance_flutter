import 'package:equatable/equatable.dart';

class OvertimeEntity extends Equatable {
  final String id;
  final String userId;
  final String? overtimeStartTime;
  final String? overtimeEndTime;
  final String workDate;
  final String reason;
  final String status;
  final String? rejectReason;

  const OvertimeEntity({
    required this.id,
    required this.userId,
    this.overtimeStartTime,
    this.overtimeEndTime,
    this.workDate = '',
    required this.reason,
    required this.status,
    this.rejectReason,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    overtimeStartTime,
    overtimeEndTime,
    workDate,
    reason,
    status,
    rejectReason,
  ];
}
