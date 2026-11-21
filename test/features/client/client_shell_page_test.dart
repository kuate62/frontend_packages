import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';
import 'package:frontend_packages/features/auth/controllers/auth_controller.dart';

import 'package:frontend_packages/features/auth/repositories/auth_repository.dart';
import 'package:frontend_packages/features/client/bindings/client_shell_binding.dart';
import 'package:frontend_packages/features/client/controllers/client_shell_controller.dart';
import 'package:frontend_packages/features/client/pages/client_shell_page.dart';
import 'package:frontend_packages/features/directory/controllers/agencies_controller.dart';
import 'package:frontend_packages/features/directory/controllers/companies_controller.dart';
import 'package:frontend_packages/features/directory/models/directory_models.dart';
import 'package:frontend_packages/features/directory/repositories/directory_repository.dart';
import 'package:frontend_packages/features/parcels/controllers/my_parcels_controller.dart';
import 'package:frontend_packages/features/parcels/models/my_parcel.dart';
import 'package:frontend_packages/features/parcels/repositories/my_parcels_repository.dart';

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

class _FakeParcelsRepository extends MyParcelsRepository {
  _FakeParcelsRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  @override
  Future<List<MyParcel>> listMyParcels() async => <MyParcel>[];
}

class _FakeDirectoryRepository extends DirectoryRepository {
  _FakeDirectoryRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  @override
  Future<List<Company>> listCompanies({String? search, String? city, int page = 1, int limit = 20}) async =>
      <Company>[];

  @override
  Future<List<Agency>> listAgencies({String? search, String? city, String? tenantId, int page = 1, int limit = 20}) async =>
      <Agency>[];
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  Future<void> pumpShell(WidgetTester tester) async {
    Get.put<AuthController>(
      AuthController(
        repository: _FakeAuthRepository(),
        secureStorage: SecureStorageService(_MemoryStore()),
      ),
      permanent: true,
    );
    Get.put<MyParcelsRepository>(_FakeParcelsRepository(), permanent: true);
    Get.put<MyParcelsController>(
      MyParcelsController(Get.find<MyParcelsRepository>()),
      permanent: true,
    );
    Get.put<DirectoryRepository>(_FakeDirectoryRepository(), permanent: true);
    Get.put<AgenciesController>(
      AgenciesController(Get.find<DirectoryRepository>()),
      permanent: true,
    );
    Get.put<CompaniesController>(
      CompaniesController(Get.find<DirectoryRepository>()),
      permanent: true,
    );
    ClientShellBinding().dependencies();
    await tester.pumpWidget(const GetMaterialApp(home: ClientShellPage()));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche les quatre onglets et le bouton central', (tester) async {
    await pumpShell(tester);

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Mes colis'), findsOneWidget);
    expect(find.text('Agences'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('change d’onglet', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('Agences'));
    await tester.pumpAndSettle();

    final controller = Get.find<ClientShellController>();
    expect(controller.currentIndex.value, 2);
  });
}