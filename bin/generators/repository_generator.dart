import '../models/model_info.dart';

/// Generator for repository classes and interfaces
class RepositoryGenerator {
  /// Generates the repository implementation class
  String generateRepositoryClass(ModelInfo model) {
    return '''
import 'package:either_dart/either.dart';
import '../../../domain/exceptions/server_exception.dart';
import '../../../domain/errors/error.dart';
import '../../../domain/errors/crud_error.dart';
import '../../../domain/errors/server_error.dart';
import '../../../domain/exceptions/${model.fileName}_crud_exception.dart';
import '../../../infra/model/${model.fileName}.dart';
import '../../infra/repositories/${model.fileName}_repository_interface.dart';
import '../datasources/${model.fileName}_datasource.dart';

class ${model.className}Repository extends ${model.className}RepositoryInterface {
  final ${model.className}Datasource datasource;

  ${model.className}Repository(this.datasource);

  ${_generateRepositoryMethods(model)}
}
''';
  }

  /// Generates the repository interface
  String generateRepositoryInterface(ModelInfo model) {
    return '''
import 'package:either_dart/either.dart';
import '../../domain/errors/error.dart';
import '../model/${model.fileName}.dart';

abstract class ${model.className}RepositoryInterface {
  Future<Either<AppError, void>> create${model.className}(${model.className} model);

  Future<Either<AppError, ${model.className}>> read${model.className}(String id);

  Future<Either<AppError, List<${model.className}>>> listAll${model.className}();

  Future<Either<AppError, void>> update${model.className}(${model.className} model);

  Future<Either<AppError, void>> delete${model.className}(String id);
}
''';
  }

  String _generateRepositoryMethods(ModelInfo model) {
    return '''
  @override
  Future<Either<AppError, void>> create${model.className}(${model.className} data) async {
    try {
      await datasource.create${model.className}(data.toMap());
      return const Right(null);
    } on Create${model.className}Exception catch (e) {
      return Left(CreateError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  @override
  Future<Either<AppError, ${model.className}>> read${model.className}(String id) async {
    try {
      final result = await datasource.read${model.className}(id);
      final model = ${model.className}.fromMap(result);
      return Right(model);
    } on Read${model.className}Exception catch (e) {
      return Left(ReadError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  @override
  Future<Either<AppError, List<${model.className}>>> listAll${model.className}() async {
    try {
      final results = await datasource.listAll${model.className}();
      final models = results.map((data) => ${model.className}.fromMap(data)).toList();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  @override
  Future<Either<AppError, void>> update${model.className}(${model.className} data) async {
    try {
      await datasource.update${model.className}(data.toMap());
      return const Right(null);
    } on Update${model.className}Exception catch (e) {
      return Left(UpdateError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }

  @override
  Future<Either<AppError, void>> delete${model.className}(String id) async {
    try {
      await datasource.delete${model.className}(id);
      return const Right(null);
    } on Delete${model.className}Exception catch (e) {
      return Left(DeleteError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: \$e'));
    }
  }
''';
  }
}

