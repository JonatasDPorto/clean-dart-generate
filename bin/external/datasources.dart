enum DatasourceType {
  firestore,
  dio,
  http,
}

String generateFirestoreDatasourceClass(
    String modelFileName, String modelName, String? endpoint, String? baseUrl) {
  final collectionName = endpoint != null
      ? endpoint.replaceAll('/', '').replaceAll('@', '')
      : '${modelName.toLowerCase()}s';

  return '''
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import 'interface/datasource.dart';

class ${modelName}Datasource extends DatasourceInterface {

  final CollectionReference collection = FirebaseFirestore.instance.collection('$collectionName');

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

  Future<List<Map<String, dynamic>>> listAll$modelName() async {
    try {
      final querySnapshot = await collection.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to list $modelName: \${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
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

String generateDioDatasourceClass(
    String modelFileName, String modelName, String? endpoint, String? baseUrl) {
  final endpointPath = endpoint ?? '/${modelName.toLowerCase()}s';
  final defaultBaseUrl = baseUrl ?? 'https://api.example.com';

  return '''
import 'package:dio/dio.dart';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../../domain/exceptions/server_exception.dart';
import 'interface/datasource.dart';

class ${modelName}Datasource extends DatasourceInterface {
  final Dio dio;
  final String? baseUrl;

  ${modelName}Datasource({required this.dio, this.baseUrl});

  String get _baseUrl => baseUrl ?? '$defaultBaseUrl';
  String get _endpoint => '$endpointPath';

  Future<void> create$modelName(Map<String, dynamic> data) async {
    try {
      await dio.post('\$_baseUrl\$_endpoint', data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to create $modelName: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Create${modelName}Exception('Failed to create $modelName: \${e.message}');
    } catch (e) {
      throw Create${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<Map<String, dynamic>> read$modelName(String id) async {
    try {
      final response = await dio.get('\$_baseUrl\$_endpoint/\$id');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Read${modelName}Exception('$modelName not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Read${modelName}Exception('$modelName not found');
      }
      if (e.response != null) {
        throw ServerException('Failed to read $modelName: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Read${modelName}Exception('Failed to read $modelName: \${e.message}');
    } catch (e) {
      throw Read${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<List<Map<String, dynamic>>> listAll$modelName() async {
    try {
      final response = await dio.get('\$_baseUrl\$_endpoint');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else if (data is Map<String, dynamic>) {
          return [data];
        }
        return [];
      } else {
        throw ServerException('Failed to list $modelName: \${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to list $modelName: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw ServerException('Failed to list $modelName: \${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<void> update$modelName(Map<String, dynamic> data) async {
    try {
      final id = data['id'];
      if (id == null) {
        throw Update${modelName}Exception('ID is required for update');
      }
      await dio.put('\$_baseUrl\$_endpoint/\$id', data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to update $modelName: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Update${modelName}Exception('Failed to update $modelName: \${e.message}');
    } catch (e) {
      throw Update${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete$modelName(String id) async {
    try {
      await dio.delete('\$_baseUrl\$_endpoint/\$id');
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to delete $modelName: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Delete${modelName}Exception('Failed to delete $modelName: \${e.message}');
    } catch (e) {
      throw Delete${modelName}Exception('Unexpected error: \$e');
    }
  }
}
''';
}

String generateHttpDatasourceClass(
    String modelFileName, String modelName, String? endpoint, String? baseUrl) {
  final endpointPath = endpoint ?? '/${modelName.toLowerCase()}s';
  final defaultBaseUrl = baseUrl ?? 'https://api.example.com';

  return '''
import 'dart:convert';
import 'dart:io';
import '../../domain/exceptions/${modelFileName}_crud_exception.dart';
import '../../domain/exceptions/server_exception.dart';
import 'interface/datasource.dart';

class ${modelName}Datasource extends DatasourceInterface {
  final HttpClient httpClient;
  final String? baseUrl;

  ${modelName}Datasource({HttpClient? httpClient, this.baseUrl})
      : httpClient = httpClient ?? HttpClient();

  String get _baseUrl => baseUrl ?? '$defaultBaseUrl';
  String get _endpoint => '$endpointPath';

  Future<void> create$modelName(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint');
      final request = await httpClient.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(data));
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to create $modelName: \${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Create${modelName}Exception) {
        rethrow;
      }
      throw Create${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<Map<String, dynamic>> read$modelName(String id) async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint/\$id');
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode == 404) {
        throw Read${modelName}Exception('$modelName not found');
      }
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to read $modelName: \${response.statusCode}');
      }
      
      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Read${modelName}Exception) {
        rethrow;
      }
      throw Read${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<List<Map<String, dynamic>>> listAll$modelName() async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint');
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to list $modelName: \${response.statusCode}');
      }
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      
      if (data is List) {
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (data is Map<String, dynamic>) {
        return [data];
      }
      return [];
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<void> update$modelName(Map<String, dynamic> data) async {
    try {
      final id = data['id'];
      if (id == null) {
        throw Update${modelName}Exception('ID is required for update');
      }
      final uri = Uri.parse('\$_baseUrl\$_endpoint/\$id');
      final request = await httpClient.putUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(data));
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to update $modelName: \${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Update${modelName}Exception) {
        rethrow;
      }
      throw Update${modelName}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete$modelName(String id) async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint/\$id');
      final request = await httpClient.deleteUrl(uri);
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to delete $modelName: \${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Delete${modelName}Exception) {
        rethrow;
      }
      throw Delete${modelName}Exception('Unexpected error: \$e');
    }
  }
}
''';
}

String generateDatasourceClass(String modelFileName, String modelName,
    DatasourceType type, String? endpoint, String? baseUrl) {
  switch (type) {
    case DatasourceType.firestore:
      return generateFirestoreDatasourceClass(
          modelFileName, modelName, endpoint, baseUrl);
    case DatasourceType.dio:
      return generateDioDatasourceClass(
          modelFileName, modelName, endpoint, baseUrl);
    case DatasourceType.http:
      return generateHttpDatasourceClass(
          modelFileName, modelName, endpoint, baseUrl);
  }
}

String generateDatasourceInterface() {
  return '''
abstract class DatasourceInterface {
}
''';
}
