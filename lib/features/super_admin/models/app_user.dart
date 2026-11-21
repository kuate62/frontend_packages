/// Modèle d'adhésion d'un utilisateur à un tenant.
class AppUserMembership {
  const AppUserMembership({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    this.tenantCode,
    required this.role,
    this.roleLabel,
    this.agencyId,
    this.agencyName,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String tenantId;
  final String tenantName;
  final String? tenantCode;
  final String role;
  final String? roleLabel;
  final String? agencyId;
  final String? agencyName;
  final String status;
  final String? createdAt;

  factory AppUserMembership.fromJson(Map<String, dynamic> json) {
    return AppUserMembership(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      tenantCode: json['tenantCode'] as String?,
      role: json['role'] as String? ?? '',
      roleLabel: json['roleLabel'] as String?,
      agencyId: json['agencyId'] as String?,
      agencyName: json['agencyName'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] as String?,
    );
  }
}

/// Modèle utilisateur global (vue SUPER_ADMIN).
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.status,
    required this.isPlatformAdmin,
    this.createdAt,
    this.memberships = const [],
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String status;
  final bool isPlatformAdmin;
  final String? createdAt;
  final List<AppUserMembership> memberships;

  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final rawMemberships = json['memberships'] as List<dynamic>? ?? const [];
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isPlatformAdmin: json['isPlatformAdmin'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      memberships: rawMemberships
          .map((m) => AppUserMembership.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
