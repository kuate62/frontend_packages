import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/network/auth_interceptor.dart';
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

class _RefreshAdapter implements HttpClientAdapter {
  int dataCalls = 0;
  int refreshCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      refreshCalls++;
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{
          'data': <String, dynamic>{
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
          },
        }),
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }

    dataCalls++;
    if (dataCalls == 1) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{
          'error': <String, dynamic>{'code': 'UNAUTHENTICATED', 'message': 'Authentification requise.'},
        }),
        401,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }

    final auth = options.headers['Authorization'];
    if (auth == 'Bearer new-access') {
      return ResponseBody.fromString(
        '{"data":{"ok":true}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString('unauthorized', 401);
  }
}

class _InvalidRefreshAdapter implements HttpClientAdapter {
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
        '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
        401,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
      401,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  int refreshCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      refreshCalls++;
    }
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
      401,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _NetworkErrorRefreshAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'network',
      );
    }
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
      401,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _ServerErrorRefreshAdapter implements HttpClientAdapter {
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
        '{"error":{"code":"INTERNAL_ERROR","message":"Erreur serveur."}}',
        500,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
      401,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _RefreshWithoutNewTokenAdapter implements HttpClientAdapter {
  int dataCalls = 0;

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
        '{"data":{"accessToken":"new-access"}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    dataCalls++;
    if (dataCalls == 1) {
      return ResponseBody.fromString(
        '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
        401,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString(
      '{"data":{"ok":true}}',
      200,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _ConcurrentRefreshAdapter implements HttpClientAdapter {
  int refreshCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return ResponseBody.fromString(
        '{"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    if (options.headers['Authorization'] == 'Bearer new-access') {
      return ResponseBody.fromString(
        '{"data":{"ok":true}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
      401,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _RefreshEndpointAdapter implements HttpClientAdapter {
  int refreshCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      refreshCalls++;
      return ResponseBody.fromString(
        '{"data":{"accessToken":"new-access"}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString('ok', 200);
  }
}

class _DelayedRefreshAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return ResponseBody.fromString(
        '{"data":{"accessToken":"late-access","refreshToken":"late-refresh"}}',
        200,
        headers: <String, List<String>>{
          'content-type': <String>['application/json'],
        },
      );
    }
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHENTICATED","message":"Authentification requise."}}',
      401,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }
}

class _FailingStorage implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    throw Exception('storage failure');
  }
}

void main() {
  test('renouvelle le token et rejoue la requête', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _RefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    final response = await dio.get<Map<String, dynamic>>('/data');

    expect(response.statusCode, 200);
    expect(await storage.readAccessToken(), 'new-access');
    expect(await storage.readRefreshToken(), 'new-refresh');
    expect(adapter.refreshCalls, 1);
  });

  test('supprime la session si le refresh token est invalide', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _InvalidRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    try {
      await dio.get<void>('/data');
    } catch (_) {}

    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });

  test('ne renouvelle pas sans refresh token', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');

    final adapter = _UnauthorizedAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    try {
      await dio.get<void>('/data');
    } catch (_) {}

    expect(await storage.readAccessToken(), 'old-access');
    expect(adapter.refreshCalls, 0);
  });

  test('conserve les tokens en cas d\'erreur réseau pendant le refresh', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _NetworkErrorRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    try {
      await dio.get<void>('/data');
    } catch (_) {}

    expect(await storage.readAccessToken(), 'old-access');
    expect(await storage.readRefreshToken(), 'old-refresh');
  });

  test('conserve les tokens en cas de 500 pendant le refresh', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _ServerErrorRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    try {
      await dio.get<void>('/data');
    } catch (_) {}

    expect(await storage.readAccessToken(), 'old-access');
    expect(await storage.readRefreshToken(), 'old-refresh');
  });

  test('conserve l\'ancien refresh token si le backend n\'en renvoie pas', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _RefreshWithoutNewTokenAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    final response = await dio.get<Map<String, dynamic>>('/data');

    expect(response.statusCode, 200);
    expect(await storage.readAccessToken(), 'new-access');
    expect(await storage.readRefreshToken(), 'old-refresh');
  });

  test('n\'exécute qu\'un seul refresh pour plusieurs requêtes simultanées', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _ConcurrentRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    final results = await Future.wait(<Future<Response<dynamic>>>[
      dio.get<dynamic>('/data1'),
      dio.get<dynamic>('/data2'),
    ], eagerError: false);

    expect(adapter.refreshCalls, 1);
    expect(results.length, 2);
    expect(await storage.readAccessToken(), 'new-access');
  });

  test('une requête de refresh ne déclenche pas de second refresh', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _RefreshEndpointAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio));

    await dio.post<void>('/auth/refresh', data: <String, dynamic>{'refreshToken': 'old-refresh'});

    expect(adapter.refreshCalls, 1);
  });

  test('ignore une réponse de refresh après invalidation', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _DelayedRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    final interceptor = AuthInterceptor(storage, dio);
    dio.interceptors.add(interceptor);

    final future = interceptor.refresh();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    interceptor.invalidateSession();

    final result = await future;

    expect(result, isNull);
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });

  test('ne remplace pas une nouvelle session avec une ancienne réponse', () async {
    final storage = SecureStorageService(_MemoryStore());
    await storage.saveAccessToken('old-access');
    await storage.saveRefreshToken('old-refresh');

    final adapter = _DelayedRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    final interceptor = AuthInterceptor(storage, dio);
    dio.interceptors.add(interceptor);

    final future = interceptor.refresh();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    interceptor.invalidateSession();
    interceptor.activateSession();
    await storage.saveAccessToken('new-session-access');
    await storage.saveRefreshToken('new-session-refresh');

    final result = await future;

    expect(result, isNull);
    expect(await storage.readAccessToken(), 'new-session-access');
    expect(await storage.readRefreshToken(), 'new-session-refresh');
  });

  test('invalide la session si le stockage échoue après rotation', () async {
    final store = _FailingStorage();
    store.values['access_token'] = 'old-access';
    store.values['refresh_token'] = 'old-refresh';
    final storage = SecureStorageService(store);

    final adapter = _RefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1/'));
    dio.httpClientAdapter = adapter;
    final interceptor = AuthInterceptor(storage, dio);
    dio.interceptors.add(interceptor);

    final result = await interceptor.refresh();

    expect(result, isNull);
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });
}