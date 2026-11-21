import 'package:get/get.dart';

import '../models/tenant.dart';
import '../repositories/tenants_repository.dart';

class SuperAdminController extends GetxController {
  SuperAdminController(this._repository);

  final TenantsRepository _repository;

  final tenants = <Tenant>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      tenants.assignAll(await _repository.list());
    } catch (_) {
      errorMessage.value = 'Impossible de charger les entreprises.';
    } finally {
      isLoading.value = false;
    }
  }
}