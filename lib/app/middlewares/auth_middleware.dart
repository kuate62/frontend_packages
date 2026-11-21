import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.allowedRoles});

  final List<String>? allowedRoles;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }
    final controller = Get.find<AuthController>();
    if (!controller.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (allowedRoles != null && !allowedRoles!.contains(controller.primaryRole)) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}