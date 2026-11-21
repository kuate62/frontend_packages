import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_confirm_dialog.dart';
import '../controllers/super_admin_users_controller.dart';
import '../models/app_user.dart';
import '../repositories/users_repository.dart';

/// Page de détail d'un utilisateur — SUPER_ADMIN.
class SuperAdminUserDetailPage extends StatefulWidget {
  const SuperAdminUserDetailPage({super.key, this.userId});

  final String? userId;

  @override
  State<SuperAdminUserDetailPage> createState() => _SuperAdminUserDetailPageState();
}

class _SuperAdminUserDetailPageState extends State<SuperAdminUserDetailPage> {
  AppUser? _user;
  bool _isLoading = true;
  String? _error;

  String get _userId => widget.userId ?? (Get.arguments as String? ?? '');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_userId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Identifiant utilisateur manquant.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = Get.find<UsersRepository>();
      final user = await repo.getUser(_userId);
      if (mounted) setState(() => _user = user);
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de charger cet utilisateur.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStatusAction(BuildContext context, AppUser user) async {
    final isSuspending = user.status == 'ACTIVE';
    final confirmed = await AppConfirmDialog.show(
      context,
      title: isSuspending ? 'Confirmer la suspension' : 'Confirmer la réactivation',
      message: isSuspending
          ? 'Êtes-vous sûr de vouloir suspendre ce compte utilisateur ?'
          : 'Êtes-vous sûr de vouloir réactiver ce compte utilisateur ?',
      confirmLabel: isSuspending ? 'Suspendre' : 'Réactiver',
      cancelLabel: 'Annuler',
      isDestructive: isSuspending,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final repo = Get.find<UsersRepository>();
      final updated = await repo.setUserStatus(user.id, isSuspending ? 'SUSPENDED' : 'ACTIVE');
      if (mounted) setState(() => _user = updated);

      // Mise à jour de la liste si le contrôleur est disponible
      if (Get.isRegistered<SuperAdminUsersController>()) {
        Get.find<SuperAdminUsersController>().setUserStatus(user.id, isSuspending ? 'SUSPENDED' : 'ACTIVE');
      }
      Get.snackbar('Succès', 'Statut mis à jour.', duration: const Duration(seconds: 3));
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de modifier le statut.', duration: const Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Utilisateur')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Utilisateur')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppDimensions.sm),
              Text(_error!),
              const SizedBox(height: AppDimensions.sm),
              ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    final user = _user!;
    return Scaffold(
      appBar: AppBar(title: Text('${user.firstName} ${user.lastName}'.trim())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Informations personnelles'),
            _InfoRow('Nom complet', user.fullName),
            _InfoRow('E-mail', user.email),
            if (user.phone != null) _InfoRow('Téléphone', user.phone!),
            _InfoRow('Statut', user.status, key: const Key('user_status_text')),
            if (user.isPlatformAdmin) _InfoRow('Rôle plateforme', 'Super Administrateur'),
            if (user.createdAt != null) _InfoRow('Créé le', user.createdAt!),
            const Divider(height: AppDimensions.xl),
            _SectionTitle('Entreprises et adhésions'),
            if (user.memberships.isEmpty)
              const Text(
                'Aucune adhésion.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...user.memberships.map((m) => _MembershipCard(membership: m)),
            const SizedBox(height: AppDimensions.xl),
            if (!user.isPlatformAdmin)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('toggle_user_status_button'),
                  onPressed: _isLoading ? null : () => _handleStatusAction(context, user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.status == 'ACTIVE' ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(user.status == 'ACTIVE' ? 'Suspendre ce compte' : 'Réactiver ce compte'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliaires
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership});

  final AppUserMembership membership;

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
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: ListTile(
        leading: const Icon(Icons.business),
        title: Text(membership.tenantName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rôle : ${membership.roleLabel ?? membership.role}'),
            if (membership.agencyName != null) Text('Agence : ${membership.agencyName}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(membership.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _statusColor(membership.status)),
          ),
          child: Text(
            membership.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor(membership.status),
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
