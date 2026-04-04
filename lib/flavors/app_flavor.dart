enum FlavorType { dev, staging, prod }

class AppFlavor {
  final FlavorType type;
  final String baseUrl;
  final String name;
  final bool enableLogging;
  final bool showDebugBanner;

  const AppFlavor._({
    required this.type,
    required this.baseUrl,
    required this.name,
    required this.enableLogging,
    required this.showDebugBanner,
  });

  static const AppFlavor dev = AppFlavor._(
    type: FlavorType.dev,
    baseUrl: 'https://api-dev.sanad.sa/v1',
    name: 'DEV',
    enableLogging: true,
    showDebugBanner: true,
  );

  static const AppFlavor staging = AppFlavor._(
    type: FlavorType.staging,
    baseUrl: 'https://api-staging.sanad.sa/v1',
    name: 'STAGING',
    enableLogging: true,
    showDebugBanner: true,
  );

  static const AppFlavor prod = AppFlavor._(
    type: FlavorType.prod,
    baseUrl: 'https://api.sanad.sa/v1',
    name: 'PROD',
    enableLogging: false,
    showDebugBanner: false,
  );

  static AppFlavor _current = dev;

  static AppFlavor get current => _current;

  static void setCurrent(AppFlavor flavor) => _current = flavor;

  bool get isDev => type == FlavorType.dev;
  bool get isStaging => type == FlavorType.staging;
  bool get isProd => type == FlavorType.prod;

  @override
  String toString() => 'AppFlavor($name)';
}
