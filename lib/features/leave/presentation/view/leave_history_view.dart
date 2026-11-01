import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/presentation/widgets/leave_history_card_widget.dart';
import 'package:flutter/material.dart';

class LeaveHistoryView extends StatelessWidget {
  const LeaveHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
  });

  final List<LeaveEntity> requests;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_rounded,
                color: Color(0xFF98A2B3),
                size: 46,
              ),
              SizedBox(height: 12),
              Text(
                'No leave history yet',
                style: TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Your submitted leave requests will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) =>
          LeaveHistoryCardWidget(request: requests[index]),
    );
  }
}
