String generateRepositoryClass(String modelFileName, String modelName) {
  return '''
import 'package:dart_either/dart_either.dart';
import 'package:barber_shop/domain/exceptions/server_exception.dart';
import '../../../domain/errors/error.dart';
import '../../../domain/errors/crud_error.dart';
import '../../../domain/errors/server_error.dart';
import '../../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../../../infra/model/$modelFileName.dart';

class ${modelName}Repository extends ${modelName}RepositoryInterface {
  final ${modelName}DatasourceInterface datasource;

  ${modelName}Datasource(this.datasource);

  Future<Either<AppError, void>> create$modelName($modelName data) async {
    try {
      await datasource.create$modelName(data.toMap());
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
      final result = await datasource.read$modelName(id);
      final model = $modelName.fromMap(result);
      return Right(model);
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
      await datasource.update$modelName(data.toMap());
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
      await datasource.delete$modelName(id);
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
