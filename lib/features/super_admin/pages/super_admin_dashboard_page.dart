import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/super_admin_dashboard_controller.dart';
import '../models/super_admin_dashboard_data.dart';

/// Tableau de bord général du Super Administrateur.
class SuperAdminDashboardPage extends GetView<SuperAdminDashboardController> {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Super Administrateur'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            key: const Key('dashboard_nav_tenants_btn'),
            icon: const Icon(Icons.business),
            tooltip: 'Entreprises',
            onPressed: () => Get.toNamed(AppRoutes.platformHome),
          ),
          IconButton(
            key: const Key('dashboard_nav_users_btn'),
            icon: const Icon(Icons.people),
            tooltip: 'Utilisateurs',
            onPressed: () => Get.toNamed(AppRoutes.superAdminUsers),
          ),
          IconButton(
            key: const Key('dashboard_refresh_btn'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.dashboardData.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              key: Key('dashboard_loading_indicator'),
              color: AppColors.primary,
            ),
          );
        }

        if (controller.errorMessage.value != null && controller.dashboardData.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  ElevatedButton(
                    key: const Key('dashboard_retry_btn'),
                    onPressed: controller.refresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.dashboardData.value;
        if (data == null || data.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dashboard_customize_outlined, size: 48, color: AppColors.textDisabled),
                const SizedBox(height: AppDimensions.sm),
                const Text('Aucune donnée statistique disponible.'),
                const SizedBox(height: AppDimensions.md),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Vue globale : Entreprises & Utilisateurs
                const _SectionHeader(title: 'Vue d\'ensemble de la plateforme', icon: Icons.analytics),
                const SizedBox(height: AppDimensions.xs),
                _GlobalKpiGrid(data: data),

                const SizedBox(height: AppDimensions.lg),

                // 2. Opérations : Colis & Trajets
                const _SectionHeader(title: 'Opérations & Transport', icon: Icons.local_shipping),
                const SizedBox(height: AppDimensions.xs),
                _OperationsSection(data: data),

                const SizedBox(height: AppDimensions.lg),

                // 3. Section financière
                const _SectionHeader(title: 'Paiements enregistrés au guichet (V1)', icon: Icons.payments),
                const SizedBox(height: AppDimensions.xs),
                _FinancialSection(payments: data.payments),

                const SizedBox(height: AppDimensions.lg),

                // 4. Activité récente
                const _SectionHeader(title: 'Activité récente', icon: Icons.history),
                const SizedBox(height: AppDimensions.xs),
                _RecentActivitySection(recent: data.recent),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppDimensions.xs),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grille KPI Globale
// ---------------------------------------------------------------------------

class _GlobalKpiGrid extends StatelessWidget {
  const _GlobalKpiGrid({required this.data});

  final SuperAdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > AppDimensions.breakpointTablet ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.sm,
          mainAxisSpacing: AppDimensions.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _KpiCard(
              title: 'Entreprises',
              value: '${data.tenants.total}',
              subtitle: '${data.tenants.active} actives · ${data.tenants.suspended} susp.',
              icon: Icons.business,
              iconColor: AppColors.primary,
              onTap: () => Get.toNamed(AppRoutes.platformHome),
            ),
            _KpiCard(
              title: 'Utilisateurs',
              value: '${data.users.total}',
              subtitle: '${data.users.active} actifs · ${data.users.suspended} susp.',
              icon: Icons.people,
              iconColor: AppColors.accent,
              onTap: () => Get.toNamed(AppRoutes.superAdminUsers),
            ),
            _KpiCard(
              title: 'Agences',
              value: '${data.agenciesTotal}',
              subtitle: 'Points de présence',
              icon: Icons.storefront,
              iconColor: AppColors.secondary,
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section Opérations (Colis & Trajets)
// ---------------------------------------------------------------------------

class _OperationsSection extends StatelessWidget {
  const _OperationsSection({required this.data});

  final SuperAdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final p = data.parcels;
    final t = data.trips;

    final inTransitCount = (p.byStatus['IN_TRANSIT'] ?? 0) + (p.byStatus['LOADED'] ?? 0);
    final waitingCount = (p.byStatus['REGISTERED'] ?? 0) + (p.byStatus['WAITING_FOR_TRANSPORT'] ?? 0);
    final deliveredCount = p.byStatus['DELIVERED'] ?? 0;
    final arrivedCount = p.byStatus['ARRIVED'] ?? 0;
    final returnCount = p.byStatus['RETURN_TO_SENDER'] ?? 0;

    return Card(
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatMiniBlock(
                    label: 'Total Colis',
                    value: '${p.total}',
                    color: AppColors.primary,
                  ),
                ),
                Container(height: 36, width: 1, color: AppColors.border),
                Expanded(
                  child: _StatMiniBlock(
                    label: 'Total Trajets',
                    value: '${t.total}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const Divider(height: AppDimensions.lg),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.xs,
              children: [
                _StatusBadge(label: 'En attente', count: waitingCount, color: AppColors.warning),
                _StatusBadge(label: 'En transit', count: inTransitCount, color: AppColors.info),
                _StatusBadge(label: 'Arrivés', count: arrivedCount, color: AppColors.accentDark),
                _StatusBadge(label: 'Livrés', count: deliveredCount, color: AppColors.success),
                if (returnCount > 0)
                  _StatusBadge(label: 'Retournés', count: returnCount, color: AppColors.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Financière
// ---------------------------------------------------------------------------

class _FinancialSection extends StatelessWidget {
  const _FinancialSection({required this.payments});

  final DashboardPayments payments;

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} ${payments.currency}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Encaissé (Guichet)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      _formatAmount(payments.totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${payments.total} paiement(s)',
                    style: const TextStyle(color: AppColors.secondaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (payments.byMode.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.sm),
              const Divider(),
              const Text('Répartition par moyen de paiement :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...payments.byMode.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        '${entry.value.count} op. (${_formatAmount(entry.value.amount)})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: AppDimensions.xs),
            Text(
              payments.note,
              style: const TextStyle(fontSize: 10, color: AppColors.textDisabled, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Activité Récente
// ---------------------------------------------------------------------------

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.recent});

  final DashboardRecentActivity recent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (recent.tenants.isNotEmpty) ...[
          _SubActivityCard(
            title: 'Dernières entreprises inscrites',
            items: recent.tenants.map((t) => ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 14, child: Icon(Icons.business, size: 16)),
              title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${t.city ?? 'Ville N/C'} · Statut: ${t.status}', style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Get.toNamed(AppRoutes.superAdminDetail, arguments: t.id),
            )).toList(),
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
        if (recent.users.isNotEmpty) ...[
          _SubActivityCard(
            title: 'Derniers utilisateurs enregistrés',
            items: recent.users.map((u) => ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
              title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(u.email, style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Get.toNamed(AppRoutes.superAdminUserDetail, arguments: u.id),
            )).toList(),
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
        if (recent.parcels.isNotEmpty) ...[
          _SubActivityCard(
            title: 'Derniers colis enregistrés',
            items: recent.parcels.map((p) => ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 14, child: Icon(Icons.inventory_2, size: 16)),
              title: Text(p.trackingCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${p.description ?? 'Colis'} · Statut: ${p.status}', style: const TextStyle(fontSize: 11)),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

class _SubActivityCard extends StatelessWidget {
  const _SubActivityCard({required this.title, required this.items});

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const Divider(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composants génériques
// ---------------------------------------------------------------------------

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Card(
        elevation: 1,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radius)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  Icon(icon, size: 20, color: iconColor),
                ],
              ),
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: iconColor),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatMiniBlock extends StatelessWidget {
  const _StatMiniBlock({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
