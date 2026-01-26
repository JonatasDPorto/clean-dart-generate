/// Configuration class for CLI arguments
class CliConfig {
  final DatasourceType datasourceType;
  final String? baseUrlOverride;

  const CliConfig({
    required this.datasourceType,
    this.baseUrlOverride,
  });

  factory CliConfig.fromArguments(List<String> arguments) {
    return CliConfig(
      datasourceType: _parseDatasourceType(arguments),
      baseUrlOverride: _parseBaseUrlOverride(arguments),
    );
  }

  static DatasourceType _parseDatasourceType(List<String> arguments) {
    if (arguments.contains('--dio')) {
      return DatasourceType.dio;
    } else if (arguments.contains('--http')) {
      return DatasourceType.http;
    } else if (arguments.contains('--firestore')) {
      return DatasourceType.firestore;
    }
    // Default to firestore for backward compatibility
    return DatasourceType.firestore;
  }

  static String? _parseBaseUrlOverride(List<String> arguments) {
    final baseUrlIndex = arguments.indexOf('--base-url-override');
    if (baseUrlIndex != -1 && baseUrlIndex + 1 < arguments.length) {
      return arguments[baseUrlIndex + 1];
    }
    return null;
  }
}

enum DatasourceType {
  firestore,
  dio,
  http,
}
