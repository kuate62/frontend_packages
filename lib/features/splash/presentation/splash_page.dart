import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_error_view.dart';
import 'splash_controller.dart';

/// Écran Splash Premium ExpressIO.
/// Affiche le logo officiel avec animations fluides d'entrée,
/// dégradé de fond immersif et indicateur de progression.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final SplashController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SplashController>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion;
    if (reduceMotion) {
      _animationController.value = 1.0;
    } else {
      _animationController.forward();
    }

    _logoFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
    );
    _taglineFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );
    _loaderFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec dégradé subtil
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF4F7F9),
                    Color(0xFFE9F1F6),
                  ],
                ),
              ),
            ),
          ),

          // Halos lumineux décoratifs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (_controller.status.value == SplashStatus.error) {
                return AppErrorView(
                  message: _controller.errorMessage.value ?? 'Connexion au serveur impossible.',
                  onRetry: _controller.prepare,
                );
              }
              return _buildContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Logo officiel animé avec container stylisé
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/expressio_logo.jpg',
                    width: 200,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // Titre & Slogan
            FadeTransition(
              opacity: _titleFade,
              child: Text(
                'ExpressIO',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xs),

            FadeTransition(
              opacity: _taglineFade,
              child: Text(
                'Transport & Expédition de colis interurbains',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 2),

            // Barre de chargement élégante
            FadeTransition(
              opacity: _loaderFade,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 140,
                      height: 4,
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Chargement en cours...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Mention de bas de page sécurisée
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: AppColors.textDisabled),
                const SizedBox(width: 6),
                Text(
                  'Plateforme SaaS certifiée ExpressIO v1.0',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
          ],
        ),
      ),
    );
  }
}
