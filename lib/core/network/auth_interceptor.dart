import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../storage/secure_storage_service.dart';

/// Ajoute le jeton d'accès et gère le renouvellement automatique.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, this._dio);

  final SecureStorageService _secureStorage;
  final Dio _dio;

  Completer<String?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _attachToken(options, handler);
  }

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleError(err, handler);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    final isAuthEndpoint = requestOptions.path.contains('/auth/login') ||
        requestOptions.path.contains('/auth/register') ||
        requestOptions.path.contains('/auth/refresh');
    final alreadyRetried = requestOptions.extra['retried'] == true;

    if (response?.statusCode != 401 || isAuthEndpoint || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final newAccessToken = await refresh();
      if (newAccessToken == null || newAccessToken.isEmpty) {
        handler.next(err);
        return;
      }

      requestOptions.extra['retried'] = true;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _sessionValid = true;
  int _sessionGeneration = 0;

  void activateSession() {
    _sessionGeneration++;
    _sessionValid = true;
  }

  void invalidateSession() {
    _sessionGeneration++;
    _sessionValid = false;
  }

  Future<String?> refresh() async {
    if (!_sessionValid) {
      return null;
    }
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }
    return _refresh(refreshToken);
  }

  Future<String?> _refresh(String refreshToken) async {
    final generation = _sessionGeneration;
    if (_refreshCompleter != null) {
      final result = await _refreshCompleter!.future;
      if (generation != _sessionGeneration || !_sessionValid) {
        return null;
      }
      return result;
    }

    _refreshCompleter = Completer<String?>();
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
        ),
      );
      refreshDio.httpClientAdapter = _dio.httpClientAdapter;

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (generation != _sessionGeneration || !_sessionValid) {
        if (!_sessionValid) {
          await _secureStorage.clearSession();
          _navigateToLogin();
        }
        _refreshCompleter!.complete(null);
        return null;
      }

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _secureStorage.clearSession();
        invalidateSession();
        _navigateToLogin();
        _refreshCompleter!.complete(null);
        return null;
      }

      if (generation != _sessionGeneration || !_sessionValid) {
        if (!_sessionValid) {
          await _secureStorage.clearSession();
          _navigateToLogin();
        }
        _refreshCompleter!.complete(null);
        return null;
      }

      try {
        await _secureStorage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _secureStorage.saveRefreshToken(newRefreshToken);
        }
      } catch (_) {
        await _secureStorage.clearSession();
        invalidateSession();
        _navigateToLogin();
        _refreshCompleter!.complete(null);
        return null;
      }

      if (generation != _sessionGeneration || !_sessionValid) {
        if (!_sessionValid) {
          await _secureStorage.clearSession();
          _navigateToLogin();
        }
        _refreshCompleter!.complete(null);
        return null;
      }

      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _secureStorage.clearSession();
        invalidateSession();
        _navigateToLogin();
      }
      _refreshCompleter!.complete(null);
      return null;
    } catch (error) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  void _navigateToLogin() {
    try {
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      // Navigation indisponible dans les tests unitaires.
    }
  }
}