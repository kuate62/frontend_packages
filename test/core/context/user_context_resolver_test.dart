import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/context/user_context.dart';
import 'package:frontend_packages/core/context/user_context_resolver.dart';

void main() {
  const resolver = UserContextResolver();

  test('résout un super administrateur sans appartenance', () {
    final context = resolver.resolve(<String, dynamic>{
      'isPlatformAdmin': true,
      'memberships': <Map<String, dynamic>>[],
    });

    expect(context.type, UserContextType.platform);
  });

  test('résout un client sans membership', () {
    final context = resolver.resolve(<String, dynamic>{
      'isPlatformAdmin': false,
      'memberships': <Map<String, dynamic>>[],
    });

    expect(context.type, UserContextType.clientPlatform);
  });

  test('résout une appartenance unique', () {
    final context = resolver.resolve(<String, dynamic>{
      'isPlatformAdmin': false,
      'memberships': <Map<String, dynamic>>[
        <String, dynamic>{
          'tenantId': 't1',
          'tenantName': 'Tenant 1',
          'tenantCode': 'T1',
          'role': 'AGENT',
          'roleLabel': 'Agent',
          'agencyId': 'a1',
          'status': 'ACTIVE',
        },
      ],
    });

    expect(context.type, UserContextType.singleMembership);
    expect(context.tenantId, 't1');
    expect(context.agencyId, 'a1');
  });

  test('détecte plusieurs appartenances actives', () {
    final context = resolver.resolve(<String, dynamic>{
      'isPlatformAdmin': false,
      'memberships': <Map<String, dynamic>>[
        <String, dynamic>{
          'tenantId': 't1',
          'tenantName': 'Tenant 1',
          'tenantCode': 'T1',
          'role': 'AGENT',
          'roleLabel': 'Agent',
          'agencyId': 'a1',
          'status': 'ACTIVE',
        },
        <String, dynamic>{
          'tenantId': 't2',
          'tenantName': 'Tenant 2',
          'tenantCode': 'T2',
          'role': 'CLIENT',
          'roleLabel': 'Client',
          'agencyId': null,
          'status': 'ACTIVE',
        },
      ],
    });

    expect(context.type, UserContextType.multipleMemberships);
    expect(context.memberships.length, 2);
  });
}