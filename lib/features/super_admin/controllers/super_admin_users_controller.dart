import 'package:get/get.dart';

import '../models/app_user.dart';
import '../repositories/users_repository.dart';

/// Contrôleur GetX — liste globale des utilisateurs (SUPER_ADMIN).
class SuperAdminUsersController extends GetxController {
  SuperAdminUsersController(this._repository);

  final UsersRepository _repository;

  // État observable
  final users = <AppUser>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final total = 0.obs;
  final currentPage = 1.obs;
  final hasMore = false.obs;

  // Filtres observables
  final searchQuery = ''.obs;
  final filterRole = RxnString();
  final filterStatus = RxnString();

  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Chargement initial ou rechargement complet.
  Future<void> load() async {
    currentPage.value = 1;
    users.clear();
    hasMore.value = false;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.list(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        role: filterRole.value,
        status: filterStatus.value,
        page: 1,
        limit: _limit,
      );
      final items = result['items'] as List<AppUser>;
      users.assignAll(items);
      total.value = result['total'] as int;
      hasMore.value = items.length >= _limit && users.length < total.value;
    } catch (_) {
      errorMessage.value = 'Impossible de charger les utilisateurs.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualisation (pull-to-refresh).
  @override
  Future<void> refresh() => load();

  /// Pagination — charger la page suivante.
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    isLoading.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final result = await _repository.list(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        role: filterRole.value,
        status: filterStatus.value,
        page: nextPage,
        limit: _limit,
      );
      final items = result['items'] as List<AppUser>;
      users.addAll(items);
      currentPage.value = nextPage;
      hasMore.value = items.length >= _limit && users.length < total.value;
    } catch (_) {
      // On ne remplace pas le message d'erreur global sur une pagination
    } finally {
      isLoading.value = false;
    }
  }

  /// Mise à jour de la recherche texte.
  void onSearchChanged(String value) {
    searchQuery.value = value;
    load();
  }

  /// Mise à jour du filtre de rôle.
  void setRoleFilter(String? role) {
    filterRole.value = role;
    load();
  }

  /// Mise à jour du filtre de statut.
  void setStatusFilter(String? status) {
    filterStatus.value = status;
    load();
  }

  /// Réinitialisation de tous les filtres.
  void clearFilters() {
    searchQuery.value = '';
    filterRole.value = null;
    filterStatus.value = null;
    load();
  }

  /// Modification du statut global d'un utilisateur.
  Future<void> setUserStatus(String userId, String newStatus) async {
    try {
      final updated = await _repository.setUserStatus(userId, newStatus);
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = updated;
        users.refresh();
      }
      Get.snackbar('Succès', 'Statut mis à jour.', duration: const Duration(seconds: 3));
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut.', duration: const Duration(seconds: 3));
    }
  }
}
