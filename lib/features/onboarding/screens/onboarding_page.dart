import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  late final OnboardingController _controller;

  static const List<_OnboardingData> _pages = <_OnboardingData>[
    _OnboardingData(
      image: 'assets/images/onboarding/onboarding_send.jpg',
      title: 'Envoyez vos colis en toute simplicité',
      description:
          'Déposez votre colis en agence et confiez son acheminement à un réseau de transport organisé.',
      accent: AppColors.primary,
    ),
    _OnboardingData(
      image: 'assets/images/onboarding/onboarding_track.jpg',
      title: 'Suivez votre colis à chaque étape',
      description:
          'Restez informé de son évolution, de son départ jusqu’à son arrivée à destination.',
      accent: AppColors.secondary,
    ),
    _OnboardingData(
      image: 'assets/images/onboarding/onboarding_receive.jpg',
      title: 'Recevez vos colis en toute confiance',
      description:
          'Soyez informé lorsque votre colis arrive et récupérez-le simplement auprès de votre agence de destination.',
      accent: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OnboardingController>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _controller.complete();
    Get.offAllNamed(AppRoutes.welcome);
  }

  void _next() {
    if (_controller.pageIndex.value == _pages.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AppColors.inkDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _controller.onPageChanged,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingPageView(
                data: page,
                reduceMotion: reduceMotion,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 12),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Passer'),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Obx(() {
                  final isLast =
                      _controller.pageIndex.value == _pages.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PageIndicator(
                        count: _pages.length,
                        index: _controller.pageIndex.value,
                        accent: _pages[_controller.pageIndex.value].accent,
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _pages[_controller.pageIndex.value].accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius,
                              ),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _next,
                          child: Text(
                            isLast ? 'Commencer' : 'Continuer',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.data, required this.reduceMotion});

  final _OnboardingData data;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          data.image,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: AppColors.inkDark);
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.75),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.xl,
              AppDimensions.lg,
              180,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: data.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  data.title,
                  style: AppTextStyles.headline.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  data.description,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.index,
    required this.accent,
  });

  final int count;
  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Étape ${index + 1} sur $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(count, (i) {
          final active = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: active ? 28 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active ? accent : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    required this.accent,
  });

  final String image;
  final String title;
  final String description;
  final Color accent;
}
