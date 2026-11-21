import '../models/membership.dart';
import 'user_context.dart';

class UserContextResolver {
  const UserContextResolver();

  UserContext resolve(Map<String, dynamic> userJson) {
    final isPlatformAdmin = userJson['isPlatformAdmin'] as bool? ?? false;
    final memberships = (userJson['memberships'] as List<dynamic>? ?? const [])
        .map((item) => Membership.fromJson(item as Map<String, dynamic>))
        .where((membership) => membership.isActive)
        .toList();

    if (isPlatformAdmin && memberships.isEmpty) {
      return const UserContext(type: UserContextType.platform);
    }

    if (memberships.length == 1) {
      final membership = memberships.first;
      return UserContext(
        type: UserContextType.singleMembership,
        tenantId: membership.tenantId,
        agencyId: membership.agencyId,
        role: membership.role,
        memberships: memberships,
      );
    }

    if (memberships.length > 1) {
      return UserContext(
        type: UserContextType.multipleMemberships,
        memberships: memberships,
      );
    }

    if (isPlatformAdmin) {
      return const UserContext(type: UserContextType.platform);
    }

    return const UserContext(type: UserContextType.clientPlatform);
  }
}