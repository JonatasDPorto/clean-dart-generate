/// Generator for annotation classes
class AnnotationGenerator {
  /// Generates the endpoint annotation file
  String generateEndpointAnnotation() {
    return '''
${_generateEndpointAnnotation()}
${_generateBaseUrlAnnotation()}
${_generateCleanDartGenerateAnnotation()}
''';
  }

  String _generateEndpointAnnotation() {
    return '''
class Endpoint {
  final String path;
  const Endpoint(this.path);
}
''';
  }

  String _generateBaseUrlAnnotation() {
    return '''
class BaseUrl {
  final String url;
  const BaseUrl(this.url);
}
''';
  }

  String _generateCleanDartGenerateAnnotation() {
    return '''
class CleanDartGenerate {
  const CleanDartGenerate();
}
''';
  }
}

