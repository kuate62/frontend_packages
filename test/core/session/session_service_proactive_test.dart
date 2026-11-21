import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

class _FakeTimer implements Timer {
  _FakeTimer(this.duration, this.callback);

  final Duration duration;
  final void Function() callback;
  bool cancelled = false;

  @override
  void cancel() {
    cancelled = true;
  }

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

String _fakeJwt(int exp) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode('{"exp":$exp}'));
  return '$header.$payload.signature';
}

void main() {
  test('programme le renouvellement 60 secondes avant expiration', () async {
    final storage = SecureStorageService(_MemoryStore());
    final client = DioClient(
      config: const AppConfig(environment: AppEnvironment.development, apiBaseUrl: 'http://127.0.0.1:3000'),
      secureStorage: storage,
    );
    _FakeTimer? captured;
    final service = SessionService(
      secureStorage: storage,
      dioClient: client,
      now: () => DateTime.fromMillisecondsSinceEpoch(0),
      createTimer: (duration, callback) {
        captured = _FakeTimer(duration, callback);
        return captured!;
      },
    );

    final token = _fakeJwt(120);
    await service.scheduleFromToken(token);

    expect(captured, isNotNull);
    expect(captured!.duration, const Duration(seconds: 60));
    expect(captured!.cancelled, isFalse);
  });

  test('déclenche le renouvellement immédiatement si le token expire dans moins de 60 secondes', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _ProactiveRefreshAdapter();
    final client = DioClient(
      config: const AppConfig(environment: AppEnvironment.development, apiBaseUrl: 'http://127.0.0.1:3000'),
      secureStorage: storage,
    );
    client.dio.httpClientAdapter = adapter;

    final service = SessionService(
      secureStorage: storage,
      dioClient: client,
      now: () => DateTime.fromMillisecondsSinceEpoch(0),
    );

    final token = _fakeJwt(30);
    await service.scheduleFromToken(token);

    expect(await storage.readAccessToken(), 'new-access');
  });
}

class _ProactiveRefreshAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      return ResponseBody.fromString(
        '{"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString('{}', 200);
  }
}