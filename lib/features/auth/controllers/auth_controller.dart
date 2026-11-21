import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/context/user_context.dart';
import '../../../core/context/user_context_resolver.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/models/membership.dart';
import '../../../core/session/session_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController({
    required this.repository,
    required this.secureStorage,
    this.sessionService,
    this.contextResolver = const UserContextResolver(),
  });

  final AuthRepository repository;
  final SecureStorageService secureStorage;
  final SessionService? sessionService;
  final UserContextResolver contextResolver;

  final user = Rxn<User>();
  final accessToken = RxnString();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  bool get isAuthenticated =>
      accessToken.value != null && accessToken.value!.isNotEmpty && user.value != null;

  String get primaryRole {
    if (user.value?.isPlatformAdmin ?? false) {
      return 'SUPER_ADMIN';
    }
    final memberships = user.value?.memberships ?? const <Membership>[];
    if (memberships.isEmpty) {
      return 'CLIENT';
    }
    return memberships.first.role;
  }

  Future<void> restoreSession() async {
    final token = await secureStorage.readAccessToken();
    if (token == null) {
      return;
    }
    accessToken.value = token;
    try {
      user.value = await repository.me();
    } catch (_) {
      await secureStorage.clearSession();
      accessToken.value = null;
      user.value = null;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final session = await repository.login(email: email, password: password);
      await secureStorage.saveAccessToken(session.accessToken);
      if (session.refreshToken != null) {
        await secureStorage.saveRefreshToken(session.refreshToken!);
      }
      accessToken.value = session.accessToken;
      user.value = await repository.me();
      sessionService?.activateSession();
      sessionService?.scheduleFromToken(session.accessToken);
      _navigateAfterLogin(user.value!);
      return true;
    } catch (error) {
      await secureStorage.clearSession();
      accessToken.value = null;
      user.value = null;
      errorMessage.value = _messageFromError(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateAfterLogin(User user) {
    try {
      final context = contextResolver.resolve(user.toJson());
      if (context.type == UserContextType.multipleMemberships) {
        Get.offAllNamed(AppRoutes.contextSelection);
        return;
      }
      if (context.type == UserContextType.unauthenticated) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final role = primaryRole;
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
    } catch (_) {
      // La navigation peut être indisponible dans les tests unitaires.
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String lastName,
    required String phone,
    String? firstName,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final session = await repository.register(
        email: email,
        password: password,
        lastName: lastName,
        phone: phone,
        firstName: firstName,
      );
      await secureStorage.saveAccessToken(session.accessToken);
      if (session.refreshToken != null) {
        await secureStorage.saveRefreshToken(session.refreshToken!);
      }
      accessToken.value = session.accessToken;
      user.value = session.user;
      sessionService?.activateSession();
      sessionService?.scheduleFromToken(session.accessToken);
      try {
        user.value = await repository.me();
      } catch (_) {
        // Le profil retourné par l'inscription reste utilisable.
      }
      _navigateAfterLogin(user.value!);
      return true;
    } catch (error) {
      await secureStorage.clearSession();
      accessToken.value = null;
      user.value = null;
      errorMessage.value = _messageFromError(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    sessionService?.cancelAndInvalidate();
    await repository.logout();
    await secureStorage.clearSession();
    accessToken.value = null;
    user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  String _messageFromError(Object error) {
    if (error is DioException) {
      final wrapped = error.error;
      if (wrapped is ApiException) {
        return wrapped.message;
      }
      return ApiException.fromDio(error).message;
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}