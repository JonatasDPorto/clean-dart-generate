import 'dart:io';
import 'package:path/path.dart' as p;
import 'extensions.dart';

void main(List<String> arguments) {
  final modelDirectory = Directory('lib/infra/model');

  if (!modelDirectory.existsSync()) {
    print('Error: Model directory does not exist.');
    return;
  }

  final modelFiles =
      modelDirectory.listSync().where((file) => file.path.endsWith('.dart'));

  if (modelFiles.isEmpty) {
    print('No model files found in ${modelDirectory.path}');
    return;
  }

  for (var file in modelFiles) {
    if (file is File) {
      final modelFileName = p.basenameWithoutExtension(file.path);
      final modelName =
          modelFileName.split("_").map((e) => e.capitalize()).join();
      _createRepositoryAndController(modelFileName, modelName);
      _createExceptions(modelFileName, modelName);
    }
  }
  _createServerException();
  _createErrors();
}

void _createRepositoryAndController(String modelFileName, String modelName) {
  final baseDir = 'lib/infra';
  final repositoryDir = Directory(p.join(baseDir, 'repositories'));
  final controllerDir = Directory(p.join(baseDir, 'controllers'));

  repositoryDir.createSync(recursive: true);
  controllerDir.createSync(recursive: true);

  final repositoryFile =
      File(p.join(repositoryDir.path, '${modelFileName}_repository.dart'));
  final controllerFile =
      File(p.join(controllerDir.path, '${modelFileName}_controller.dart'));

  repositoryFile
      .writeAsStringSync(_generateRepositoryClass(modelFileName, modelName));
  controllerFile
      .writeAsStringSync(_generateControllerClass(modelFileName, modelName));

  print('Generated files for model "$modelName":');
  print(' - ${repositoryFile.path}');
  print(' - ${controllerFile.path}');
}

void _createExceptions(String modelFileName, String modelName) {
  final exceptionDir = Directory('lib/domain/exceptions');

  if (!exceptionDir.existsSync()) {
    exceptionDir.createSync(recursive: true);
  }

  final crudExceptionFile =
      File(p.join(exceptionDir.path, '${modelFileName}_crud_exception.dart'));

  crudExceptionFile.writeAsStringSync(_generateCrudExceptionClass(modelName));

  print('Generated exception files for model "$modelName":');
  print(' - ${crudExceptionFile.path}');
}

void _createServerException() {
  final exceptionDir = Directory('lib/domain/exceptions');

  if (!exceptionDir.existsSync()) {
    exceptionDir.createSync(recursive: true);
  }

  final serverExceptionFile =
      File(p.join(exceptionDir.path, 'server_exception.dart'));

  serverExceptionFile.writeAsStringSync(_generateServerExceptionClass());

  print(' - ${serverExceptionFile.path}');
}

void _createErrors() {
  final exceptionDir = Directory('lib/domain/errors');

  if (!exceptionDir.existsSync()) {
    exceptionDir.createSync(recursive: true);
  }

  final errorFile = File(p.join(exceptionDir.path, 'error.dart'));

  final crudErrorFile = File(p.join(exceptionDir.path, 'crud_error.dart'));
  final serverErrorFile = File(p.join(exceptionDir.path, 'server_error.dart'));
  errorFile.writeAsStringSync(_generateErrorClass());
  crudErrorFile.writeAsStringSync(_generateCrudErrorClass());
  serverErrorFile.writeAsStringSync(_generateServerErrorClass());

  print('Generated errors files:');
  print(' - ${crudErrorFile.path}');
  print(' - ${serverErrorFile.path}');
}

String _generateRepositoryClass(String modelFileName, String modelName) {
  return '''
import 'package:dio/dio.dart';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../model/$modelFileName.dart';

class ${modelName}Repository {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://my-api/"));

  Future<void> create$modelName(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$modelFileName', data: data);
      if (response.statusCode != 201) {
        throw Create${modelName}Exception('Failed to create $modelName');
      }
    } on DioException catch (e) {
      throw Create${modelName}Exception('Failed to create $modelName: \${e.message}');
    } catch (e) {
      throw Create${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<$modelName> read$modelName(String id) async {
    try {
      final response = await _dio.get('$modelFileName/\$id');
      if (response.statusCode == 200) {
        return $modelName.fromJson(response.data);
      } else {
        throw Read${modelName}Exception('Failed to read $modelName');
      }
    } on DioException catch (e) {
      throw Read${modelName}Exception('Failed to read $modelName: \${e.message}');
    } catch (e) {
      throw Read${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<void> update$modelName(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$modelFileName/\${data["id"]}', data: data);
      if (response.statusCode != 200) {
        throw Update${modelName}Exception('Failed to update $modelName');
      }
    } on DioException catch (e) {
      throw Update${modelName}Exception('Failed to update $modelName: \${e.message}');
    } catch (e) {
      throw Update${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete$modelName(String id) async {
    try {
      final response = await _dio.delete('$modelFileName/\$id');
      if (response.statusCode != 200) {
        throw Delete${modelName}Exception('Failed to delete $modelName');
      }
    } on DioException catch (e) {
      throw Delete${modelName}Exception('Failed to delete $modelName: \${e.message}');
    } catch (e) {
      throw Delete${modelName}Exception('Unexpected error: \$e');
    }
  }
}
''';
}

String _generateControllerClass(String modelFileName, String modelName) {
  return '''
import 'package:barber_shop/domain/exceptions/server_exception.dart';
import '../../domain/errors/error.dart';
import '../repositories/${modelFileName}_repository.dart';
import 'package:dart_either/dart_either.dart';
import '../../domain/errors/crud_error.dart';
import '../../domain/errors/server_error.dart';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../model/$modelFileName.dart';

class ${modelName}Controller {
  final ${modelName}Repository repository;

  ${modelName}Controller(this.repository);

  Future<Either<AppError, void>> create$modelName($modelName data) async {
    try {
      await repository.create$modelName(data.toMap());
      return const Right(null);
    } on Create${modelName}Exception catch (e) {
      return Left(CreateError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  Future<Either<AppError, $modelName>> read$modelName(String id) async {
    try {
      final result = await repository.read$modelName(id);
      return Right(result);
    } on Read${modelName}Exception catch (e) {
      return Left(ReadError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  Future<Either<AppError, void>> update$modelName($modelName data) async {
    try {
      await repository.update$modelName(data.toMap());
      return const Right(null);
    } on Update${modelName}Exception catch (e) {
      return Left(UpdateError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  Future<Either<AppError, void>> delete$modelName(String id) async {
    try {
      await repository.delete$modelName(id);
      return const Right(null);
    } on Delete${modelName}Exception catch (e) {
      return Left(DeleteError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }
}
''';
}

String _generateCrudExceptionClass(String modelName) {
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

String _generateServerExceptionClass() {
  return '''
class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}
''';
}

String _generateErrorClass() {
  return '''
class AppError {
  final String message;
  AppError(this.message);
}
''';
}

String _generateServerErrorClass() {
  return '''
import 'error.dart';

class ServerError extends AppError {
  ServerError(super.message);
}
''';
}

String _generateCrudErrorClass() {
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
