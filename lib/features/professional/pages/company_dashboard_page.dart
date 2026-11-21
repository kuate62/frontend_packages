import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/company_dashboard_controller.dart';
import '../models/company_dashboard_data.dart';

/// Tableau de bord centralisé pour l'Administrateur d'Entreprise (TENANT_ADMIN).
class CompanyDashboardPage extends GetView<CompanyDashboardController> {
  const CompanyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          final companyName = controller.dashboardData.value?.company.name;
          if (companyName != null && companyName.isNotEmpty) {
            return Text(companyName, key: const Key('company_name_appbar'));
          }
          return const Text('Tableau de bord');
        }),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            key: const Key('company_refresh_btn'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.refresh,
          ),
          IconButton(
            key: const Key('company_logout_btn'),
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
              key: Key('company_loading_indicator'),
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
                    key: const Key('company_retry_btn'),
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
                const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textDisabled),
                const SizedBox(height: AppDimensions.sm),
                const Text('Aucune activité enregistrée pour cette entreprise.'),
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
                // 1. En-tête de bienvenue de l'entreprise
                _CompanyHeader(company: data.company),

                const SizedBox(height: AppDimensions.md),

                // 2. Vue générale (Agences, Agents, Clients, Colis, Trajets)
                const _SectionTitle(title: 'Vue d\'ensemble de l\'entreprise', icon: Icons.domain),
                const SizedBox(height: AppDimensions.xs),
                _GeneralOverviewGrid(company: data.company),

                const SizedBox(height: AppDimensions.lg),

                // 3. Suivi des colis
                const _SectionTitle(title: 'Suivi opérationnel des colis', icon: Icons.local_shipping),
                const SizedBox(height: AppDimensions.xs),
                _ParcelsOverviewCard(parcels: data.parcels),

                const SizedBox(height: AppDimensions.lg),

                // 4. Suivi des trajets
                const _SectionTitle(title: 'Suivi des trajets inter-agences', icon: Icons.alt_route),
                const SizedBox(height: AppDimensions.xs),
                _TripsOverviewCard(transport: data.transport),

                const SizedBox(height: AppDimensions.lg),

                // 5. Suivi financier guichet V1
                const _SectionTitle(title: 'Encaissements guichet (V1)', icon: Icons.account_balance_wallet),
                const SizedBox(height: AppDimensions.xs),
                _CompanyFinancialCard(financial: data.financial),

                const SizedBox(height: AppDimensions.lg),

                // 6. Activité récente
                const _SectionTitle(title: 'Activité récente', icon: Icons.history),
                const SizedBox(height: AppDimensions.xs),
                _CompanyRecentActivitySection(recent: data.recent),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : En-tête d'entreprise
// ---------------------------------------------------------------------------

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({required this.company});

  final CompanyInfo company;

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.business_center, color: AppColors.onPrimary, size: 28),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Code : ${company.code} · Statut : ${company.status}',
                  style: const TextStyle(
                    color: AppColors.surfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : Titre de section
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

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
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : Grille générale
// ---------------------------------------------------------------------------

class _GeneralOverviewGrid extends StatelessWidget {
  const _GeneralOverviewGrid({required this.company});

  final CompanyInfo company;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > AppDimensions.breakpointTablet ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.sm,
          mainAxisSpacing: AppDimensions.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _MiniKpi(
              label: 'Agences',
              value: '${company.totalAgencies}',
              icon: Icons.storefront,
              color: AppColors.primary,
            ),
            _MiniKpi(
              label: 'Agents actifs',
              value: '${company.totalAgents}',
              icon: Icons.badge,
              color: AppColors.accent,
            ),
            _MiniKpi(
              label: 'Clients inscrits',
              value: '${company.totalCustomers}',
              icon: Icons.groups,
              color: AppColors.secondary,
            ),
            _MiniKpi(
              label: 'Total Colis',
              value: '${company.totalParcels}',
              icon: Icons.inventory_2,
              color: AppColors.primaryDark,
            ),
          ],
        );
      },
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : Suivi des Colis
// ---------------------------------------------------------------------------

class _ParcelsOverviewCard extends StatelessWidget {
  const _ParcelsOverviewCard({required this.parcels});

  final CompanyParcelsStats parcels;

