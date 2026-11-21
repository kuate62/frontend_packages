import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/super_admin_users_controller.dart';
import '../models/app_user.dart';

/// Page de liste globale des utilisateurs — SUPER_ADMIN.
class SuperAdminUsersPage extends GetView<SuperAdminUsersController> {
  const SuperAdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: controller),
          _FilterRow(controller: controller),
          Expanded(child: _UserList(controller: controller)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barre de recherche
// ---------------------------------------------------------------------------

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller});

  final SuperAdminUsersController controller;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.controller.searchQuery.value);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.sm),
      child: TextField(
        key: const Key('users_search_field'),
        controller: _textCtrl,
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, e-mail ou téléphone…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(
            () => widget.controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textCtrl.clear();
                      widget.controller.onSearchChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
        ),
        onChanged: widget.controller.onSearchChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filtres rapides (rôle + statut)
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final SuperAdminUsersController controller;

  static const _roles = <String>['TENANT_ADMIN', 'AGENCY_MANAGER', 'AGENT', 'DRIVER'];
  static const _statuses = <String>['ACTIVE', 'SUSPENDED', 'PENDING'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeFilters = controller.filterRole.value != null ||
          controller.filterStatus.value != null;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
        child: Row(
          children: [
            // Filtre rôle
            DropdownButton<String>(
              key: const Key('role_filter'),
              hint: const Text('Rôle'),
              value: controller.filterRole.value,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Tous les rôles')),
                ..._roles.map((r) => DropdownMenuItem<String>(value: r, child: Text(r))),
              ],
              onChanged: controller.setRoleFilter,
            ),
            const SizedBox(width: AppDimensions.sm),
            // Filtre statut
            DropdownButton<String>(
              key: const Key('status_filter'),
              hint: const Text('Statut'),
              value: controller.filterStatus.value,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Tous les statuts')),
                ..._statuses.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))),
              ],
              onChanged: controller.setStatusFilter,
            ),
            if (activeFilters) ...[
              const SizedBox(width: AppDimensions.sm),
              TextButton.icon(
                key: const Key('clear_filters_btn'),
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.filter_alt_off, size: 16),
                label: const Text('Effacer'),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Liste des utilisateurs
// ---------------------------------------------------------------------------

class _UserList extends StatelessWidget {
  const _UserList({required this.controller});

  final SuperAdminUsersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.users.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value != null && controller.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppDimensions.sm),
              Text(controller.errorMessage.value!),
              const SizedBox(height: AppDimensions.sm),
              ElevatedButton(
                onPressed: controller.refresh,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }
      if (controller.users.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey),
              SizedBox(height: AppDimensions.sm),
              Text('Aucun utilisateur trouvé.'),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          itemCount: controller.users.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.users.length) {
              // Déclenchement de la pagination
              controller.loadMore();
              return const Padding(
                padding: EdgeInsets.all(AppDimensions.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final user = controller.users[index];
            return _UserCard(user: user);
          },
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Carte utilisateur
// ---------------------------------------------------------------------------

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final AppUser user;

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'SUSPENDED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('user_card_${user.id}'),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
          ),
        ),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 12)),
            if (user.phone != null)
              Text(user.phone!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (user.memberships.isNotEmpty)
              Text(
                '${user.memberships.length} entreprise(s)',
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(user.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _statusColor(user.status), width: 1),
          ),
          child: Text(
            user.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor(user.status),
            ),
          ),
        ),
        isThreeLine: true,
        onTap: () => Get.toNamed(AppRoutes.superAdminUserDetail, arguments: user.id),
      ),
    );
  }
}
