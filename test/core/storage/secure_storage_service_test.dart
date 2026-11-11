import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';

void main() {
  group('SecureStorageService', () {
    late SecureStorageService service;
    late _MemoryStore store;

    setUp(() {
      store = _MemoryStore();
      service = SecureStorageService(store);
    });

    test('enregistre, lit et supprime le jeton', () async {
      expect(await service.readAccessToken(), isNull);

      await service.saveAccessToken(' jwt-1 ');
      expect(await service.readAccessToken(), 'jwt-1');
      expect(store.values[SecureStorageService.accessTokenKey], 'jwt-1');

      await service.deleteAccessToken();
      expect(await service.readAccessToken(), isNull);
    });

    test('clearSession efface toutes les clés', () async {
      await service.saveAccessToken('jwt-1');
      await store.write(key: 'autre', value: 'valeur');

      await service.clearSession();

      expect(store.values, isEmpty);
      expect(await service.readAccessToken(), isNull);
    });

    test('refuse un jeton vide', () {
      expect(() => service.saveAccessToken('   '), throwsArgumentError);
    });
  });
}

class _MemoryStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    values.clear();
  }
}