  @override
  Widget build(BuildContext context) {
    final s = parcels.currentByStatus;

    final waiting = (s['REGISTERED'] ?? 0) + (s['WAITING_FOR_TRANSPORT'] ?? 0);
    final inTransit = (s['LOADED'] ?? 0) + (s['IN_TRANSIT'] ?? 0);
    final arrived = (s['ARRIVED'] ?? 0) + (s['READY_FOR_PICKUP'] ?? 0);
    final outForDelivery = s['OUT_FOR_DELIVERY'] ?? 0;
    final delivered = s['DELIVERED'] ?? 0;
    final cancelled = s['CANCELLED'] ?? 0;
    final returned = s['RETURN_TO_SENDER'] ?? 0;

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
                Text(
                  'Total : ${parcels.total} colis',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                if (parcels.withIncidents > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${parcels.withIncidents} incident(s)',
                      style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const Divider(height: AppDimensions.lg),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.xs,
              children: [
                _StatusBadge(label: 'En attente', count: waiting, color: AppColors.warning),
                _StatusBadge(label: 'En transit', count: inTransit, color: AppColors.info),
                _StatusBadge(label: 'Arrivés/À retirer', count: arrived, color: AppColors.accentDark),
                if (outForDelivery > 0)
                  _StatusBadge(label: 'En livraison', count: outForDelivery, color: AppColors.accent),
                _StatusBadge(label: 'Livrés', count: delivered, color: AppColors.success),
                if (cancelled > 0)
                  _StatusBadge(label: 'Annulés', count: cancelled, color: AppColors.textDisabled),
                if (returned > 0)
                  _StatusBadge(label: 'Retournés', count: returned, color: AppColors.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : Suivi des Trajets
// ---------------------------------------------------------------------------

class _TripsOverviewCard extends StatelessWidget {
  const _TripsOverviewCard({required this.transport});

  final CompanyTransportStats transport;

  @override
  Widget build(BuildContext context) {
    final ts = transport.tripsByStatus;
    final planned = ts['PLANNED'] ?? 0;
    final ready = ts['READY_FOR_DEPARTURE'] ?? 0;
    final inTransit = ts['IN_TRANSIT'] ?? 0;
    final arrived = ts['ARRIVED'] ?? 0;
    final cancelled = ts['CANCELLED'] ?? 0;

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
                Text(
                  'Total : ${transport.total} trajet(s)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
                Text(
                  '${transport.activeVehicles} véhicule(s) actif(s)',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: AppDimensions.lg),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.xs,
              children: [
                _StatusBadge(label: 'Planifiés', count: planned, color: AppColors.info),
                _StatusBadge(label: 'Prêts au départ', count: ready, color: AppColors.warning),
                _StatusBadge(label: 'En cours', count: inTransit, color: AppColors.secondary),
                _StatusBadge(label: 'Arrivés', count: arrived, color: AppColors.success),
                if (cancelled > 0)
                  _StatusBadge(label: 'Annulés', count: cancelled, color: AppColors.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : Suivi Financier
// ---------------------------------------------------------------------------

class _CompanyFinancialCard extends StatelessWidget {
  const _CompanyFinancialCard({required this.financial});

  final CompanyFinancialStats financial;

  @override
  Widget build(BuildContext context) {
    final xafStats = financial.byCurrency['XAF'] ??
        (financial.byCurrency.isNotEmpty ? financial.byCurrency.values.first : null);

    final netAmount = xafStats?.net ?? 0.0;
    final paymentsAmount = xafStats?.payments ?? 0.0;
    final refundsAmount = xafStats?.refunds ?? 0.0;
    final totalOps = (xafStats?.paymentCount ?? 0) + (xafStats?.refundCount ?? 0);

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
                    const Text('Encaissements nets (Guichet)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      '${netAmount.toStringAsFixed(0)} XAF',
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
                    '$totalOps opération(s)',
                    style: const TextStyle(color: AppColors.secondaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (refundsAmount > 0) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Paiements : ${paymentsAmount.toStringAsFixed(0)} XAF · Remboursements : ${refundsAmount.toStringAsFixed(0)} XAF',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
            if (financial.byMode.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.sm),
              const Divider(),
              const Text('Répartition par moyen de paiement :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...financial.byMode.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        '${entry.value.count} op. (${entry.value.amount.toStringAsFixed(0)} XAF)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: AppDimensions.xs),
            Text(
              financial.note,
              style: const TextStyle(fontSize: 10, color: AppColors.textDisabled, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composant : Activité Récente de l'Entreprise
// ---------------------------------------------------------------------------

class _CompanyRecentActivitySection extends StatelessWidget {
  const _CompanyRecentActivitySection({required this.recent});

  final CompanyRecentActivity recent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (recent.parcels.isNotEmpty) ...[
          _RecentCard(
            title: 'Derniers colis enregistrés',
            items: recent.parcels.map((p) => ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 14, child: Icon(Icons.inventory_2, size: 16)),
              title: Text(p.trackingCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${p.description ?? 'Colis'} · Statut: ${p.status}', style: const TextStyle(fontSize: 11)),
            )).toList(),
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
        if (recent.trips.isNotEmpty) ...[
          _RecentCard(
            title: 'Derniers trajets planifiés',
            items: recent.trips.map((t) => ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 14, child: Icon(Icons.directions_bus, size: 16)),
              title: Text('Trajet #${t.id.substring(t.id.length - 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Statut : ${t.status}', style: const TextStyle(fontSize: 11)),
            )).toList(),
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
        if (recent.payments.isNotEmpty) ...[
          _RecentCard(
            title: 'Derniers paiements enregistrés',
            items: recent.payments.map((pay) => ListTile(
              dense: true,
              leading: const CircleAvatar(radius: 14, child: Icon(Icons.payment, size: 16)),
              title: Text('${pay.amount.toStringAsFixed(0)} ${pay.currency} (${pay.mode})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Type : ${pay.type} · Statut : ${pay.status}', style: const TextStyle(fontSize: 11)),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.title, required this.items});

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
