import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  final _secureToken = _SecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: const <String, Object>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(dio: _dio, storage: _secureToken));

    // 1. Add Retry Interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // 2. Add Logger (Debug Mode Only)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  Future<String?> getAccessToken() => _secureToken.getAccessToken();

  Future<String?> getRefreshToken() => _secureToken.getRefreshToken();

  Future<void> clearTokens() => _secureToken.clearTokens();

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request(
      method: 'PATCH',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> _request<T>({
    required String method,
    required String path,
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}

class _SecureStorage {
  final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const String _authAccessToken = 'auth_token';
  static const String _authRefreshToken = "auth_refresh_token";

  Future<String?> getAccessToken() => _storage.read(key: _authAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _authRefreshToken);

  Future<void> saveTokens({
    required String authAccessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _authAccessToken, value: authAccessToken);

    if (refreshToken != null) {
      await _storage.write(key: _authRefreshToken, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _authAccessToken),
      _storage.delete(key: _authRefreshToken),
    ]);
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final _SecureStorage _storage;

  Completer<bool>? _refreshCompleter;

  _AuthInterceptor({required Dio dio, required _SecureStorage storage})
    : _dio = dio,
      _storage = storage;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;

      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          final accessToken = await _storage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } else {
          await _storage.clearTokens();
          return handler.next(err);
        }
      } catch (e) {
        await _storage.clearTokens();
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _storage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Failed to read saved access token: $e',
          error: e,
          // stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        final data = body is Map ? body['data'] : null;

        if (data is Map) {
          final accessToken = data['accessToken'];
          final refreshToken = data['refreshToken'];

          if (accessToken is String &&
              accessToken.isNotEmpty &&
              refreshToken is String &&
              refreshToken.isNotEmpty) {
            await _storage.saveTokens(
              authAccessToken: accessToken,
              refreshToken: refreshToken,
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving token: $e");
      }
    }
    handler.next(response);
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        _refreshCompleter = null;
        return false;
      }

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken =
            data['data']['accessToken'] ?? data['data']['token'];
        final newRefreshToken = data['data']['refreshToken'];

        if (newAccessToken != null) {
          await _storage.saveTokens(
            authAccessToken: newAccessToken.toString(),
            refreshToken: newRefreshToken?.toString() ?? refreshToken,
          );

          _refreshCompleter!.complete(true);
          _refreshCompleter = null;
          return true;
        }
      }

      _refreshCompleter!.complete(false);
      _refreshCompleter = null;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      _refreshCompleter!.complete(false);
      _refreshCompleter = null;
      return false;
    }
  }
}
