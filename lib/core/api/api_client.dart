import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:attendance_flutter/core/service/token_storage/token_local_data_source.dart';
import 'package:attendance_flutter/core/service/token_storage/secure_token_local_data_source.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  final TokenLocalDataSource _secureToken;
  late final _AuthInterceptor _authInterceptor;

  ApiClient({
    Dio? dio,
    Dio? refreshDio,
    TokenLocalDataSource? tokenStore,
    Future<void> Function()? onSessionExpired,
  }) : _secureToken = tokenStore ?? SecureTokenLocalDataSource() {
    _dio =
        dio ??
        Dio(
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

    _authInterceptor = _AuthInterceptor(
      dio: _dio,
      refreshDio: refreshDio ?? Dio(_dio.options.copyWith()),
      storage: _secureToken,
      onSessionExpired: onSessionExpired,
    );
    _dio.interceptors.add(_authInterceptor);

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
          requestHeader: false,
          requestBody: false,
          responseBody: false,
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

  Future<void> clearTokens() => _authInterceptor.clearTokens();

  /// Validates a saved session using the existing single-flight refresh path.
  Future<bool> restoreSavedSession() => _authInterceptor.restoreSavedSession();

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

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this._dio,
    required this._refreshDio,
    required this._storage,
    this.onSessionExpired,
  });

  final Dio _dio;
  final Dio _refreshDio;
  final TokenLocalDataSource _storage;
  final Future<void> Function()? onSessionExpired;
  Future<bool>? _refreshFuture;
  int? _refreshVersion;
  int _sessionVersion = 0;
  Future<void> _tokenWrites = Future<void>.value();
  static const _retryKey = 'authRetried';
  static const _versionKey = 'authSessionVersion';

  bool _isPublic(RequestOptions request) {
    final path = request.uri.path;
    return path == Uri.parse(ApiEndpoints.loginUser).path ||
        path == Uri.parse(ApiEndpoints.createUser).path ||
        path == Uri.parse(ApiEndpoints.refreshToken).path;
  }

  Future<void> _write(Future<void> Function() action) {
    final result = _tokenWrites.then((_) => action());
    _tokenWrites = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<void> clearTokens() {
    final version = ++_sessionVersion;
    return _write(() async {
      if (version == _sessionVersion) await _storage.clearTokens();
    });
  }

  Future<void> _expireSession(int version) {
    if (version != _sessionVersion) return Future<void>.value();
    final expiredVersion = ++_sessionVersion;
    return _write(() async {
      if (expiredVersion != _sessionVersion) return;
      await _storage.clearTokens();
      if (expiredVersion == _sessionVersion) await onSessionExpired?.call();
    });
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublic(options)) {
      options.headers.remove('Authorization');
      handler.next(options);
      return;
    }
    try {
      options.extra.putIfAbsent(_versionKey, () => _sessionVersion);
      final accessToken = await _storage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      } else {
        options.headers.remove('Authorization');
      }
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Unable to read the saved session.',
          error: error,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final path = response.requestOptions.uri.path;
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        path == Uri.parse(ApiEndpoints.loginUser).path) {
      try {
        final body = response.data;
        final data = body is Map ? body['data'] : null;
        final access = data is Map ? data['accessToken'] : null;
        final refresh = data is Map ? data['refreshToken'] : null;
        if (access is! String ||
            access.isEmpty ||
            refresh is! String ||
            refresh.isEmpty) {
          throw const FormatException(
            'Login response is missing authentication tokens.',
          );
        }
        final version = ++_sessionVersion;
        await _write(() async {
          if (version == _sessionVersion) {
            await _storage.saveTokens(
              authAccessToken: access,
              refreshToken: refresh,
            );
          }
        });
      } catch (error, stack) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            message: 'Unable to save the signed-in session.',
            error: error,
            stackTrace: stack,
          ),
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final request = error.requestOptions;
    final version = request.extra[_versionKey];
    if (error.response?.statusCode != 401 ||
        _isPublic(request) ||
        version is! int ||
        version != _sessionVersion) {
      handler.next(error);
      return;
    }
    if (request.extra[_retryKey] == true) {
      await _expireSession(version);
      handler.next(error);
      return;
    }
    try {
      final current = await _storage.getAccessToken();
      if (version != _sessionVersion) {
        handler.next(error);
        return;
      }
      // A delayed 401 may refer to the token another request already replaced.
      if (current == null ||
          current.isEmpty ||
          request.headers['Authorization'] == 'Bearer $current') {
        final refreshed = await _refreshToken(version);
        if (!refreshed) {
          await _expireSession(version);
          handler.next(error);
          return;
        }
      }
      if (version != _sessionVersion) {
        handler.next(error);
        return;
      }
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        await _expireSession(version);
        handler.next(error);
        return;
      }
      final response = await _dio.fetch<dynamic>(
        request.copyWith(
          headers: {...request.headers, 'Authorization': 'Bearer $token'},
          extra: {...request.extra, _retryKey: true},
          data: request.data is FormData
              ? (request.data as FormData).clone()
              : request.data,
        ),
      );
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.reject(retryError);
    } catch (failure, stack) {
      handler.reject(
        DioException(
          requestOptions: request,
          message: 'Unable to restore your session. Please try again.',
          error: failure,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<bool> restoreSavedSession() async {
    final version = _sessionVersion;
    final restored = await _refreshToken(version);
    if (!restored) await _expireSession(version);
    return restored && version == _sessionVersion;
  }

  Future<bool> _refreshToken(int version) async {
    final existing = _refreshFuture;
    if (existing != null && _refreshVersion == version) return existing;
    final refresh = _rotateTokens(version);
    _refreshFuture = refresh;
    _refreshVersion = version;
    try {
      return await refresh;
    } finally {
      if (identical(_refreshFuture, refresh)) {
        _refreshFuture = null;
        _refreshVersion = null;
      }
    }
  }

  Future<bool> _rotateTokens(int version) async {
    final refreshToken = await _storage.getRefreshToken();
    if (version != _sessionVersion ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return false;
    }
    try {
      // Separate Dio avoids recursively refreshing its own failed refresh call.
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data?['data'];
      final access = data is Map ? data['accessToken'] : null;
      final refresh = data is Map ? data['refreshToken'] : null;
      if (access is! String ||
          access.isEmpty ||
          refresh is! String ||
          refresh.isEmpty) {
        throw const FormatException(
          'The session refresh response is missing tokens.',
        );
      }
      if (version != _sessionVersion) return false;
      await _write(() async {
        if (version == _sessionVersion) {
          await _storage.saveTokens(
            authAccessToken: access,
            refreshToken: refresh,
          );
        }
      });
      return version == _sessionVersion;
    } on DioException catch (error) {
      if ([400, 401, 403].contains(error.response?.statusCode)) return false;
      rethrow;
    }
  }
}
