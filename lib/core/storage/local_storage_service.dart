/// Stockage local non sensible (prévu pour le cache et les préférences légères).
///
/// Implémentation mémoire provisoire pour M0. Une persistance (Hive/Drift)
/// sera branchée lors des modules concernés sans changer ce contrat.
class LocalStorageService {
  final Map<String, String> _values = <String, String>{};

  Future<void> writeString({required String key, required String value}) async {
    _values[key] = value;
  }

  Future<String?> readString({required String key}) async => _values[key];

  Future<void> remove({required String key}) async {
    _values.remove(key);
  }

  Future<void> clear() async {
    _values.clear();
  }
}
