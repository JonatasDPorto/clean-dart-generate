String generateRepositoryInterface(String modelFileName, String modelName) {
  return '''
import '../model/$modelFileName.dart';

abstract class ${modelName}RepositoryInterface {

  Future<Either<AppError, void>> create$modelName($modelName model);

  Future<Either<AppError, $modelName>> read$modelName(String id);

  Future<Either<AppError, void>> update$modelName($modelName model);

  Future<Either<AppError, void>> delete$modelName(String id);
}
''';
}
