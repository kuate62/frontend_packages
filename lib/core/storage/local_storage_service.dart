/// Stockage local non sensible (préférences et état d'onboarding).
class LocalStorageService {
  final Map<String, String> _values = <String, String>{};

  static const String onboardingCompletedKey = 'onboarding_completed';

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

  Future<bool> isOnboardingCompleted() async {
    return _values[onboardingCompletedKey] == 'true';
  }

  Future<void> setOnboardingCompleted(bool value) async {
    _values[onboardingCompletedKey] = value.toString();
  }
}