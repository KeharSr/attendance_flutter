class ApiEndpoints {
  ApiEndpoints._();

  // static const String baseUrl = 'https://api.hrms.gadgetbyte.com.np/api/v1';
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  static const String createUser = "$baseUrl/users/createUser";

  // =======================user routes========================
  static const String loginUser = "$baseUrl/users/loginUser";
  static const String refreshToken = "$baseUrl/users/refreshToken";
  static const String logout = "$baseUrl/users/logout";

  static const String registerDevice = '$baseUrl/notifications/register';
  static const String unregisterDevice = '$baseUrl/notifications/unregister';

  // =======================attendance routes========================
  static const String clockIn = "$baseUrl/attendance/clockin";
  static const String clockOut = "$baseUrl/attendance/clockout";
  static const String todayAttendance = "$baseUrl/attendance/today";

  // =======================leave routes========================
  static const String leaveRequest = "$baseUrl/leave/request";
  static String allLeaveRequest({num? year, num? month}) =>
      "$baseUrl/leave/all?year=$year&month=$month";
  static String editLeave(String requestId) =>
      "$baseUrl/leave/request/$requestId";
  static String deleteLeave(String requestId) =>
      "$baseUrl/leave/request/$requestId";

  // =======================overtime routes========================
  static const String overtimeRequest = "$baseUrl/overtime/request";
  static String fetchAllOvertime({required int year, required int month}) =>
      "$baseUrl/overtime/getAllOvertime?year=$year&month=$month";
  static String editOvertime(String requestId) =>
      "$baseUrl/overtime/request/$requestId";
  static String deleteOvertime(String requestId) =>
      "$baseUrl/overtime/request/$requestId";

  // =======================missing attendance routes========================
  static const String createMissingAttendance =
      "$baseUrl/missing-attendance/request";
  static String fetchMissingAttendance({
    required int year,
    required int month,
  }) => "$baseUrl/missing-attendance/get-all-request?year=$year&month=$month";
  static String editMissingAttendance(String requestId) =>
      "$baseUrl/missing-attendance/request/$requestId";
  static String deleteMissingAttendance(String requestId) =>
      "$baseUrl/missing-attendance/request/$requestId";
}
