import 'package:get/get.dart';

import '../models/directory_models.dart';
import '../repositories/directory_repository.dart';

class AgenciesController extends GetxController {
  AgenciesController(this._repository);

  final DirectoryRepository _repository;

  final agencies = <Agency>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? search, String? city}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      agencies.assignAll(await _repository.listAgencies(search: search, city: city));
    } catch (_) {
      errorMessage.value = 'Impossible de charger les agences.';
    } finally {
      isLoading.value = false;
    }
  }
}