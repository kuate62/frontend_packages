import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';
import 'package:frontend_packages/features/auth/controllers/auth_controller.dart';
import 'package:frontend_packages/features/auth/models/auth_models.dart';
import 'package:frontend_packages/features/auth/repositories/auth_repository.dart';
import 'package:get/get.dart' hide Response;

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  AuthSession? loginResult;
  Object? loginError;
  AuthSession? registerResult;
  Object? registerError;
  User? meResult;
  Object? meError;
  int loginCalls = 0;
  int registerCalls = 0;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    loginCalls++;
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String lastName,
    required String phone,
    String? firstName,
  }) async {
    registerCalls++;
    if (registerError != null) throw registerError!;
    return registerResult!;
  }

  @override
  Future<User> me() async {
    if (meError != null) throw meError!;
    return meResult!;
  }

  @override
  Future<void> logout() async {}
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

const _user = User(
  id: 'u1',
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
  status: 'ACTIVE',
  isPlatformAdmin: false,
  memberships: [],
);

void main() {
  late _FakeAuthRepository repository;
  late SecureStorageService storage;
  late AuthController controller;

  setUp(() {
    Get.testMode = true;
    repository = _FakeAuthRepository();
    storage = SecureStorageService(_MemoryStore());
    controller = AuthController(repository: repository, secureStorage: storage);
  });

  tearDown(Get.reset);

  test('connexion réussie enregistre le token et charge le profil', () async {
    repository.loginResult = const AuthSession(
      tokenType: 'Bearer',
      accessToken: 'token-123',
      expiresIn: '15m',
      user: _user,
    );
    repository.meResult = _user;

    final result = await controller.login(email: 'test@example.com', password: 'password');

    expect(result, isTrue);
    expect(await storage.readAccessToken(), 'token-123');
    expect(controller.user.value, _user);
    expect(controller.errorMessage.value, isNull);
  });

  test('identifiants incorrects ne stockent pas de token', () async {
    repository.loginError = DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 401,
        data: {
          'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Identifiants invalides.'},
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final result = await controller.login(email: 'test@example.com', password: 'wrong');

    expect(result, isFalse);
    expect(await storage.readAccessToken(), isNull);
    expect(controller.errorMessage.value, 'Identifiants invalides.');
  });

  test('erreur réseau est distinguée', () async {
    repository.loginError = DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      type: DioExceptionType.connectionError,
    );

    final result = await controller.login(email: 'test@example.com', password: 'password');

    expect(result, isFalse);
    expect(controller.errorMessage.value, 'Connexion au serveur impossible.');
  });

  test('la session non autorisée est gérée', () async {
    repository.loginResult = const AuthSession(
      tokenType: 'Bearer',
      accessToken: 'token-123',
      expiresIn: '15m',
      user: _user,
    );
    repository.meError = DioException(
      requestOptions: RequestOptions(path: '/auth/me'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth/me'),
        statusCode: 401,
        data: {
          'error': {'code': 'UNAUTHENTICATED', 'message': 'Authentification requise.'},
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final result = await controller.login(email: 'test@example.com', password: 'password');

    expect(result, isFalse);
    expect(await storage.readAccessToken(), isNull);
  });

  test('inscription réussie stocke les deux tokens', () async {
    repository.registerResult = const AuthSession(
      tokenType: 'Bearer',
      accessToken: 'access-123',
      expiresIn: '15m',
      refreshToken: 'refresh-123',
      user: _user,
    );

    final result = await controller.register(
      email: 'new@example.com',
      password: 'password123',
      lastName: 'User',
      phone: '+237600000000',
    );

    expect(result, isTrue);
    expect(await storage.readAccessToken(), 'access-123');
    expect(await storage.readRefreshToken(), 'refresh-123');
  });

  test('inscription avec e-mail existant ne stocke pas de token', () async {
    repository.registerError = DioException(
      requestOptions: RequestOptions(path: '/auth/register'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth/register'),
        statusCode: 409,
        data: {
          'error': {'code': 'CONFLICT', 'message': 'Un compte existe déjà.'},
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final result = await controller.register(
      email: 'existing@example.com',
      password: 'password123',
      lastName: 'User',
      phone: '+237600000000',
    );

    expect(result, isFalse);
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
    expect(controller.errorMessage.value, 'Un compte existe déjà.');
  });

  test('client sans membership conserve sa session', () async {
    const clientUser = User(
      id: 'c1',
      email: 'client@example.com',
      firstName: 'Client',
      lastName: 'User',
      status: 'ACTIVE',
      isPlatformAdmin: false,
      memberships: [],
    );
    repository.registerResult = const AuthSession(
      tokenType: 'Bearer',
      accessToken: 'access-456',
      expiresIn: '15m',
      user: clientUser,
    );

    final result = await controller.register(
      email: 'client@example.com',
      password: 'password123',
      lastName: 'User',
      phone: '+237600000000',
    );

    expect(result, isTrue);
    expect(await storage.readAccessToken(), 'access-456');
    expect(controller.user.value, clientUser);
  });

  test('clearSession supprime les deux tokens', () async {
    await storage.saveAccessToken('access');
    await storage.saveRefreshToken('refresh');

    await storage.clearSession();

    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });
}