import '../models/membership.dart';

enum UserContextType {
  platform,
  clientPlatform,
  singleMembership,
  multipleMemberships,
  unauthenticated,
}

class UserContext {
  const UserContext({
    required this.type,
    this.tenantId,
    this.agencyId,
    this.role,
    this.memberships = const <Membership>[],
  });

  final UserContextType type;
  final String? tenantId;
  final String? agencyId;
  final String? role;
  final List<Membership> memberships;
}