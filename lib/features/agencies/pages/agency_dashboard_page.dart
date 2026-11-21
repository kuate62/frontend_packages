import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/agency_dashboard_controller.dart';
import '../models/agency_dashboard_data.dart';

/// Tableau de bord opérationnel pour le Responsable d'Agence (AGENCY_MANAGER - V1-12).
class AgencyDashboardPage extends GetView<AgencyDashboardController> {
  const AgencyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          final agencyName = controller.dashboardData.value?.agency.name;
          if (agencyName != null && agencyName.isNotEmpty) {
            return Text(agencyName, key: const Key('agency_name_appbar'));
          }
          return const Text('Tableau de bord Agence');
        }),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            key: const Key('agency_refresh_btn'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.refresh,
          ),
          IconButton(
            key: const Key('agency_logout_btn'),
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await auth.logout();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.dashboardData.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              key: Key('agency_loading_indicator'),
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
                    key: const Key('agency_retry_btn'),
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
                const Icon(Icons.storefront_outlined, size: 48, color: AppColors.textDisabled),
                const SizedBox(height: AppDimensions.sm),
                const Text('Aucune activité enregistrée pour cette agence.'),
                const SizedBox(height: AppDimensions.md),
                ElevatedButton(
                  onPressed: controller.refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              _buildAgencyHeader(data.agency),
              const SizedBox(height: AppDimensions.md),
              _buildKpiGrid(data),
              const SizedBox(height: AppDimensions.lg),
              _buildParcelsSection(data.parcels),
              const SizedBox(height: AppDimensions.lg),
              _buildFinancialSection(data.financial),
              const SizedBox(height: AppDimensions.lg),
              _buildAgentsSection(data.agency),
              const SizedBox(height: AppDimensions.lg),
              _buildRecentActivitySection(data.recent),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAgencyHeader(AgencyScopeInfo agency) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront, color: AppColors.onPrimary, size: 32),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agency.name,
                  key: const Key('agency_header_name'),
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${agency.code} • Ville: ${agency.city}',
                  style: TextStyle(
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              agency.status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(AgencyDashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.md,
      mainAxisSpacing: AppDimensions.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _KpiCard(
          icon: Icons.inventory_2,
          iconColor: AppColors.primary,
          label: 'Total Colis',
          value: '${data.parcels.total}',
          keyPrefix: 'kpi_parcels',
        ),
        _KpiCard(
          icon: Icons.badge,
          iconColor: AppColors.secondary,
          label: 'Agents Actifs',
          value: '${data.agency.totalAgents}',
          keyPrefix: 'kpi_agents',
        ),
      ],
    );
  }

  Widget _buildParcelsSection(AgencyParcelsStats parcels) {
    final statusList = [
      {'key': 'REGISTERED', 'label': 'Enregistrés', 'color': AppColors.info},
      {'key': 'WAITING_FOR_TRANSPORT', 'label': 'En attente départ', 'color': AppColors.warning},
      {'key': 'LOADED', 'label': 'Chargés', 'color': AppColors.accent},
      {'key': 'IN_TRANSIT', 'label': 'En transit', 'color': AppColors.primary},
      {'key': 'ARRIVED', 'label': 'Arrivés en agence', 'color': AppColors.info},
      {'key': 'READY_FOR_PICKUP', 'label': 'Prêts au retrait', 'color': AppColors.secondary},
      {'key': 'OUT_FOR_DELIVERY', 'label': 'En livraison', 'color': AppColors.accent},
      {'key': 'DELIVERED', 'label': 'Livrés', 'color': AppColors.success},
      {'key': 'CANCELLED', 'label': 'Annulés', 'color': AppColors.danger},
      {'key': 'RETURN_TO_SENDER', 'label': 'Retournés', 'color': AppColors.danger},
    ];

    return _SectionCard(
      title: 'Suivi des Colis',
      icon: Icons.local_shipping,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total colis gérés: ${parcels.total}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              if (parcels.withIncidents > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, size: 14, color: AppColors.danger),
                      const SizedBox(width: 4),
                      Text(
                        '${parcels.withIncidents} incident(s)',
                        style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          const Divider(),
          const SizedBox(height: AppDimensions.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusList.map((item) {
              final statusKey = item['key'] as String;
              final label = item['label'] as String;
              final color = item['color'] as Color;
              final count = parcels.currentByStatus[statusKey] ?? 0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$label: ',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '$count',
                      key: Key('agency_parcel_status_$statusKey'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: count > 0 ? color : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSection(AgencyFinancialStats financial) {
    return _SectionCard(
      title: 'Paiements au Guichet (V1)',
      icon: Icons.payments,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (financial.byCurrency.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Aucun paiement enregistré pour cette période.',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
              ),
            )
          else
            ...financial.byCurrency.entries.map((e) {
              final cur = e.key;
              final stats = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net encaissé ($cur)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${stats.net.toStringAsFixed(0)} $cur',
                          key: Key('agency_net_$cur'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paiements (${stats.paymentCount}): +${stats.payments.toStringAsFixed(0)} $cur',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (stats.refunds > 0)
                          Text(
                            'Remboursements (${stats.refundCount}): -${stats.refunds.toStringAsFixed(0)} $cur',
                            style: const TextStyle(fontSize: 12, color: AppColors.danger),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          if (financial.byMode.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.xs),
            const Text(
              'Répartition par mode de paiement :',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: financial.byMode.entries.map((e) {
                return Chip(
                  label: Text(
                    '${e.key}: ${e.value.amount.toStringAsFixed(0)} (${e.value.count})',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            financial.note.isNotEmpty
                ? financial.note
                : 'Paiements enregistrés dans la plateforme (guichet V1). Ne constitue pas un chiffre d\'affaires comptable.',
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsSection(AgencyScopeInfo agency) {
    return _SectionCard(
      title: 'Agents de l\'Agence (${agency.agents.length})',
      icon: Icons.people,
      child: agency.agents.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Aucun agent actif rattaché à cette agence.',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: agency.agents.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final agent = agency.agents[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      agent.firstName.isNotEmpty ? agent.firstName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  title: Text(
                    agent.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  subtitle: Text(
                    '${agent.roleLabel} • ${agent.email}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${agent.parcelsCount} colis',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRecentActivitySection(AgencyRecentActivity recent) {
    return _SectionCard(
      title: 'Activité Récente',
      icon: Icons.history,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Derniers Colis',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          if (recent.parcels.isEmpty)
            const Text(
              'Aucun colis récent.',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 12),
            )
          else
            ...recent.parcels.take(5).map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.trackingCode,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.status,
                          style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: AppDimensions.md),
          const Text(
            'Derniers Paiements',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          if (recent.payments.isEmpty)
            const Text(
              'Aucun paiement récent.',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 12),
            )
          else
            ...recent.payments.take(5).map((pay) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        pay.type == 'REFUND' ? Icons.remove_circle_outline : Icons.add_circle_outline,
                        size: 16,
                        color: pay.type == 'REFUND' ? AppColors.danger : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${pay.type} • ${pay.mode}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '${pay.type == 'REFUND' ? '-' : '+'}${pay.amount.toStringAsFixed(0)} ${pay.currency}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: pay.type == 'REFUND' ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.keyPrefix,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          Text(
            value,
            key: Key('${keyPrefix}_val'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          child,
        ],
      ),
    );
  }
}
