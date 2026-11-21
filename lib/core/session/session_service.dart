import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

class SessionService with WidgetsBindingObserver {
  SessionService({
    required this.secureStorage,
    required this.dioClient,
    DateTime Function()? now,
    Timer Function(Duration, void Function())? createTimer,
  })  : _now = now ?? (() => DateTime.now()),
        _createTimer = createTimer ?? Timer.new {
    _authInterceptor = dioClient.dio.interceptors.whereType<AuthInterceptor>().first;
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      // Binding indisponible dans certains tests.
    }
  }

  late final DateTime Function() _now;
  late final Timer Function(Duration, void Function()) _createTimer;

  final SecureStorageService secureStorage;
  final DioClient dioClient;

  late final AuthInterceptor _authInterceptor;

  Timer? _timer;
  bool _disposed = false;

  static const Duration _safetyMargin = Duration(seconds: 60);
  static const Duration _retryDelay = Duration(seconds: 30);

  int? readAccessTokenExpiration(String token) => _readExpiration(token);

  int? _readExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final json = (jsonDecode(payload) as Map<String, dynamic>);
      final exp = json['exp'];
      if (exp is int) return exp;
      if (exp is num) return exp.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> scheduleFromToken(String token) async {
    cancel();
    final expiration = _readExpiration(token);
    if (expiration == null) {
      return;
    }

    final now = _now().millisecondsSinceEpoch ~/ 1000;
    final remainingSeconds = expiration - now;
    final delaySeconds = remainingSeconds - _safetyMargin.inSeconds;

    if (delaySeconds <= 0) {
      await refreshNow();
    } else {
      _timer = _createTimer(Duration(seconds: delaySeconds), () {
        refreshNow();
      });
    }
  }

  Future<void> refreshNow() async {
    if (_disposed) {
      return;
    }

    try {
      final newToken = await _authInterceptor.refresh();
      if (newToken == null || newToken.isEmpty) {
        await _invalidateSession();
        return;
      }
      scheduleFromToken(newToken);
    } catch (_) {
      _timer = _createTimer(_retryDelay, refreshNow);
    }
  }

  Future<void> _invalidateSession() async {
    cancelAndInvalidate();
    await secureStorage.clearSession();
    try {
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      // Navigation indisponible dans les tests.
    }
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void activateSession() {
    _authInterceptor.activateSession();
    cancel();
  }

  void cancelAndInvalidate() {
    _authInterceptor.invalidateSession();
    cancel();
  }

  Future<void> restoreAndSchedule() async {
    final token = await secureStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      cancel();
      return;
    }
    scheduleFromToken(token);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      handleAppResumed();
    }
  }

  Future<void> handleAppResumed() async {
    final token = await secureStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      cancel();
      return;
    }

    final expiration = _readExpiration(token);
    if (expiration == null) {
      return;
    }

    final now = _now().millisecondsSinceEpoch ~/ 1000;
    if (now >= expiration - _safetyMargin.inSeconds) {
      await refreshNow();
    } else {
      scheduleFromToken(token);
    }
  }

  void dispose() {
    _disposed = true;
    cancel();
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {
      // Ignore.
    }
  }
}