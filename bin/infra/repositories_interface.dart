String generateRepositoryInterface(String modelFileName, String modelName) {
  return '''
import '../model/$modelFileName.dart';

abstract class ${modelName}RepositoryInterface {

  Future<void> create$modelName(Map<String, dynamic> data);

  Future<Map<String, dynamic>> read$modelName(String id);

  Future<void> update$modelName(Map<String, dynamic> data);

  Future<void> delete$modelName(String id);
}
''';
}
