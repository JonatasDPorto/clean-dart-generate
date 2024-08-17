import 'dart:io';
import 'package:path/path.dart' as p;
import 'extensions.dart';
import 'external/repositories.dart';
import 'domain/errors.dart';
import 'domain/exceptions.dart';
import 'external/datasources.dart';
import 'infra/repositories_interface.dart';

void main(List<String> arguments) {
  createDatasource();
  createRepository();
  createExceptions();
  createServerException();
  createErrors();
}

void forEachModel(
    void Function(String modelFileName, String modelName) callback) {
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
      callback(modelFileName, modelName);
    }
  }
}

void createDatasource() {
  final baseDir = 'lib/external';

  final dir = Directory(p.join(baseDir, 'datasources/interface'));
  dir.createSync(recursive: true);
  final file = File(p.join(dir.path, 'datasource.dart'));
  file.writeAsStringSync(generateDatasourceInterface());

  final eachDir = Directory(p.join(baseDir, 'datasources'));
  eachDir.createSync(recursive: true);
  forEachModel((modelFileName, modelName) {
    final file = File(p.join(dir.path, '${modelFileName}_datasource.dart'));
    file.writeAsStringSync(generateDatasourceClass(modelFileName, modelName));
  });
}

void createRepository() {
  final externalDir = Directory(p.join('lib/external', 'repositories'));
  externalDir.createSync(recursive: true);

  final infraDir = Directory(p.join('lib/infra', 'repositories'));
  infraDir.createSync(recursive: true);

  forEachModel((modelFileName, modelName) {
    final externalFile = File(
      p.join(infraDir.path, '${modelFileName}_repository.dart'),
    );
    externalFile.writeAsStringSync(
      generateRepositoryClass(modelFileName, modelName),
    );

    final infraFile = File(
      p.join(infraDir.path, '${modelFileName}_repository_interface.dart'),
    );
    infraFile.writeAsStringSync(
      generateRepositoryInterface(modelFileName, modelName),
    );
  });
}

void createExceptions() {
  final exceptionDir = Directory('lib/domain/exceptions');

  if (!exceptionDir.existsSync()) {
    exceptionDir.createSync(recursive: true);
  }

  forEachModel((modelFileName, modelName) {
    final crudExceptionFile =
        File(p.join(exceptionDir.path, '${modelFileName}_crud_exception.dart'));

    crudExceptionFile.writeAsStringSync(generateCrudExceptionClass(modelName));
  });
}

void createServerException() {
  final exceptionDir = Directory('lib/domain/exceptions');

  if (!exceptionDir.existsSync()) {
    exceptionDir.createSync(recursive: true);
  }

  final serverExceptionFile =
      File(p.join(exceptionDir.path, 'server_exception.dart'));

  serverExceptionFile.writeAsStringSync(generateServerExceptionClass());
}

void createErrors() {
  final exceptionDir = Directory('lib/domain/errors');

  if (!exceptionDir.existsSync()) {
    exceptionDir.createSync(recursive: true);
  }

  final errorFile = File(p.join(exceptionDir.path, 'error.dart'));

  final crudErrorFile = File(p.join(exceptionDir.path, 'crud_error.dart'));
  final serverErrorFile = File(p.join(exceptionDir.path, 'server_error.dart'));
  errorFile.writeAsStringSync(generateErrorClass());
  crudErrorFile.writeAsStringSync(generateCrudErrorClass());
  serverErrorFile.writeAsStringSync(generateServerErrorClass());
}
