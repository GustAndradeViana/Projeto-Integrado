class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );
  static const pollingSeconds = int.fromEnvironment(
    'POLLING_SECONDS',
    defaultValue: 6,
  );
}