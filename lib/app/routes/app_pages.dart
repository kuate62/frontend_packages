import 'package:get/get.dart';

import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/screens/onboarding_page.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/screens/login_page.dart';
import '../../features/auth/screens/register_page.dart';
import '../../features/auth/screens/forgot_password_page.dart';
import '../../features/client/bindings/client_shell_binding.dart';

import '../../app/middlewares/auth_middleware.dart';
import '../../features/client/pages/client_shell_page.dart';
import '../../features/driver/bindings/driver_binding.dart';
import '../../features/driver/pages/driver_trip_detail_page.dart';
import '../../features/driver/pages/driver_trips_page.dart';
import '../../features/professional/bindings/company_dashboard_binding.dart';
import '../../features/professional/pages/agent_home_page.dart';
import '../../features/professional/pages/company_dashboard_page.dart';
import '../../features/agencies/bindings/agency_dashboard_binding.dart';
import '../../features/agencies/pages/agency_dashboard_page.dart';
import '../../features/reception/bindings/reception_binding.dart';
import '../../features/reception/pages/reception_page.dart';
import '../../features/professional/pages/professional_home_page.dart';
import '../../features/agencies/bindings/agencies_binding.dart' as professional_agencies;
import '../../features/agents/bindings/agents_binding.dart';
import '../../features/agents/pages/agent_create_page.dart';
import '../../features/agents/pages/agent_detail_page.dart';
import '../../features/agents/pages/agents_page.dart';
import '../../features/agencies/pages/agency_create_page.dart';
import '../../features/agencies/pages/agency_detail_page.dart';
import '../../features/agencies/pages/agencies_page.dart';

import '../../features/directory/bindings/companies_binding.dart';
import '../../features/directory/pages/companies_page.dart';
import '../../features/onboarding/screens/welcome_page.dart';
import '../../features/shipments/bindings/shipment_request_binding.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/claims/bindings/claims_binding.dart';
import '../../features/claims/pages/claim_create_page.dart';
import '../../features/claims/pages/claims_page.dart';
import '../../features/claims/pages/claim_detail_page.dart';
import '../../features/shipments/pages/shipment_payment_page.dart';
import '../../features/shipments/pages/shipment_request_page.dart';
import '../../features/super_admin/bindings/super_admin_binding.dart';
import '../../features/super_admin/pages/super_admin_dashboard_page.dart';
import '../../features/super_admin/pages/super_admin_detail_page.dart';
import '../../features/super_admin/pages/super_admin_page.dart';
import '../../features/super_admin/pages/super_admin_users_page.dart';
import '../../features/super_admin/pages/super_admin_user_detail_page.dart';
import '../../features/parcels/bindings/parcel_create_binding.dart';
import '../../features/parcels/bindings/parcels_binding.dart';
import '../../features/parcels/pages/parcel_create_page.dart';
import '../../features/parcels/pages/parcel_detail_page.dart';
import '../../features/parcels/pages/parcel_waybill_page.dart';
import '../../features/parcels/pages/parcels_page.dart';
import '../../features/trips/bindings/trips_binding.dart';
import '../../features/trips/pages/trip_create_page.dart';
import '../../features/trips/pages/trip_detail_page.dart';
import '../../features/trips/pages/trip_edit_page.dart';
import '../../features/trips/pages/trips_page.dart';
import '../../features/vehicles/bindings/vehicles_binding.dart';
import '../../features/vehicles/pages/vehicle_create_page.dart';
import '../../features/vehicles/pages/vehicle_detail_page.dart';
import '../../features/vehicles/pages/vehicles_page.dart';
import '../../features/shipment_requests/bindings/company_shipment_requests_binding.dart';
import '../../features/shipment_requests/pages/company_shipment_requests_page.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../shared/widgets/app_placeholder_page.dart';
import 'app_routes.dart';

