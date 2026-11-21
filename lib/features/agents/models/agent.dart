class Agent {
  const Agent({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.status,
    this.role,
    this.roleLabel,
    this.agencyId,
    this.membershipId,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String status;
  final String? role;
  final String? roleLabel;
  final String? agencyId;
  final String? membershipId;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  bool get isActive => status == 'ACTIVE';

  factory Agent.fromJson(Map<String, dynamic> json) {
    final memberships = json['memberships'] as List<dynamic>? ?? const [];
    final membership = memberships.isNotEmpty ? memberships.first as Map<String, dynamic> : null;
    return Agent(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      role: membership?['role'] as String?,
      roleLabel: membership?['roleLabel'] as String?,
      agencyId: membership?['agencyId'] as String?,
      membershipId: membership?['id'] as String?,
    );
  }
}