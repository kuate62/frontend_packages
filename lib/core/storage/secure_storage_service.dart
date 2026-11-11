import 'secure_key_value_store.dart';

/// Session d'authentification conservée hors des préférences partagées.
class SecureStorageService {
  SecureStorageService(this._store);

  final SecureKeyValueStore _store;

  static const String accessTokenKey = 'access_token';

  Future<void> saveAccessToken(String token) {
    final value = token.trim();
    if (value.isEmpty) {
      throw ArgumentError.value(token, 'token', 'Jeton vide.');
    }
    return _store.write(key: accessTokenKey, value: value);
  }

  Future<String?> readAccessToken() async {
    final value = await _store.read(key: accessTokenKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> deleteAccessToken() {
    return _store.delete(key: accessTokenKey);
  }

  /// Efface toute la session locale (jeton et clés associées).
  Future<void> clearSession() {
    return _store.deleteAll();
  }
}
