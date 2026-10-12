class AppConfig {
  static const appName = 'UniSecure';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
  static const requestTimeout = Duration(seconds: 20);
}
