import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/context/user_context.dart';
import '../../../core/context/user_context_resolver.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';

enum SplashStatus { loading, ready, error }

class SplashController extends GetxController {
  SplashController({
    required this.secureStorage,
    required this.localStorage,
    required this.dioClient,
    this.sessionService,
    this.contextResolver = const UserContextResolver(),
  });

  final SecureStorageService secureStorage;
  final LocalStorageService localStorage;
  final DioClient dioClient;
  final SessionService? sessionService;
  final UserContextResolver contextResolver;

  final status = SplashStatus.loading.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    prepare();
  }

  Future<void> prepare() async {
    status.value = SplashStatus.loading;
    errorMessage.value = null;

    try {
      final token = await secureStorage.readAccessToken();
      final onboardingCompleted = await localStorage.isOnboardingCompleted();

      if (token == null || token.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 2000));
        if (!onboardingCompleted) {
          Get.offAllNamed(AppRoutes.onboarding);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
        return;
      }

      try {
        final response = await dioClient.dio.get<Map<String, dynamic>>('/auth/me');
        if (response.statusCode != 200) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          );
        }

        sessionService?.activateSession();
        sessionService?.scheduleFromToken(token);
        final userJson = response.data?['data']?['user'] as Map<String, dynamic>?;
        if (userJson == null) {
          throw DioException(
            requestOptions: response.requestOptions,
            type: DioExceptionType.badResponse,
          );
        }

        await Future<void>.delayed(const Duration(milliseconds: 2000));
        final context = contextResolver.resolve(userJson);
        if (context.type == UserContextType.multipleMemberships) {
          Get.offAllNamed(AppRoutes.contextSelection);
          return;
        }
        if (context.type == UserContextType.unauthenticated) {
          await secureStorage.clearSession();
          Get.offAllNamed(AppRoutes.login);
          return;
        }

        final role = context.type == UserContextType.platform
            ? 'SUPER_ADMIN'
            : (context.memberships.isNotEmpty ? context.memberships.first.role : 'CLIENT');
        switch (role) {
          case 'SUPER_ADMIN':
            Get.offAllNamed(AppRoutes.platformHome);
            break;
          case 'TENANT_ADMIN':
            Get.offAllNamed(AppRoutes.companyAdminHome);
            break;
          case 'AGENCY_MANAGER':
            Get.offAllNamed(AppRoutes.agencyManagerHome);
            break;
          case 'AGENT':
            Get.offAllNamed(AppRoutes.agentHome);
            break;
          case 'DRIVER':
            Get.offAllNamed(AppRoutes.driverHome);
            break;
          default:
            Get.offAllNamed(AppRoutes.home);
            break;
        }
      } on DioException catch (error) {
        if (error.response?.statusCode == 401) {
          await Future<void>.delayed(const Duration(milliseconds: 2000));
          await secureStorage.clearSession();
          Get.offAllNamed(AppRoutes.login);
          return;
        }
        errorMessage.value = 'Connexion au serveur impossible. Veuillez réessayer.';
        status.value = SplashStatus.error;
      }
    } catch (_) {
      errorMessage.value = 'Le stockage sécurisé est indisponible.';
      status.value = SplashStatus.error;
    }
  }
}