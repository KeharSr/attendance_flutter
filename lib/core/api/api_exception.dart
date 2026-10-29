import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.type,
  });

  factory ApiException.fromDioException(DioException exception) {
    final response = exception.response;
    final responseMessage = _messageFromData(response?.data);

    return ApiException(
      message: responseMessage ?? exception.message ?? 'An API error occurred.',
      statusCode: response?.statusCode,
      data: response?.data,
      type: exception.type,
    );
  }

  final String message;
  final int? statusCode;
  final Object? data;
  final DioExceptionType? type;

  static String? _messageFromData(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }

    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
