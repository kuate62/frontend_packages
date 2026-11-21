import 'package:get/get.dart';

import '../models/directory_models.dart';
import '../repositories/directory_repository.dart';

class CompaniesController extends GetxController {
  CompaniesController(this._repository);

  final DirectoryRepository _repository;

  final companies = <Company>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final quotes = <String, Map<String, dynamic>>{}.obs;
  final isComparing = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? search, String? city}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      companies.assignAll(await _repository.listCompanies(search: search, city: city));
    } catch (_) {
      errorMessage.value = 'Impossible de charger les entreprises.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> compare(double weightKg) async {
    isComparing.value = true;
    quotes.clear();
    try {
      final results = await Future.wait(companies.map((company) async {
        try {
          final quote = await _repository.quoteCompany(company.id, weightKg: weightKg);
          if (quote != null) {
            quotes[company.id] = quote;
          }
        } catch (_) {
          // Tarif indisponible pour cette entreprise.
        }
      }));
      // ignore: unused_local_variable
      results;
    } finally {
      isComparing.value = false;
    }
  }
}