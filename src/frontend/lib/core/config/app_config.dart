class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const clienteId = int.fromEnvironment(
    'CLIENTE_ID',
    defaultValue: 1,
  );

  static const pollingSeconds = int.fromEnvironment(
    'POLLING_SECONDS',
    defaultValue: 6,
  );
}
