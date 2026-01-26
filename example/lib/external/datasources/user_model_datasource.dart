import 'package:dio/dio.dart';
import '../../domain/exceptions/user_model_crud_exception.dart';
import '../../domain/exceptions/server_exception.dart';
import 'interface/datasource.dart';

class UserModelDatasource extends DatasourceInterface {
  final Dio dio;
  final String? baseUrl;

  UserModelDatasource({required this.dio, this.baseUrl});

  String get _baseUrl => baseUrl ?? 'https://jsonplaceholder.typicode.com/';
  String get _endpoint => '/users';

    Future<void> createUserModel(Map<String, dynamic> data) async {
    try {
      await dio.post('$_baseUrl$_endpoint', data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to create UserModel: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw CreateUserModelException('Failed to create UserModel: ${e.message}');
    } catch (e) {
      throw CreateUserModelException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> readUserModel(String id) async {
    try {
      final response = await dio.get('$_baseUrl$_endpoint/$id');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ReadUserModelException('UserModel not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ReadUserModelException('UserModel not found');
      }
      if (e.response != null) {
        throw ServerException('Failed to read UserModel: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw ReadUserModelException('Failed to read UserModel: ${e.message}');
    } catch (e) {
      throw ReadUserModelException('Unexpected error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listAllUserModel() async {
    try {
      final response = await dio.get('$_baseUrl$_endpoint');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else if (data is Map<String, dynamic>) {
          return [data];
        }
        return [];
      } else {
        throw ServerException('Failed to list UserModel: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to list UserModel: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw ServerException('Failed to list UserModel: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<void> updateUserModel(Map<String, dynamic> data) async {
    try {
      final id = data['id'];
      if (id == null) {
        throw UpdateUserModelException('ID is required for update');
      }
      await dio.put('$_baseUrl$_endpoint/$id', data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to update UserModel: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw UpdateUserModelException('Failed to update UserModel: ${e.message}');
    } catch (e) {
      throw UpdateUserModelException('Unexpected error: $e');
    }
  }

  Future<void> deleteUserModel(String id) async {
    try {
      await dio.delete('$_baseUrl$_endpoint/$id');
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to delete UserModel: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw DeleteUserModelException('Failed to delete UserModel: ${e.message}');
    } catch (e) {
      throw DeleteUserModelException('Unexpected error: $e');
    }
  }

}
