import 'package:attendance_flutter/core/domain/entity/request_summary_entity.dart';

class RequestSummaryModel {
  const RequestSummaryModel({
    required this.totalApplied,
    required this.totalApproved,
    required this.totalPending,
    required this.totalRejected,
  });

  factory RequestSummaryModel.fromJson(Map<String, dynamic> json) {
    return RequestSummaryModel(
      totalApplied: json['total_applied'] as num,
      totalApproved: json['total_approved'] as num,
      totalPending: json['total_pending'] as num,
      totalRejected: json['total_rejected'] as num,
    );
  }

  final num totalApplied;
  final num totalApproved;
  final num totalPending;
  final num totalRejected;

  RequestSummaryEntity toEntity() => RequestSummaryEntity(
    totalApplied: totalApplied,
    totalApproved: totalApproved,
    totalPending: totalPending,
    totalRejected: totalRejected,
  );
}
