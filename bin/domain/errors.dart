String generateErrorClass() {
  return '''
class AppError {
  final String message;
  AppError(this.message);
}
''';
}

String generateServerErrorClass() {
  return '''
import 'error.dart';

class ServerError extends AppError {
  ServerError(super.message);
}
''';
}

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
