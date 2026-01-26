/// Generator for error classes
class ErrorGenerator {
  /// Generates the base error class
  String generateErrorClass() {
    return '''
class AppError {
  final String message;
  AppError(this.message);
}
''';
  }

  /// Generates the server error class
  String generateServerErrorClass() {
    return '''
import 'error.dart';

class ServerError extends AppError {
  ServerError(super.message);
}
''';
  }

  /// Generates CRUD error classes
  String generateCrudErrorClass() {
    return '''
import 'error.dart';

class CrudError extends AppError {
  CrudError(super.message);
}

class CreateError extends CrudError {
  CreateError(super.message);
}

class ReadError extends CrudError {
  ReadError(super.message);
}

class UpdateError extends CrudError {
  UpdateError(super.message);
}

class DeleteError extends CrudError {
  DeleteError(super.message);
}
''';
  }
}

