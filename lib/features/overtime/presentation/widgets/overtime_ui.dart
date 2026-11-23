import 'package:attendance_flutter/core/common/compact_request_card.dart';
import 'package:attendance_flutter/core/common/styled_request_ui.dart';

const overtimeBlue = requestBlue;
const overtimeGreen = requestGreen;
const overtimeInk = requestInk;

typedef OvertimePanel = RequestPanel;
typedef OvertimeMetric = RequestMetric;
typedef OvertimePair = RequestMetricPair;

String overtimeDate(String value) => styledRequestDate(value);
String overtimeRange(String? start, String? end) =>
    styledRequestRange(start, end);
String overtimeHours(String? start, String? end, {double? hours}) =>
    styledRequestHours(start, end, hours: hours);

typedef OvertimeStatusBadge = RequestStatusPill;
