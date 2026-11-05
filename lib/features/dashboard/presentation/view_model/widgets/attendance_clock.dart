import 'dart:math' as math;

import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:flutter/material.dart';

const _green = Color(0xFF008A20);
const _red = Color(0xFFEF4444);

class AttendanceClock extends StatelessWidget {
  const AttendanceClock({
    required this.now,
    required this.working,
    required this.completed,
    required this.loading,
    required this.elapsed,
    required this.onToggle,
    this.loadingMessage = 'Verifying location...',
    this.checkIn,
    this.fullRingDuration = const Duration(hours: 8),
    super.key,
  }) : assert(fullRingDuration > Duration.zero);

  final DateTime now;
  final bool working;
  final bool completed;
  final bool loading;
  final Duration elapsed;
  final VoidCallback? onToggle;
  final String loadingMessage;
  final DateTime? checkIn;
  final Duration fullRingDuration;

  @override
  Widget build(BuildContext context) {
    final recorded = working || completed;
    final progress = recorded
        ? (elapsed.inMicroseconds / fullRingDuration.inMicroseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;
    final status = loading && !recorded
        ? loadingMessage
        : working
        ? 'Working'
        : completed
        ? 'Session complete'
        : 'Not clocked in';
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final timer = '${DateTimeUtils.formatDuration(elapsed)}:$seconds';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: working ? _green : AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final diameter = math.min(244.0, constraints.maxWidth);
              return Semantics(
                value: '${(progress * 100).round()}% of the workday',
                label:
                    'Attendance clock. $status. Local time ${DateTimeUtils.formatTime(now)}.'
                    '${checkIn == null ? '' : ' Clocked in at ${DateTimeUtils.formatTime(checkIn!)}.'}',
                child: ExcludeSemantics(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: progress, end: progress),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 500),
                    curve: Curves.linear,
                    builder: (context, fill, child) => CustomPaint(
                      painter: AttendanceDialPainter(fill: fill),
                      child: child,
                    ),
                    child: SizedBox(
                      width: diameter,
                      height: diameter,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox.square(
                          dimension: diameter,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: diameter * .22,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DateTimeUtils.formatTime(now),
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            timer,
            semanticsLabel: 'Time worked: $timer',
            style: TextStyle(
              color: recorded ? _green : AppColors.muted,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: .5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Time worked',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: loading || completed ? null : onToggle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: working ? _red : _green,
                  side: BorderSide(
                    color: loading || completed || onToggle == null
                        ? AppColors.border
                        : working
                        ? _red
                        : _green,
                  ),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                child: loading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: loadingMessage,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Please wait'),
                        ],
                      )
                    : Text(
                        completed
                            ? 'Completed for today'
                            : working
                            ? 'Clock out'
                            : 'Clock in',
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            loading
                ? loadingMessage
                : working
                ? 'Your work session is in progress.'
                : completed
                ? 'You have clocked out. You can clock in again tomorrow.'
                : 'Location is verified when you clock in.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Elapsed work time on an eight-hour scale. The unworked portion stays neutral.
class AttendanceDialPainter extends CustomPainter {
  const AttendanceDialPainter({required this.fill});
  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = size.width;
    final center = Offset(diameter / 2, diameter / 2);
    final stroke = diameter * .065;
    final radius = diameter / 2 - stroke / 2 - 3;
    final ring = Rect.fromCircle(center: center, radius: radius);
    final progress = fill.clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawCircle(center, radius, paint..color = AppColors.border);
    if (progress > 0) {
      paint.color = _green;
      if (progress == 1) {
        canvas.drawCircle(center, radius, paint);
      } else {
        canvas.drawArc(
          ring,
          -math.pi / 2,
          math.pi * 2 * progress,
          false,
          paint..strokeCap = StrokeCap.round,
        );
      }
    }

    final tickRadius = radius - stroke - 6;
    for (var tick = 0; tick < 60; tick++) {
      final major = tick % 5 == 0;
      final angle = tick * math.pi / 30 - math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * tickRadius,
        center + direction * (tickRadius - (major ? 9 : 4)),
        Paint()
          ..color = major ? const Color(0xFFB8C0C8) : const Color(0xFFE4E7EC)
          ..strokeWidth = major ? 1.5 : 1
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(AttendanceDialPainter oldDelegate) =>
      fill != oldDelegate.fill;
}
