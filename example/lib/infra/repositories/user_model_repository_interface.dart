import 'package:either_dart/either.dart';
import '../../domain/errors/error.dart';
import '../model/user_model.dart';

abstract class UserModelRepositoryInterface {
  Future<Either<AppError, void>> createUserModel(UserModel model);

  Future<Either<AppError, UserModel>> readUserModel(String id);

  Future<Either<AppError, List<UserModel>>> listAllUserModel();

  Future<Either<AppError, void>> updateUserModel(UserModel model);

  Future<Either<AppError, void>> deleteUserModel(String id);
}
