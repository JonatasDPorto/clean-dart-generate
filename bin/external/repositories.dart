String generateRepositoryClass(String modelFileName, String modelName) {
  return '''
import 'package:dio/dio.dart';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../model/$modelFileName.dart';

class ${modelName}Repository extends ${modelName}RepositoryInterface {
  ${modelName}Repository(super.dio);

  @override
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

  @override
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

  @override
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

  @override
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
