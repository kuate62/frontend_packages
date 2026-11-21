class CompanyInfo {
  const CompanyInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.totalAgencies,
    required this.totalAgents,
    required this.totalCustomers,
    required this.totalParcels,
    required this.totalTrips,
  });

  final String id;
  final String name;
  final String code;
  final String status;
  final int totalAgencies;
  final int totalAgents;
  final int totalCustomers;
  final int totalParcels;
  final int totalTrips;

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      totalAgencies: (json['totalAgencies'] as num?)?.toInt() ?? 0,
      totalAgents: (json['totalAgents'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      totalParcels: (json['totalParcels'] as num?)?.toInt() ?? 0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
    );
  }
}

class CompanyParcelsStats {
  const CompanyParcelsStats({
    required this.created,
    required this.total,
    required this.currentByStatus,
    required this.withIncidents,
  });

  final int created;
  final int total;
  final Map<String, int> currentByStatus;
  final int withIncidents;

  factory CompanyParcelsStats.fromJson(Map<String, dynamic> json) {
    final rawByStatus = json['currentByStatus'] as Map<String, dynamic>? ?? {};
    final statusMap = <String, int>{};
    rawByStatus.forEach((key, val) {
      statusMap[key] = (val as num?)?.toInt() ?? 0;
    });
    return CompanyParcelsStats(
      created: (json['created'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      currentByStatus: statusMap,
      withIncidents: (json['withIncidents'] as num?)?.toInt() ?? 0,
    );
  }
}

class CompanyTransportStats {
  const CompanyTransportStats({
    required this.tripsCreated,
    required this.total,
    required this.tripsByStatus,
    required this.vehiclesByStatus,
    required this.activeVehicles,
  });

  final int tripsCreated;
  final int total;
  final Map<String, int> tripsByStatus;
  final Map<String, int> vehiclesByStatus;
  final int activeVehicles;

  factory CompanyTransportStats.fromJson(Map<String, dynamic> json) {
    final rawTripsByStatus = json['tripsByStatus'] as Map<String, dynamic>? ?? {};
    final tripMap = <String, int>{};
    rawTripsByStatus.forEach((key, val) {
      tripMap[key] = (val as num?)?.toInt() ?? 0;
    });

    final rawVehByStatus = json['vehiclesByStatus'] as Map<String, dynamic>? ?? {};
    final vehMap = <String, int>{};
    rawVehByStatus.forEach((key, val) {
      vehMap[key] = (val as num?)?.toInt() ?? 0;
    });

    return CompanyTransportStats(
      tripsCreated: (json['tripsCreated'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      tripsByStatus: tripMap,
      vehiclesByStatus: vehMap,
      activeVehicles: (json['activeVehicles'] as num?)?.toInt() ?? 0,
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

class CompanyFinancialStats {
  const CompanyFinancialStats({
    required this.byCurrency,
    required this.byMode,
    required this.note,
  });

  final Map<String, FinancialCurrencyStats> byCurrency;
  final Map<String, FinancialModeStats> byMode;
  final String note;

  factory CompanyFinancialStats.fromJson(Map<String, dynamic> json) {
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

    return CompanyFinancialStats(
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

class RecentTripItem {
  const RecentTripItem({
    required this.id,
    required this.status,
    this.plannedDepartureAt,
    this.createdAt,
  });

  final String id;
  final String status;
  final String? plannedDepartureAt;
  final String? createdAt;

  factory RecentTripItem.fromJson(Map<String, dynamic> json) {
    return RecentTripItem(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      plannedDepartureAt: json['plannedDepartureAt'] as String?,
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

class CompanyRecentActivity {
  const CompanyRecentActivity({
    this.parcels = const [],
    this.trips = const [],
    this.payments = const [],
  });

  final List<RecentParcelItem> parcels;
  final List<RecentTripItem> trips;
  final List<RecentPaymentItem> payments;

  factory CompanyRecentActivity.fromJson(Map<String, dynamic> json) {
    final rawParcels = json['parcels'] as List<dynamic>? ?? [];
    final rawTrips = json['trips'] as List<dynamic>? ?? [];
    final rawPayments = json['payments'] as List<dynamic>? ?? [];

    return CompanyRecentActivity(
      parcels: rawParcels
          .map((e) => RecentParcelItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      trips: rawTrips
          .map((e) => RecentTripItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: rawPayments
          .map((e) => RecentPaymentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Modèle complet du tableau de bord de l'administrateur d'entreprise.
class CompanyDashboardData {
  const CompanyDashboardData({
    required this.company,
    required this.parcels,
    required this.transport,
    required this.financial,
    required this.recent,
  });

  final CompanyInfo company;
  final CompanyParcelsStats parcels;
  final CompanyTransportStats transport;
  final CompanyFinancialStats financial;
  final CompanyRecentActivity recent;

  bool get isEmpty =>
      company.totalParcels == 0 &&
      company.totalTrips == 0 &&
      company.totalAgencies == 0;

  factory CompanyDashboardData.fromJson(Map<String, dynamic> json) {
    return CompanyDashboardData(
      company: CompanyInfo.fromJson(
        json['company'] as Map<String, dynamic>? ?? {},
      ),
      parcels: CompanyParcelsStats.fromJson(
        json['parcels'] as Map<String, dynamic>? ?? {},
      ),
      transport: CompanyTransportStats.fromJson(
        json['transport'] as Map<String, dynamic>? ?? {},
      ),
      financial: CompanyFinancialStats.fromJson(
        json['financial'] as Map<String, dynamic>? ?? {},
      ),
      recent: CompanyRecentActivity.fromJson(
        json['recent'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
