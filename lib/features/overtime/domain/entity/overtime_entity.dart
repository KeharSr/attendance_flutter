import 'package:equatable/equatable.dart';

class OvertimeEntity extends Equatable {
  final int id;
  final int userId;
  final String workDate;
  final double overtimeHours;
  final String reason;
  final String status;

  const OvertimeEntity({
    required this.id,
    required this.userId,
    required this.workDate,
    required this.overtimeHours,
    required this.reason,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    workDate,
    overtimeHours,
    reason,
    status,
  ];
}
