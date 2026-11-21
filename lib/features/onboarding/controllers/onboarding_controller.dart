import 'package:get/get.dart';

import '../../../core/storage/local_storage_service.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._storage);

  final LocalStorageService _storage;

  final pageIndex = 0.obs;

  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  Future<void> complete() async {
    await _storage.setOnboardingCompleted(true);
  }
}