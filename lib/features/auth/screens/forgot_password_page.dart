import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../repositories/auth_repository.dart';

enum ForgotPasswordStep { email, code, newPassword, success }

/// Écran moderne de récupération de mot de passe ExpressIO.
/// Déroule les 3 étapes (Email -> OTP -> Nouveau Mot de Passe) avec feedback visuel.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _obscurePassword = true.obs;
  final _obscureConfirm = true.obs;

  final _currentStep = ForgotPasswordStep.email.obs;
  final _isLoading = false.obs;
  final _errorMessage = RxnString();
  final _successMessage = RxnString();

  // Minuteur de renvoi OTP
  Timer? _resendTimer;
  final _resendCountdown = 0.obs;

  late final AuthRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = Get.find<AuthRepository>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    _resendCountdown.value = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown.value > 0) {
        _resendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // Étape 1 : Demande de code OTP
  Future<void> _requestOtp() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final msg = await _repository.requestPasswordReset(email: _emailController.text);
      _successMessage.value = msg;
      _currentStep.value = ForgotPasswordStep.code;
      _startResendTimer(60);
    } catch (_) {
      _errorMessage.value = 'Impossible d\'envoyer le code. Vérifiez votre connexion.';
    } finally {
      _isLoading.value = false;
    }
  }

  // Étape 2 : Validation du code et passage à la saisie du nouveau mot de passe
  void _verifyOtp() {
    if (!(_codeFormKey.currentState?.validate() ?? false)) return;
    _errorMessage.value = null;
    _currentStep.value = ForgotPasswordStep.newPassword;
  }

  // Étape 3 : Soumission du nouveau mot de passe
  Future<void> _submitNewPassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _errorMessage.value = 'Les mots de passe ne correspondent pas.';
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final msg = await _repository.resetPassword(
        email: _emailController.text,
        code: _codeController.text,
        newPassword: _newPasswordController.text,
      );
      _successMessage.value = msg;
      _currentStep.value = ForgotPasswordStep.success;
    } catch (_) {
      _errorMessage.value = 'Code invalide ou expiré. Veuillez vérifier le code ou en redemander un.';
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep.value == ForgotPasswordStep.code) {
              _currentStep.value = ForgotPasswordStep.email;
            } else if (_currentStep.value == ForgotPasswordStep.newPassword) {
              _currentStep.value = ForgotPasswordStep.code;
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.md),
                    _buildStepIndicator(),
                    const SizedBox(height: AppDimensions.lg),
                    _buildErrorOrSuccess(),
                    _buildCurrentStepContent(),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/expressio_logo.jpg',
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Mot de passe oublié',
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          _getSubtitleForCurrentStep(),
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getSubtitleForCurrentStep() {
    switch (_currentStep.value) {
      case ForgotPasswordStep.email:
        return 'Entrez votre adresse e-mail pour recevoir un code de réinitialisation sécurisé.';
      case ForgotPasswordStep.code:
        return 'Saisissez le code à 6 chiffres reçu par e-mail.';
      case ForgotPasswordStep.newPassword:
        return 'Définissez votre nouveau mot de passe fort.';
      case ForgotPasswordStep.success:
        return 'Votre mot de passe a été mis à jour avec succès.';
    }
  }

  Widget _buildStepIndicator() {
    int activeIndex = 0;
    if (_currentStep.value == ForgotPasswordStep.code) {
      activeIndex = 1;
    } else if (_currentStep.value == ForgotPasswordStep.newPassword ||
        _currentStep.value == ForgotPasswordStep.success) {
      activeIndex = 2;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= activeIndex;
        final isCurrent = index == activeIndex;
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? AppColors.primary
                    : isActive
                        ? AppColors.primaryLight
                        : const Color(0xFFCBD5E1),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (index < 2)
              Container(
                width: 36,
                height: 3,
                color: index < activeIndex ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorOrSuccess() {
    final error = _errorMessage.value;
    final success = _successMessage.value;

    if (error != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.md),
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 20, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      );
    }

    if (success != null && _currentStep.value != ForgotPasswordStep.success) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.md),
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep.value) {
      case ForgotPasswordStep.email:
        return _buildEmailStep();
      case ForgotPasswordStep.code:
        return _buildCodeStep();
      case ForgotPasswordStep.newPassword:
        return _buildNewPasswordStep();
      case ForgotPasswordStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Adresse e-mail de votre compte',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Adresse e-mail requise.';
              if (!text.contains('@')) return 'Adresse e-mail invalide.';
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
              ),
              onPressed: _isLoading.value ? null : _requestOtp,
              child: _isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Envoyer le code OTP'),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep() {
    return Form(
      key: _codeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Code de vérification (6 chiffres)',
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.pin_outlined,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Code de vérification requis.';
              if (text.length != 6) return 'Le code doit contenir 6 chiffres.';
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Pas reçu de code ?',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: _resendCountdown.value > 0 ? null : _requestOtp,
                child: Text(
                  _resendCountdown.value > 0
                      ? 'Renvoyer dans ${_resendCountdown.value}s'
                      : 'Renvoyer le code',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
              ),
              onPressed: _verifyOtp,
              child: const Text('Valider le code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            return AppTextField(
              label: 'Nouveau mot de passe',
              controller: _newPasswordController,
              obscureText: _obscurePassword.value,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => _obscurePassword.value = !_obscurePassword.value,
              ),
              validator: (value) {
                if ((value ?? '').length < 8) {
                  return 'Le mot de passe doit comporter au moins 8 caractères.';
                }
                return null;
              },
            );
          }),
          const SizedBox(height: AppDimensions.sm),
          Obx(() {
            return AppTextField(
              label: 'Confirmer le nouveau mot de passe',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm.value,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => _obscureConfirm.value = !_obscureConfirm.value,
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return 'Veuillez confirmer votre mot de passe.';
                return null;
              },
            );
          }),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
              ),
              onPressed: _isLoading.value ? null : _submitNewPassword,
              child: _isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Enregistrer le nouveau mot de passe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 64, color: AppColors.success),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Félicitations !',
          style: AppTextStyles.headline.copyWith(color: AppColors.success),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter en toute sécurité.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xl),
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius),
              ),
            ),
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            child: const Text('Se connecter'),
          ),
        ),
      ],
    );
  }
}
