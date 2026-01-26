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
