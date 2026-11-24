import 'package:equatable/equatable.dart';

class RequestSummaryEntity extends Equatable {
  const RequestSummaryEntity({
    required this.totalApplied,
    required this.totalApproved,
    required this.totalPending,
    required this.totalRejected,
  });

  final num totalApplied;
  final num totalApproved;
  final num totalPending;
  final num totalRejected;

  @override
  List<Object?> get props => [
    totalApplied,
    totalApproved,
    totalPending,
    totalRejected,
  ];
}
