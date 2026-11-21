import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:3000/api/v1';

  test('health endpoint répond', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000'));
    final response = await dio.get<Map<String, dynamic>>('/health');
    expect(response.statusCode, 200);
    expect(response.data?['status'], 'ok');
  });

  test('register/login/me/refresh fonctionnent', () async {
    final email = 'flutter.integration.${DateTime.now().millisecondsSinceEpoch}@example.com';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    final register = await dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{
        'email': email,
        'password': 'Password123!',
        'lastName': 'Integration',
        'phone': '+237600000001',
      },
    );
    expect(register.statusCode, 201);
    final accessToken = register.data!['data']['accessToken'] as String;
    final refreshToken = register.data!['data']['refreshToken'] as String;

    final me = await dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(headers: <String, dynamic>{'Authorization': 'Bearer $accessToken'}),
    );
    expect(me.statusCode, 200);
    expect(me.data!['data']['user']['email'], email);

    final refresh = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
    expect(refresh.statusCode, 200);
    expect(refresh.data!['data']['accessToken'], isNotNull);
    expect(refresh.data!['data']['refreshToken'], isNotNull);
  });

  test('my/parcels répond pour un client', () async {
    final email = 'flutter.integration2.${DateTime.now().millisecondsSinceEpoch}@example.com';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    final register = await dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{
        'email': email,
        'password': 'Password123!',
        'lastName': 'Integration',
        'phone': '+237600000002',
      },
    );
    final token = register.data!['data']['accessToken'] as String;
    final response = await dio.get<Map<String, dynamic>>(
      '/my/parcels',
      options: Options(headers: <String, dynamic>{'Authorization': 'Bearer $token'}),
    );
    expect(response.statusCode, 200);
    expect(response.data!['data']['items'], isA<List<dynamic>>());
  });

  test('public tracking code inconnu retourne 404', () async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    try {
      await dio.get<Map<String, dynamic>>('/public/tracking/TRK-2026-000000');
      fail('Expected 404');
    } on DioException catch (error) {
      expect(error.response?.statusCode, 404);
    }
  });
}