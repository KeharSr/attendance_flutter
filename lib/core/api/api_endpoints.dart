class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  static const String createUser = "$baseUrl/users/createUser";
  static const String loginUser = "$baseUrl/users/loginUser";
  static const String clockIn = "$baseUrl/attendance/clockin";
}
