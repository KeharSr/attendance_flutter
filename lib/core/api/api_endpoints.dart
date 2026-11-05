class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  static const String createUser = "$baseUrl/users/createUser";

  // =======================user routes========================
  static const String loginUser = "$baseUrl/users/loginUser";
  static const String refreshToken = "$baseUrl/users/refreshToken";
  static const String logout = "$baseUrl/users/logout";

  // =======================attendance routes========================
  static const String clockIn = "$baseUrl/attendance/clockin";
  static const String clockOut = "$baseUrl/attendance/clockout";
  static const String todayAttendance = "$baseUrl/attendance/today";

  // =======================leave routes========================
  static const String leaveRequest = "$baseUrl/leave/request";
  static const String allLeaveRequest = "$baseUrl/leave/all";
  static String editLeave(String requestId) =>
      "$baseUrl/leave/request/$requestId";
  static String deleteLeave(String requestId) =>
      "$baseUrl/leave/request/$requestId";

  // =======================overtime routes========================
  static const String overtimeRequest = "$baseUrl/overtime/request";
  static const String fetchAllOvertime = "$baseUrl/overtime/getAllOvertime";
  static String editOvertime(String requestId) =>
      "$baseUrl/overtime/request/$requestId";
  static String deleteOvertime(String requestId) =>
      "$baseUrl/overtime/request/$requestId";

  // =======================missing attendance routes========================
  static const String createMissingAttendance =
      "$baseUrl/missing-attendance/request";
  static const String fetchMissingAttendance =
      "$baseUrl/missing-attendance/get-all-request";
  static String editMissingAttendance(String requestId) =>
      "$baseUrl/missing-attendance/request/$requestId";
  static String deleteMissingAttendance(String requestId) =>
      "$baseUrl/missing-attendance/request/$requestId";
}
