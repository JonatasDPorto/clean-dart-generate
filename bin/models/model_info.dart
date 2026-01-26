/// Encapsulates information about a model for code generation
class ModelInfo {
  final String fileName;
  final String className;
  final String? endpoint;
  final String? baseUrl;

  const ModelInfo({
    required this.fileName,
    required this.className,
    this.endpoint,
    this.baseUrl,
  });

  /// Gets the endpoint path, with fallback to default pattern
  String getEndpointPath() {
    if (endpoint != null) {
      return endpoint!;
    }
    return '/${className.toLowerCase()}s';
  }

  /// Gets the base URL with fallback
  String getBaseUrl(String? override) {
    return override ?? baseUrl ?? 'https://api.example.com';
  }

  /// Gets the collection name for Firestore
  String getCollectionName() {
    if (endpoint != null) {
      return endpoint!
          .replaceAll('/', '')
          .replaceAll('@', '')
          .toLowerCase();
    }
    return '${className.toLowerCase()}s';
  }
}

