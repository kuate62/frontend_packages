library;

/// Modèles de données pour le tableau de bord de l'AGENCY_MANAGER (V1-12).
/// Correspond exactement au schéma renvoyé par GET /api/v1/dashboard/overview
/// lorsque le scope est restreint à une agence.

class AgentSummary {
  const AgentSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleCode,
    required this.roleLabel,
    required this.status,
    required this.parcelsCount,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String roleCode;
  final String roleLabel;
  final String status;
  final int parcelsCount;

  String get fullName => '$firstName $lastName'.trim();

  factory AgentSummary.fromJson(Map<String, dynamic> json) {
    return AgentSummary(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleCode: json['roleCode'] as String? ?? 'AGENT',
      roleLabel: json['roleLabel'] as String? ?? 'Agent',
      status: json['status'] as String? ?? 'ACTIVE',
      parcelsCount: (json['parcelsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AgencyScopeInfo {
  const AgencyScopeInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.status,
    required this.totalAgents,
    this.agents = const [],
  });

  final String id;
  final String name;
  final String code;
  final String city;
  final String status;
  final int totalAgents;
  final List<AgentSummary> agents;

  factory AgencyScopeInfo.fromJson(Map<String, dynamic> json) {
    final rawAgents = json['agents'] as List<dynamic>? ?? [];
    return AgencyScopeInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      totalAgents: (json['totalAgents'] as num?)?.toInt() ?? 0,
      agents: rawAgents
          .map((e) => AgentSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AgencyParcelsStats {
  const AgencyParcelsStats({
    required this.created,
    required this.total,
    required this.currentByStatus,
    required this.withIncidents,
  });

  final int created;
  final int total;
  final Map<String, int> currentByStatus;
  final int withIncidents;

  factory AgencyParcelsStats.fromJson(Map<String, dynamic> json) {
    final rawByStatus = json['currentByStatus'] as Map<String, dynamic>? ?? {};
    final statusMap = <String, int>{};
    rawByStatus.forEach((key, val) {
      statusMap[key] = (val as num?)?.toInt() ?? 0;
    });
    return AgencyParcelsStats(
      created: (json['created'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      currentByStatus: statusMap,
      withIncidents: (json['withIncidents'] as num?)?.toInt() ?? 0,
    );
  }
}

class FinancialCurrencyStats {
  const FinancialCurrencyStats({
    required this.payments,
    required this.refunds,
    required this.net,
    required this.paymentCount,
    required this.refundCount,
  });

  final double payments;
  final double refunds;
  final double net;
  final int paymentCount;
  final int refundCount;

  factory FinancialCurrencyStats.fromJson(Map<String, dynamic> json) {
    return FinancialCurrencyStats(
      payments: (json['payments'] as num?)?.toDouble() ?? 0.0,
      refunds: (json['refunds'] as num?)?.toDouble() ?? 0.0,
      net: (json['net'] as num?)?.toDouble() ?? 0.0,
      paymentCount: (json['paymentCount'] as num?)?.toInt() ?? 0,
      refundCount: (json['refundCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FinancialModeStats {
  const FinancialModeStats({
    required this.count,
    required this.amount,
  });

  final int count;
  final double amount;

  factory FinancialModeStats.fromJson(Map<String, dynamic> json) {
    return FinancialModeStats(
      count: (json['count'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AgencyFinancialStats {
  const AgencyFinancialStats({
    required this.byCurrency,
    required this.byMode,
    required this.note,
  });

  final Map<String, FinancialCurrencyStats> byCurrency;
  final Map<String, FinancialModeStats> byMode;
  final String note;

  factory AgencyFinancialStats.fromJson(Map<String, dynamic> json) {
    final rawByCur = json['byCurrency'] as Map<String, dynamic>? ?? {};
    final curMap = <String, FinancialCurrencyStats>{};
    rawByCur.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        curMap[key] = FinancialCurrencyStats.fromJson(val);
      }
    });

    final rawByMode = json['byMode'] as Map<String, dynamic>? ?? {};
    final modeMap = <String, FinancialModeStats>{};
    rawByMode.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        modeMap[key] = FinancialModeStats.fromJson(val);
      }
    });

    return AgencyFinancialStats(
      byCurrency: curMap,
      byMode: modeMap,
      note: json['note'] as String? ?? '',
    );
  }
}

class RecentParcelItem {
  const RecentParcelItem({
    required this.id,
    required this.trackingCode,
    required this.status,
    this.description,
    this.createdAt,
  });

  final String id;
  final String trackingCode;
  final String status;
  final String? description;
  final String? createdAt;

  factory RecentParcelItem.fromJson(Map<String, dynamic> json) {
    return RecentParcelItem(
      id: json['id'] as String? ?? '',
      trackingCode: json['trackingCode'] as String? ?? '',
      status: json['status'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class RecentPaymentItem {
  const RecentPaymentItem({
    required this.id,
    required this.type,
    required this.mode,
    required this.amount,
    required this.currency,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String type;
  final String mode;
  final double amount;
  final String currency;
  final String status;
  final String? createdAt;

  factory RecentPaymentItem.fromJson(Map<String, dynamic> json) {
    return RecentPaymentItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'PAYMENT',
      mode: json['mode'] as String? ?? 'CASH',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'XAF',
      status: json['status'] as String? ?? 'CONFIRMED',
      createdAt: json['createdAt'] as String?,
    );
  }
}

class AgencyRecentActivity {
  const AgencyRecentActivity({
    this.parcels = const [],
    this.payments = const [],
  });

  final List<RecentParcelItem> parcels;
  final List<RecentPaymentItem> payments;

  factory AgencyRecentActivity.fromJson(Map<String, dynamic> json) {
    final rawParcels = json['parcels'] as List<dynamic>? ?? [];
    final rawPayments = json['payments'] as List<dynamic>? ?? [];

    return AgencyRecentActivity(
      parcels: rawParcels
          .map((e) => RecentParcelItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: rawPayments
          .map((e) => RecentPaymentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Modèle complet du tableau de bord opérationnel de l'AGENCY_MANAGER.
class AgencyDashboardData {
  const AgencyDashboardData({
    required this.agency,
    required this.parcels,
    required this.financial,
    required this.recent,
  });

  final AgencyScopeInfo agency;
  final AgencyParcelsStats parcels;
  final AgencyFinancialStats financial;
  final AgencyRecentActivity recent;

  bool get isEmpty =>
      agency.totalAgents == 0 &&
      parcels.total == 0 &&
      financial.byCurrency.isEmpty;

  factory AgencyDashboardData.fromJson(Map<String, dynamic> json) {
    return AgencyDashboardData(
      agency: AgencyScopeInfo.fromJson(
        json['agency'] as Map<String, dynamic>? ?? {},
      ),
      parcels: AgencyParcelsStats.fromJson(
        json['parcels'] as Map<String, dynamic>? ?? {},
      ),
      financial: AgencyFinancialStats.fromJson(
        json['financial'] as Map<String, dynamic>? ?? {},
      ),
      recent: AgencyRecentActivity.fromJson(
        json['recent'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
