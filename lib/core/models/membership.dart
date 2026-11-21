class Membership {
  const Membership({
    required this.tenantId,
    required this.tenantName,
    required this.tenantCode,
    required this.role,
    required this.roleLabel,
    this.agencyId,
    required this.status,
  });

  final String tenantId;
  final String tenantName;
  final String tenantCode;
  final String role;
  final String roleLabel;
  final String? agencyId;
  final String status;

  bool get isActive => status == 'ACTIVE';

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String,
      tenantCode: json['tenantCode'] as String,
      role: json['role'] as String,
      roleLabel: json['roleLabel'] as String,
      agencyId: json['agencyId'] as String?,
      status: json['status'] as String,
    );
  }
}