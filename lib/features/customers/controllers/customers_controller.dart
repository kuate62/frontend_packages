import 'package:get/get.dart';


import '../models/customer.dart';
import '../repositories/customers_repository.dart';

class CustomersController extends GetxController {
  CustomersController(this._repository);

  final CustomersRepository _repository;

  final results = <Customer>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      results.clear();
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      results.assignAll(await _repository.search(query.trim()));
    } catch (_) {
      errorMessage.value = 'Erreur de recherche.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Customer?> create(Map<String, dynamic> payload) async {
    try {
      final customer = await _repository.create(payload);
      results.insert(0, customer);
      return customer;
    } catch (_) {
      errorMessage.value = 'Impossible de créer le client.';
      return null;
    }
  }
}