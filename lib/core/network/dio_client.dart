import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Client HTTP unique. Aucun endpoint métier n'est déclaré ici.
class DioClient {
  DioClient({
    required AppConfig config,
    required SecureStorageService secureStorage,
    Dio? dio,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: config.apiRootUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    this.dio.interceptors.removeImplyContentTypeInterceptor();
    this.dio.interceptors.add(AuthInterceptor(secureStorage, this.dio));
    this.dio.interceptors.add(ErrorInterceptor());
  }

  final Dio dio;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
