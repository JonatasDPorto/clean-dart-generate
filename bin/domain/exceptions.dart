String generateCrudExceptionClass(String modelName) {
  return '''
class CrudException implements Exception {
  final String message;

  CrudException(this.message);
}

class Create${modelName}Exception extends CrudException {
  Create${modelName}Exception(super.message);
}

class Read${modelName}Exception extends CrudException {
  Read${modelName}Exception(super.message);
}

class Update${modelName}Exception extends CrudException {
  Update${modelName}Exception(super.message);
}

class Delete${modelName}Exception extends CrudException {
  Delete${modelName}Exception(super.message);
}
''';
}

String generateServerExceptionClass() {
  return '''
class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}
''';
}
