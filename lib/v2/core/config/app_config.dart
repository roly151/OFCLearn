class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.appName,
  });

  final String baseUrl;
  final String appName;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      baseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://ofcmulti.test/wp-json/ofc-mobile/v1',
      ),
      appName: 'OFC Learn v2',
    );
  }
}
