import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/storage/local_storage_service.dart';

void main() {
  test('conserve l’état onboarding', () async {
    final storage = LocalStorageService();

    expect(await storage.isOnboardingCompleted(), isFalse);

    await storage.setOnboardingCompleted(true);
    expect(await storage.isOnboardingCompleted(), isTrue);

    await storage.remove(key: LocalStorageService.onboardingCompletedKey);
    expect(await storage.isOnboardingCompleted(), isFalse);
  });
}