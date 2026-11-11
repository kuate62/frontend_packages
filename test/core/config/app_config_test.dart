import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('ajoute le préfixe /api/v1 à l’origine', () {
      const config = AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://127.0.0.1:3000',
      );

      expect(config.apiRootUrl, 'http://127.0.0.1:3000/api/v1/');
      expect(config.environment.label, 'Développement');
    });

    test('retire les barres finales de la base URL', () {
      expect(
        AppConfig.normalizeBaseUrl('https://api.exemple.com///'),
        'https://api.exemple.com',
      );
    });

    test('refuse une URL relative ou vide', () {
      expect(() => AppConfig.normalizeBaseUrl(''), throwsArgumentError);
      expect(() => AppConfig.normalizeBaseUrl('/api'), throwsArgumentError);
      expect(
        () => AppConfig.normalizeBaseUrl('ftp://api.exemple.com'),
        throwsArgumentError,
      );
    });

    test('reconnaît les alias d’environnement', () {
      expect(AppEnvironment.parse('prod'), AppEnvironment.production);
      expect(AppEnvironment.parse(' DEV '), AppEnvironment.development);
      expect(() => AppEnvironment.parse('staging'), throwsArgumentError);
    });
  });
}
