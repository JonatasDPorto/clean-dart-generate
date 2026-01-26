// This file will be generated in the project to define the Endpoint annotation
// Users should create this file in their project: lib/domain/annotations/endpoint.dart

String generateEndpointAnnotation() {
  return '''
class CleanDartGenerate {
  const CleanDartGenerate();
}

class Endpoint {
  final String path;
  const Endpoint(this.path);
}

class BaseUrl {
  final String url;
  const BaseUrl(this.url);
}
''';
}
