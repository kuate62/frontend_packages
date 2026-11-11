/// Environnement d'exécution de l'application.
enum AppEnvironment {
  development,
  production;

  /// Interprète `APP_ENV` (`development` / `dev`, `production` / `prod`).
  static AppEnvironment parse(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        throw ArgumentError.value(raw, 'APP_ENV', 'Environnement inconnu.');
    }
  }

  String get label => switch (this) {
    AppEnvironment.development => 'Développement',
    AppEnvironment.production => 'Production',
  };
}

/// Configuration sans secret, fournie au lancement.
///
/// `API_BASE_URL` est l'origine du serveur (sans préfixe d'API).
/// Le préfixe `/api/v1` est ajouté par [apiRootUrl].
///
/// ```text
/// flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://10.0.2.2:3000
/// flutter run --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.exemple.com
/// ```
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  final AppEnvironment environment;

  /// Origine normalisée, sans barre finale.
  final String apiBaseUrl;

  static const String apiPrefix = '/api/v1';

  /// Valeur par défaut réservée au poste de développement local.
  /// L'émulateur Android doit surcharger avec `http://10.0.2.2:<port>`.
  static const String defaultApiBaseUrl = 'http://127.0.0.1:3000';

  factory AppConfig.fromEnvironment() {
    const rawEnvironment = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const rawBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: defaultApiBaseUrl,
    );
    return AppConfig(
      environment: AppEnvironment.parse(rawEnvironment),
      apiBaseUrl: normalizeBaseUrl(rawBaseUrl),
    );
  }

  /// Racine des appels HTTP, avec barre finale pour Dio.
  String get apiRootUrl => '$apiBaseUrl$apiPrefix/';

  static String normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    final uri = Uri.tryParse(trimmed);
    final schemeOk =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (uri == null || !schemeOk || uri.host.isEmpty) {
      throw ArgumentError.value(
        raw,
        'API_BASE_URL',
        'URL absolue http ou https attendue.',
      );
    }
    var text = trimmed;
    while (text.endsWith('/')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }
}
