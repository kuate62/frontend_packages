import 'package:get/get.dart';

import '../../features/design_system/screens/design_system_preview_page.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/screens/splash_page.dart';
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
      name: AppRoutes.designSystemPreview,
      page: () => const DesignSystemPreviewPage(),
    ),
  ];
}
