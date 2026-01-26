class CrudException implements Exception {
  final String message;

  CrudException(this.message);
}

class CreateUserModelException extends CrudException {
  CreateUserModelException(super.message);
}

class ReadUserModelException extends CrudException {
  ReadUserModelException(super.message);
}

class UpdateUserModelException extends CrudException {
  UpdateUserModelException(super.message);
}

class DeleteUserModelException extends CrudException {
  DeleteUserModelException(super.message);
}
