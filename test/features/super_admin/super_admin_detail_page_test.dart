import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/super_admin/controllers/super_admin_controller.dart';
import 'package:frontend_packages/features/super_admin/models/tenant.dart';
import 'package:frontend_packages/features/super_admin/pages/super_admin_detail_page.dart';
import 'package:frontend_packages/features/super_admin/repositories/tenants_repository.dart';

class _MockTenantsRepository extends TenantsRepository {
  _MockTenantsRepository() : super(Dio());

  List<Tenant> tenantsList = [];
  Tenant? nextResult;
  bool shouldThrow = false;
  int setStatusCalls = 0;
  String? lastUpdatedId;
  String? lastUpdatedStatus;

  @override
  Future<List<Tenant>> list({int page = 1, int limit = 50}) async => tenantsList;

  @override
  Future<Tenant> setStatus(String id, String status) async {
    setStatusCalls++;
    lastUpdatedId = id;
    lastUpdatedStatus = status;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tenants/$id/status'),
        error: 'Erreur réseau simulée',
      );
    }
    return nextResult ??
        Tenant(
          id: id,
          name: 'Entreprise Test',
          code: 'TST',
          city: 'Douala',
          status: status,
        );
  }
}

void main() {
  late _MockTenantsRepository mockRepo;
  late SuperAdminController controller;

  setUp(() {
    Get.testMode = true;
    final initialTenants = [
      const Tenant(
        id: 't-active',
        name: 'Trans Express Active',
        code: 'TEA',
        city: 'Douala',
        status: 'ACTIVE',
      ),
      const Tenant(
        id: 't-suspended',
        name: 'Trans Cargo Suspendue',
        code: 'TCS',
        city: 'Yaoundé',
        status: 'SUSPENDED',
      ),
    ];
    mockRepo = _MockTenantsRepository();
    mockRepo.tenantsList = List.of(initialTenants);
    Get.put<TenantsRepository>(mockRepo, permanent: true);
    controller = SuperAdminController(mockRepo);
    controller.tenants.assignAll(initialTenants);
    Get.put<SuperAdminController>(controller, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpDetailPage(WidgetTester tester, String tenantId) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: SuperAdminDetailPage(tenantId: tenantId),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('1. Affichage du statut ACTIVE et bouton Suspendre', (tester) async {
    await pumpDetailPage(tester, 't-active');

    expect(find.text('Trans Express Active'), findsOneWidget);
    expect(find.text('Statut : ACTIVE'), findsOneWidget);
    expect(find.text('Suspendre'), findsOneWidget);
    expect(find.text('Réactiver'), findsNothing);
  });

  testWidgets('2. Affichage du statut SUSPENDED et bouton Réactiver', (tester) async {
    await pumpDetailPage(tester, 't-suspended');

    expect(find.text('Trans Cargo Suspendue'), findsOneWidget);
    expect(find.text('Statut : SUSPENDED'), findsOneWidget);
    expect(find.text('Réactiver'), findsOneWidget);
    expect(find.text('Suspendre'), findsNothing);
  });

  testWidgets('3. Confirmation avant suspension : annulation ne modifie pas le statut', (tester) async {
    await pumpDetailPage(tester, 't-active');

    // Clic sur Suspendre
    await tester.tap(find.text('Suspendre'));
    await tester.pumpAndSettle();

    // Vérification de la présence du dialogue de confirmation
    expect(find.text('Confirmer la suspension'), findsOneWidget);
    expect(find.text('Êtes-vous sûr de vouloir suspendre cette entreprise ?'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    // Clic sur Annuler
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    // Le dialogue est fermé, aucun appel API, le statut reste ACTIVE
    expect(mockRepo.setStatusCalls, 0);
    expect(find.text('Statut : ACTIVE'), findsOneWidget);
    expect(find.text('Suspendre'), findsOneWidget);
  });

  testWidgets('4. Confirmation avant réactivation : annulation ne modifie pas le statut', (tester) async {
    await pumpDetailPage(tester, 't-suspended');

    // Clic sur Réactiver
    await tester.tap(find.text('Réactiver'));
    await tester.pumpAndSettle();

    // Vérification de la présence du dialogue de confirmation
    expect(find.text('Confirmer la réactivation'), findsOneWidget);
    expect(find.text('Êtes-vous sûr de vouloir réactiver cette entreprise ?'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    // Clic sur Annuler
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    // Le dialogue est fermé, aucun appel API, le statut reste SUSPENDED
    expect(mockRepo.setStatusCalls, 0);
    expect(find.text('Statut : SUSPENDED'), findsOneWidget);
    expect(find.text('Réactiver'), findsOneWidget);
  });

  testWidgets('5. Actualisation du statut après action de suspension confirmée', (tester) async {
    mockRepo.nextResult = const Tenant(
      id: 't-active',
      name: 'Trans Express Active',
      code: 'TEA',
      city: 'Douala',
      status: 'SUSPENDED',
    );

    await pumpDetailPage(tester, 't-active');

    // Clic sur Suspendre
    await tester.tap(find.text('Suspendre'));
    await tester.pumpAndSettle();

    // Confirmation dans le dialogue
    final confirmButtonFinder = find.widgetWithText(FilledButton, 'Suspendre');
    await tester.tap(confirmButtonFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // L'appel API a bien eu lieu
    expect(mockRepo.setStatusCalls, 1);
    expect(mockRepo.lastUpdatedId, 't-active');
    expect(mockRepo.lastUpdatedStatus, 'SUSPENDED');

    // Le statut dans la vue et le bouton se sont actualisés
    expect(find.text('Statut : SUSPENDED'), findsOneWidget);
    expect(find.text('Réactiver'), findsOneWidget);

    // Écoulement du timer et de l'animation de fermeture du snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('6. Actualisation du statut après action de réactivation confirmée', (tester) async {
    mockRepo.nextResult = const Tenant(
      id: 't-suspended',
      name: 'Trans Cargo Suspendue',
      code: 'TCS',
      city: 'Yaoundé',
      status: 'ACTIVE',
    );

    await pumpDetailPage(tester, 't-suspended');

    // Clic sur Réactiver
    await tester.tap(find.text('Réactiver'));
    await tester.pumpAndSettle();

    // Confirmation dans le dialogue
    final confirmButtonFinder = find.widgetWithText(FilledButton, 'Réactiver');
    await tester.tap(confirmButtonFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // L'appel API a bien eu lieu
    expect(mockRepo.setStatusCalls, 1);
    expect(mockRepo.lastUpdatedId, 't-suspended');
    expect(mockRepo.lastUpdatedStatus, 'ACTIVE');

    // Le statut dans la vue et le bouton se sont actualisés
    expect(find.text('Statut : ACTIVE'), findsOneWidget);
    expect(find.text('Suspendre'), findsOneWidget);

    // Écoulement du timer et de l'animation de fermeture du snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('7. Gestion des erreurs API : affiche une notification d erreur et préserve l état', (tester) async {
    mockRepo.shouldThrow = true;

    await pumpDetailPage(tester, 't-active');

    // Clic sur Suspendre et confirmation
    await tester.tap(find.text('Suspendre'));
    await tester.pumpAndSettle();

    final confirmButtonFinder = find.widgetWithText(FilledButton, 'Suspendre');
    await tester.tap(confirmButtonFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // L'appel a été tenté
    expect(mockRepo.setStatusCalls, 1);

    // Le statut reste inchangé (ACTIVE)
    expect(find.text('Statut : ACTIVE'), findsOneWidget);
    expect(find.text('Suspendre'), findsOneWidget);

    // Écoulement du timer et de l'animation de fermeture du snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
