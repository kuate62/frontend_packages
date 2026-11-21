import 'package:dio/dio.dart';

import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Identifiants invalide.');
    }
    return AuthSession.fromJson(data);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String lastName,
    required String phone,
    String? firstName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        if (firstName != null && firstName.trim().isNotEmpty)
          'firstName': firstName.trim(),
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Réponse d’inscription invalide.');
    }
    return AuthSession.fromJson(data);
  }

  Future<User> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final userJson = data?['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw StateError('Profil utilisateur introuvable.');
    }
    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _dio.post<Map<String, dynamic>>('/auth/logout');
    } catch (_) {
      // La déconnexion client reste possible même si l'appel échoue.
    }
  }

  Future<String> requestPasswordReset({required String email}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      data: <String, dynamic>{'email': email.trim().toLowerCase()},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data?['message'] as String? ?? 'Code envoyé.';
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/reset-password',
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data?['message'] as String? ?? 'Mot de passe réinitialisé avec succès.';
  }
}