String generateDatasourceClass(String modelFileName, String modelName) {
  return '''
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../../infra/model/$modelFileName.dart';
import '../../infra/repositories/${modelFileName}_repository_interface.dart';

class ${modelName}Datasource extends DatasourceInterface {

  final CollectionReference collection = FirebaseFirestore.instance.collection('${modelName.toLowerCase()}s');

  Future<void> create$modelName(Map<String, dynamic> data) async {
    try {
      await collection.add(data);
    } on FirebaseException catch (e) {
      throw Create${modelName}Exception('Failed to create $modelName: \${e.message}');
    } catch (e) {
      throw Create${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<Map<String, dynamic>> read$modelName(String id) async {
    try {
      DocumentSnapshot doc = await collection.doc(id).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Read${modelName}Exception('$modelName not found');
      }
    } on FirebaseException catch (e) {
      throw Read${modelName}Exception('Failed to read $modelName: \${e.message}');
    } catch (e) {
      throw Read${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<void> update$modelName(Map<String, dynamic> data) async {
    try {
      await collection.doc(data['id']).update(data);
    } on FirebaseException catch (e) {
      throw Update${modelName}Exception('Failed to update $modelName: \${e.message}');
    } catch (e) {
      throw Update${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete$modelName(String id) async {
    try {
      await collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Delete${modelName}Exception('Failed to delete $modelName: \${e.message}');
    } catch (e) {
      throw Delete${modelName}Exception('Unexpected error: \$e');
    }
  }
}
''';
}

String generateDatasourceInterface() {
  return '''
abstract class DatasourceInterface {
}
''';
}
