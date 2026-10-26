class AppConfig {
  static const appName = 'Uni Secure';
  static const configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static String get apiBaseUrl {
    if (configuredApiBaseUrl.isNotEmpty) return configuredApiBaseUrl;
    // The current MAMP development machine is reachable from physical devices
    // at this LAN address. Override with --dart-define for another network.
    return 'http://192.168.1.8:8000/api/v1';
  }

  static const requestTimeout = Duration(seconds: 20);
}
