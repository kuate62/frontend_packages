import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/app/middlewares/auth_middleware.dart';
import 'package:frontend_packages/app/routes/app_routes.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/models/membership.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';
import 'package:frontend_packages/features/auth/controllers/auth_controller.dart';
import 'package:frontend_packages/features/auth/models/auth_models.dart';
import 'package:frontend_packages/features/auth/repositories/auth_repository.dart';

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

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  @override
  Future<void> logout() async {}
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  AuthController buildController({String role = 'AGENT', bool authenticated = true}) {
    final controller = AuthController(
      repository: _FakeAuthRepository(),
      secureStorage: SecureStorageService(_MemoryStore()),
    );
    if (authenticated) {
      controller.accessToken.value = 'token';
      controller.user.value = User(
        id: 'u1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        status: 'ACTIVE',
        isPlatformAdmin: role == 'SUPER_ADMIN',
        memberships: role == 'CLIENT' || role == 'SUPER_ADMIN'
            ? const []
            : [
                Membership(
                  tenantId: 't1',
                  tenantName: 'Tenant',
                  tenantCode: 'T1',
                  role: role,
                  roleLabel: role,
                  agencyId: 'a1',
                  status: 'ACTIVE',
                ),
              ],
      );
    }
    return controller;
  }

  test('redirige un utilisateur non authentifié vers login', () {
    final controller = buildController(authenticated: false);
    Get.put<AuthController>(controller, permanent: true);

    final middleware = AuthMiddleware(allowedRoles: const ['AGENT']);
    final redirect = middleware.redirect('/agent');

    expect(redirect?.name, AppRoutes.login);
  });

  test('autorise un utilisateur avec le bon rôle', () {
    final controller = buildController(role: 'AGENT');
    Get.put<AuthController>(controller, permanent: true);

    final middleware = AuthMiddleware(allowedRoles: const ['AGENT']);
    final redirect = middleware.redirect('/agent');

    expect(redirect, isNull);
  });

  test('redirige un utilisateur avec un mauvais rôle', () {
    final controller = buildController(role: 'CLIENT');
    Get.put<AuthController>(controller, permanent: true);

    final middleware = AuthMiddleware(allowedRoles: const ['AGENT']);
    final redirect = middleware.redirect('/agent');

    expect(redirect?.name, AppRoutes.login);
  });
}