/// Table de routage GetX.
abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const ClientShellPage(),
      binding: ClientShellBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['CLIENT'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.platformHome,
      page: () => const SuperAdminPage(),
      binding: SuperAdminBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['SUPER_ADMIN'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.superAdminDashboard,
      page: () => const SuperAdminDashboardPage(),
      binding: SuperAdminBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['SUPER_ADMIN'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.superAdminDetail,
      page: () => const SuperAdminDetailPage(),
      binding: SuperAdminBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.superAdminUsers,
      page: () => const SuperAdminUsersPage(),
      binding: SuperAdminBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['SUPER_ADMIN'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.superAdminUserDetail,
      page: () => const SuperAdminUserDetailPage(),
      binding: SuperAdminBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.companyAdminHome,
      page: () => const CompanyDashboardPage(),
      binding: CompanyDashboardBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['TENANT_ADMIN'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.agencyManagerHome,
      page: () => const AgencyDashboardPage(),
      binding: AgencyDashboardBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['AGENCY_MANAGER'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.agentHome,
      page: () => const AgentHomePage(),
      binding: ParcelsBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['AGENT'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.parcels,
      page: () => const ParcelsPage(),
      binding: ParcelsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.parcelDetail,
      page: () => const ParcelDetailPage(),
      binding: ParcelsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.parcelWaybill,
      page: () => const ParcelWaybillPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.parcelCreate,
      page: () => const ParcelCreatePage(),
      binding: ParcelCreateBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.driverHome,
      page: () => const DriverTripsPage(),
      binding: DriverBinding(),
      middlewares: [AuthMiddleware(allowedRoles: const ['DRIVER'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.driverTrips,
      page: () => const DriverTripsPage(),
      binding: DriverBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.driverTripDetail,
      page: () => const DriverTripDetailPage(),
      binding: DriverBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.receptionHome,
      page: () => const ProfessionalHomePage(title: 'Réception', subtitle: 'Réception et remise'),
      middlewares: [AuthMiddleware(allowedRoles: const ['AGENT'])],
    ),
    GetPage<dynamic>(
      name: AppRoutes.reception,
      page: () => const ReceptionPage(),
      binding: ReceptionBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.vehicles,
      page: () => const VehiclesPage(),
      binding: VehiclesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.vehicleCreate,
      page: () => const VehicleCreatePage(),
      binding: VehiclesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.vehicleDetail,
      page: () => const VehicleDetailPage(),
      binding: VehiclesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.trips,
      page: () => const TripsPage(),
      binding: TripsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.tripCreate,
      page: () => const TripCreatePage(),
      binding: TripsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.tripDetail,
      page: () => const TripDetailPage(),
      binding: TripsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.tripEdit,
      page: () => const TripEditPage(),
      binding: TripsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.shipmentRequest,
      page: () => const ShipmentRequestPage(),
      binding: ShipmentRequestBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.shipmentPayment,
      page: () => const ShipmentPaymentPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.companyShipmentRequests,
      page: () => const CompanyShipmentRequestsPage(),
      binding: CompanyShipmentRequestsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      binding: NotificationsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.claims,
      page: () => const ClaimsPage(),
      binding: ClaimsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.claimCreate,
      page: () => const ClaimCreatePage(),
      binding: ClaimsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.claimDetail,
      page: () => const ClaimDetailPage(),
      binding: ClaimsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.companies,
      page: () => const CompaniesPage(),
      binding: CompaniesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.agencies,
      page: () => const AgenciesPage(),
      binding: professional_agencies.AgenciesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.agencyCreate,
      page: () => const AgencyCreatePage(),
      binding: professional_agencies.AgenciesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.agencyDetail,
      page: () => const AgencyDetailPage(),
      binding: professional_agencies.AgenciesBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.agents,
      page: () => const AgentsPage(),
      binding: AgentsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.agentCreate,
      page: () => const AgentCreatePage(),
      binding: AgentsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.agentDetail,
      page: () => const AgentDetailPage(),
      binding: AgentsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.platform,
      page: () => const AppPlaceholderPage(
        title: 'Administration plateforme',
        message: 'Destination temporaire pour un super administrateur.',
      ),
    ),
    GetPage<dynamic>(
      name: AppRoutes.contextSelection,
      page: () => const AppPlaceholderPage(
        title: 'Sélection du contexte',
        message: 'Plusieurs appartenances détectées. Choix à implémenter.',
      ),
    ),
  ];
}