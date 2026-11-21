import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/config/app_config.dart';
import 'package:frontend_packages/core/network/api_exception.dart';
import 'package:frontend_packages/core/network/auth_interceptor.dart';
import 'package:frontend_packages/core/network/dio_client.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';

void main() {
  group('DioClient', () {
    test('configure la racine /api/v1 et les délais', () {
      final storage = SecureStorageService(_MemoryStore());
      final client = DioClient(
        config: const AppConfig(
          environment: AppEnvironment.production,
          apiBaseUrl: 'https://api.exemple.com',
        ),
        secureStorage: storage,
      );

      expect(client.dio.options.baseUrl, 'https://api.exemple.com/api/v1/');
      expect(client.dio.options.connectTimeout, DioClient.connectTimeout);
      expect(client.dio.options.receiveTimeout, DioClient.receiveTimeout);
      expect(client.dio.options.headers['Accept'], 'application/json');
      expect(client.dio.interceptors.length, 2);
    });
  });

  group('AuthInterceptor', () {
    test('ajoute le JWT quand une session existe', () async {
      final storage = SecureStorageService(_MemoryStore());
      await storage.saveAccessToken('token-test');
      final adapter = _CaptureAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(storage, dio));

      await dio.get<void>('ping');

      expect(adapter.authorization, 'Bearer token-test');
      expect(adapter.path, '/api/v1/ping');
    });

    test('n’ajoute pas d’en-tête sans jeton', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
      final adapter = _CaptureAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(SecureStorageService(_MemoryStore()), dio),
      );

      await dio.get<void>('ping');

      expect(adapter.authorization, isNull);
    });
  });

  group('ApiException', () {
    test('lit le schéma error.code et error.message', () {
      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 422,
            data: {
              'error': {'code': 'VALIDATION', 'message': 'Champ invalide'},
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.code, 'VALIDATION');
      expect(exception.message, 'Champ invalide');
      expect(exception.statusCode, 422);
    });

    test('décrit un délai dépassé sans corps de réponse', () {
      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(exception.message, 'Le serveur met trop de temps à répondre.');
      expect(exception.statusCode, isNull);
    });
  });
}

class _MemoryStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

class _CaptureAdapter implements HttpClientAdapter {
  String? authorization;
  String? path;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorization = options.headers['Authorization'] as String?;
    path = options.uri.path;
    return ResponseBody.fromString('{}', 200);
  }
}
