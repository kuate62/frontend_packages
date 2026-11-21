import '../../../core/models/membership.dart';

class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.status,
    required this.isPlatformAdmin,
    required this.memberships,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String status;
  final bool isPlatformAdmin;
  final List<Membership> memberships;

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'status': status,
      'isPlatformAdmin': isPlatformAdmin,
      'memberships': memberships
          .map((membership) => <String, dynamic>{
                'tenantId': membership.tenantId,
                'tenantName': membership.tenantName,
                'tenantCode': membership.tenantCode,
                'role': membership.role,
                'roleLabel': membership.roleLabel,
                'agencyId': membership.agencyId,
                'status': membership.status,
              })
          .toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final memberships = (json['memberships'] as List<dynamic>? ?? const [])
        .map((item) => Membership.fromJson(item as Map<String, dynamic>))
        .toList();
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      isPlatformAdmin: json['isPlatformAdmin'] as bool? ?? false,
      memberships: memberships,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    required this.user,
  });

  final String tokenType;
  final String accessToken;
  final String expiresIn;
  final String? refreshToken;
  final String? refreshTokenExpiresAt;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      tokenType: json['tokenType'] as String,
      accessToken: json['accessToken'] as String,
      expiresIn: json['expiresIn'] as String,
      refreshToken: json['refreshToken'] as String?,
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}