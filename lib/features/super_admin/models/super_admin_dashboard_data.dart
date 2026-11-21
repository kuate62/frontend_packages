class DashboardTenants {
  const DashboardTenants({
    required this.total,
    required this.active,
    required this.suspended,
  });

  final int total;
  final int active;
  final int suspended;

  factory DashboardTenants.fromJson(Map<String, dynamic> json) {
    return DashboardTenants(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      suspended: (json['suspended'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardUsers {
  const DashboardUsers({
    required this.total,
    required this.active,
    required this.suspended,
    required this.pending,
  });

  final int total;
  final int active;
  final int suspended;
  final int pending;

  factory DashboardUsers.fromJson(Map<String, dynamic> json) {
    return DashboardUsers(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      suspended: (json['suspended'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardParcels {
  const DashboardParcels({
    required this.total,
    required this.byStatus,
  });

  final int total;
  final Map<String, int> byStatus;

  factory DashboardParcels.fromJson(Map<String, dynamic> json) {
    final rawByStatus = json['byStatus'] as Map<String, dynamic>? ?? {};
    final statusMap = <String, int>{};
    rawByStatus.forEach((key, val) {
      statusMap[key] = (val as num?)?.toInt() ?? 0;
    });
    return DashboardParcels(
      total: (json['total'] as num?)?.toInt() ?? 0,
      byStatus: statusMap,
    );
  }
}

class DashboardTrips {
  const DashboardTrips({
    required this.total,
    required this.byStatus,
  });

  final int total;
  final Map<String, int> byStatus;

  factory DashboardTrips.fromJson(Map<String, dynamic> json) {
    final rawByStatus = json['byStatus'] as Map<String, dynamic>? ?? {};
    final statusMap = <String, int>{};
    rawByStatus.forEach((key, val) {
      statusMap[key] = (val as num?)?.toInt() ?? 0;
    });
    return DashboardTrips(
      total: (json['total'] as num?)?.toInt() ?? 0,
      byStatus: statusMap,
    );
  }
}

class PaymentModeStats {
  const PaymentModeStats({
    required this.count,
    required this.amount,
  });

  final int count;
  final double amount;

  factory PaymentModeStats.fromJson(Map<String, dynamic> json) {
    return PaymentModeStats(
      count: (json['count'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardPayments {
  const DashboardPayments({
    required this.total,
    required this.totalAmount,
    required this.currency,
    required this.byMode,
    required this.note,
  });

  final int total;
  final double totalAmount;
  final String currency;
  final Map<String, PaymentModeStats> byMode;
  final String note;

  factory DashboardPayments.fromJson(Map<String, dynamic> json) {
    final rawByMode = json['byMode'] as Map<String, dynamic>? ?? {};
    final modeMap = <String, PaymentModeStats>{};
    rawByMode.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        modeMap[key] = PaymentModeStats.fromJson(val);
      }
    });
    return DashboardPayments(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'XAF',
      byMode: modeMap,
      note: json['note'] as String? ?? '',
    );
  }
}

class RecentTenantItem {
  const RecentTenantItem({
    required this.id,
    required this.name,
    this.code,
    this.city,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? code;
  final String? city;
  final String status;
  final String? createdAt;

  factory RecentTenantItem.fromJson(Map<String, dynamic> json) {
    return RecentTenantItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      city: json['city'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] as String?,
    );
  }
}

class RecentUserItem {
  const RecentUserItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String status;
  final String? createdAt;

  String get fullName => '$firstName $lastName'.trim();

  factory RecentUserItem.fromJson(Map<String, dynamic> json) {
    return RecentUserItem(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] as String?,
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

class DashboardRecentActivity {
  const DashboardRecentActivity({
    this.tenants = const [],
    this.users = const [],
    this.parcels = const [],
  });

  final List<RecentTenantItem> tenants;
  final List<RecentUserItem> users;
  final List<RecentParcelItem> parcels;

  factory DashboardRecentActivity.fromJson(Map<String, dynamic> json) {
    final rawTenants = json['tenants'] as List<dynamic>? ?? [];
    final rawUsers = json['users'] as List<dynamic>? ?? [];
    final rawParcels = json['parcels'] as List<dynamic>? ?? [];

    return DashboardRecentActivity(
      tenants: rawTenants
          .map((e) => RecentTenantItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: rawUsers
          .map((e) => RecentUserItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      parcels: rawParcels
          .map((e) => RecentParcelItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Modèle du tableau de bord général Super Administrateur.
class SuperAdminDashboardData {
  const SuperAdminDashboardData({
    required this.tenants,
    required this.users,
    required this.agenciesTotal,
    required this.parcels,
    required this.trips,
    required this.payments,
    required this.recent,
  });

  final DashboardTenants tenants;
  final DashboardUsers users;
  final int agenciesTotal;
  final DashboardParcels parcels;
  final DashboardTrips trips;
  final DashboardPayments payments;
  final DashboardRecentActivity recent;

  bool get isEmpty =>
      tenants.total == 0 &&
      users.total == 0 &&
      parcels.total == 0 &&
      trips.total == 0;

  factory SuperAdminDashboardData.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardData(
      tenants: DashboardTenants.fromJson(
        json['tenants'] as Map<String, dynamic>? ?? {},
      ),
      users: DashboardUsers.fromJson(
        json['users'] as Map<String, dynamic>? ?? {},
      ),
      agenciesTotal:
          (json['agencies']?['total'] as num?)?.toInt() ?? 0,
      parcels: DashboardParcels.fromJson(
        json['parcels'] as Map<String, dynamic>? ?? {},
      ),
      trips: DashboardTrips.fromJson(
        json['trips'] as Map<String, dynamic>? ?? {},
      ),
      payments: DashboardPayments.fromJson(
        json['payments'] as Map<String, dynamic>? ?? {},
      ),
      recent: DashboardRecentActivity.fromJson(
        json['recent'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
