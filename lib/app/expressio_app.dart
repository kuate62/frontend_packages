import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import '../core/theme/app_theme.dart';

/// Point d'entrée visuel : navigation, injection et thème.
class ExpressioApp extends StatelessWidget {
  const ExpressioApp({super.key, this.initialBinding});

  /// Permet aux tests d'injecter des doubles sans plugin natif.
  final Bindings? initialBinding;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ExpressIO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialBinding: initialBinding ?? InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
