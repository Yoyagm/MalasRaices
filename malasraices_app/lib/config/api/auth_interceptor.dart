import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_constants.dart';

class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _storage;
  final Dio _refreshDio;
  bool _isRefreshing = false;

  AuthInterceptor({required FlutterSecureStorage storage})
      : _storage = storage,
        _refreshDio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't attempt refresh for auth endpoints themselves
    final path = err.requestOptions.path;
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        _isRefreshing = false;
        return handler.next(err);
      }

      // Call refresh endpoint with a separate Dio instance
      final response = await _refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      // Save new tokens
      await Future.wait([
        _storage.write(key: 'access_token', value: newAccessToken),
        _storage.write(key: 'refresh_token', value: newRefreshToken),
      ]);

      _isRefreshing = false;

      // Retry the original request with the new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _refreshDio.fetch(opts);
      return handler.resolve(retryResponse);
    } on DioException {
      _isRefreshing = false;
      // Refresh failed — clear tokens and propagate 401
      await _storage.deleteAll();
      return handler.next(err);
    }
  }
}
