import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_detail_view.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_detail_view.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'card duration handles partial hours, overnight ranges and missing times',
    () {
      expect(requestDisplayDuration('18:00', '21:30'), '3h 30m');
      expect(requestDisplayDuration('19:00:00', '22:00:00'), '3h');
      expect(requestDisplayDuration('23:00', '01:30'), '2h 30m');
      expect(requestDisplayDuration(null, '21:30'), isNull);
      expect(requestDisplayDuration('invalid', '21:30'), isNull);
    },
  );
  test(
    'display times accept both API time formats and preserve unfamiliar values',
    () {
      expect(requestDisplayTime('18:30'), '6:30 PM');
      expect(requestDisplayTime('00:00:00'), '12:00 AM');
      expect(requestDisplayTime('12:15:00'), '12:15 PM');
      expect(requestDisplayTime('unavailable'), 'unavailable');
      expect(requestDisplayTime(''), 'Not requested');
    },
  );

  for (final status in ['approved', 'pending', 'rejected']) {
    testWidgets(
      'all detail pages show rejection feedback only for rejected requests: $status',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pages = [
          LeaveDetailView(
            requestId: '1',
            requests: [
              LeaveEntity(
                id: '1',
                userId: '2',
                startDate: DateTime(2026, 11, 12),
                endDate: DateTime(2026, 11, 14),
                reason: 'Family commitment',
                status: status,
                rejectionReason: 'Please confirm the dates.',
              ),
            ],
          ),
          OvertimeDetailView(
            requestId: 1,
            requests: [
              OvertimeEntity(
                id: 1,
                userId: 2,
                workDate: '2026-11-12',
                overtimeStartTime: '18:00',
                overtimeEndTime: '20:30:00',
                reason: 'Complete inventory review',
                status: status,
                rejectReason: 'Please confirm the dates.',
              ),
            ],
          ),
          MissingAttendanceDetailView(
            requestId: 1,
            requests: [
              MissingAttendanceEntity(
                id: 1,
                userId: 2,
                missingDate: '2026-11-12',
                requestedCheckIn: '09:00:00',
                requestCheckOut: '',
                reason: 'Check-in was not recorded',
                status: status,
                rejectReason: 'Please confirm the dates.',
              ),
            ],
          ),
        ];
        for (final page in pages) {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.8)),
                child: child!,
              ),
              home: page,
            ),
          );
          await tester.pumpAndSettle();
          final feedback = find.text('Rejection reason');
          expect(
            feedback,
            status == 'rejected' ? findsOneWidget : findsNothing,
          );
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -1800),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );
  }
}
