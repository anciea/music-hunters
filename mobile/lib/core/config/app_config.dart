/// AppConfig — compile-time configuration via --dart-define.
///
/// Usage:
///   flutter run --dart-define=API_BASE_URL=https://myserver.com --dart-define=API_KEY=secret
///
/// Defaults point to the Android emulator host loopback (10.0.2.2 == localhost on host).
abstract class AppConfig {
  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:8000',
      );

  static String get apiKey => const String.fromEnvironment(
        'API_KEY',
        defaultValue: 'dev-key',
      );
}
