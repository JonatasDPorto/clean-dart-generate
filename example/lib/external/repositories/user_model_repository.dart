import 'package:either_dart/either.dart';
import '../../../domain/exceptions/server_exception.dart';
import '../../../domain/errors/error.dart';
import '../../../domain/errors/crud_error.dart';
import '../../../domain/errors/server_error.dart';
import '../../../domain/exceptions/user_model_crud_exception.dart';
import '../../../infra/model/user_model.dart';
import '../../infra/repositories/user_model_repository_interface.dart';
import '../datasources/user_model_datasource.dart';

class UserModelRepository extends UserModelRepositoryInterface {
  final UserModelDatasource datasource;

  UserModelRepository(this.datasource);

    @override
  Future<Either<AppError, void>> createUserModel(UserModel data) async {
    try {
      await datasource.createUserModel(data.toMap());
      return const Right(null);
    } on CreateUserModelException catch (e) {
      return Left(CreateError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<AppError, UserModel>> readUserModel(String id) async {
    try {
      final result = await datasource.readUserModel(id);
      final model = UserModel.fromMap(result);
      return Right(model);
    } on ReadUserModelException catch (e) {
      return Left(ReadError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<AppError, List<UserModel>>> listAllUserModel() async {
    try {
      final results = await datasource.listAllUserModel();
      final models = results.map((data) => UserModel.fromMap(data)).toList();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<AppError, void>> updateUserModel(UserModel data) async {
    try {
      await datasource.updateUserModel(data.toMap());
      return const Right(null);
    } on UpdateUserModelException catch (e) {
      return Left(UpdateError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<AppError, void>> deleteUserModel(String id) async {
    try {
      await datasource.deleteUserModel(id);
      return const Right(null);
    } on DeleteUserModelException catch (e) {
      return Left(DeleteError(e.message));
    } on ServerException catch (e) {
      return Left(ServerError(e.message));
    } catch (e) {
      return Left(AppError('An unknown error occurred: $e'));
    }
  }

}
