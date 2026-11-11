/// Contrat de stockage clé-valeur sécurisé.
///
/// L'implémentation de production repose sur Flutter Secure Storage.
/// Les tests injectent une mémoire locale.
abstract class SecureKeyValueStore {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});

  Future<void> deleteAll();
}
