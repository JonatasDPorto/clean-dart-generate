import '../models/model_info.dart';

/// Generator for exception classes
class ExceptionGenerator {
  /// Generates CRUD exception classes for a model
  String generateCrudException(ModelInfo model) {
    return '''
class CrudException implements Exception {
  final String message;

  CrudException(this.message);
}

class Create${model.className}Exception extends CrudException {
  Create${model.className}Exception(super.message);
}

class Read${model.className}Exception extends CrudException {
  Read${model.className}Exception(super.message);
}

class Update${model.className}Exception extends CrudException {
  Update${model.className}Exception(super.message);
}

class Delete${model.className}Exception extends CrudException {
  Delete${model.className}Exception(super.message);
}
''';
  }

  /// Generates the server exception class (shared across all models)
  String generateServerException() {
    return '''
class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}
''';
  }
}

