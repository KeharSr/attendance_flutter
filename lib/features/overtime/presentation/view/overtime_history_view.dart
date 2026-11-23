import 'package:attendance_flutter/core/common/request_summary.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/presentation/widgets/overtime_history_card_widget.dart';
import 'package:flutter/material.dart';

import 'overtime_detail_view.dart';

class OvertimeHistoryView extends StatelessWidget {
  const OvertimeHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
  });
  final List<OvertimeEntity> requests;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;
  final void Function(OvertimeEntity request)? onEdit;
  final void Function(OvertimeEntity request)? onDelete;
  @override
  Widget build(BuildContext context) {
    final sorted = [...requests]
      ..sort((a, b) => b.workDate.compareTo(a.workDate));
    return RequestHistoryList(
      summary: RequestSummary.hours(
        entries: requests.map(
          (request) => (status: request.status, duration: request.duration),
        ),
        loading: isLoading,
        unavailable: errorMessage != null,
      ),
      count: sorted.length,
      loading: isLoading,
      error: errorMessage,
      onRefresh: onRefresh,
      emptyText: 'No overtime requests found',
      itemBuilder: (context, index) => OvertimeHistoryCardWidget(
        request: sorted[index],
        actionsEnabled: !isLoading,
        onView: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OvertimeDetailView(
              requestId: sorted[index].id,
              requests: sorted,
            ),
          ),
        ),
        onEdit: onEdit == null ? null : () => onEdit!(sorted[index]),
        onDelete: onDelete == null ? null : () => onDelete!(sorted[index]),
      ),
    );
  }
}
