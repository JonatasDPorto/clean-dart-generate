String generateRepositoryInterface(String modelFileName, String modelName) {
  return '''
import '../model/$modelFileName.dart';

abstract class ${modelName}RepositoryInterface {
  final Dio dio;

  ${modelName}RepositoryInterface(this.dio);

  Future<void> create$modelName(Map<String, dynamic> data);

  Future<$modelName> read$modelName(String id);

  Future<void> update$modelName(Map<String, dynamic> data);

  Future<void> delete$modelName(String id);
}
''';
}
