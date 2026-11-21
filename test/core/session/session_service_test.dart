import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/config/app_config.dart';
import 'package:frontend_packages/core/network/dio_client.dart';
import 'package:frontend_packages/core/session/session_service.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';

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

String _fakeJwt(int exp) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode('{"exp":$exp}'));
  return '$header.$payload.signature';
}

void main() {
  test('extrait le claim exp d\'un JWT', () {
    final storage = SecureStorageService(_MemoryStore());
    final client = DioClient(
      config: const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://127.0.0.1:3000',
      ),
      secureStorage: storage,
    );
    final service = SessionService(
      secureStorage: storage,
      dioClient: client,
    );
    final token = _fakeJwt(123456);
    expect(service.readAccessTokenExpiration(token), 123456);
  });

  test('renvoie null pour un JWT malformé', () {
    final storage = SecureStorageService(_MemoryStore());
    final client = DioClient(
      config: const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://127.0.0.1:3000',
      ),
      secureStorage: storage,
    );
    final service = SessionService(
      secureStorage: storage,
      dioClient: client,
    );
    expect(service.readAccessTokenExpiration('not-a-jwt'), isNull);
  });
}