import '../core/config.dart';
import '../models/model_info.dart';

/// Base class for datasource generators
abstract class DatasourceGenerator {
  String generate(ModelInfo model, String? baseUrlOverride);
}

/// Generator for Firestore datasources
class FirestoreDatasourceGenerator implements DatasourceGenerator {
  @override
  String generate(ModelInfo model, String? baseUrlOverride) {
    final collectionName = model.getCollectionName();

    return '''
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/exceptions/${model.fileName}_crud_exception.dart';
import 'interface/datasource.dart';

class ${model.className}Datasource extends DatasourceInterface {
  final CollectionReference collection = FirebaseFirestore.instance.collection('$collectionName');

  Future<void> create${model.className}(Map<String, dynamic> data) async {
    try {
      await collection.add(data);
    } on FirebaseException catch (e) {
      throw Create${model.className}Exception('Failed to create ${model.className}: \${e.message}');
    } catch (e) {
      throw Create${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<Map<String, dynamic>> read${model.className}(String id) async {
    try {
      DocumentSnapshot doc = await collection.doc(id).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Read${model.className}Exception('${model.className} not found');
      }
    } on FirebaseException catch (e) {
      throw Read${model.className}Exception('Failed to read ${model.className}: \${e.message}');
    } catch (e) {
      throw Read${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<List<Map<String, dynamic>>> listAll${model.className}() async {
    try {
      final querySnapshot = await collection.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to list ${model.className}: \${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<void> update${model.className}(Map<String, dynamic> data) async {
    try {
      await collection.doc(data['id']).update(data);
    } on FirebaseException catch (e) {
      throw Update${model.className}Exception('Failed to update ${model.className}: \${e.message}');
    } catch (e) {
      throw Update${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete${model.className}(String id) async {
    try {
      await collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Delete${model.className}Exception('Failed to delete ${model.className}: \${e.message}');
    } catch (e) {
      throw Delete${model.className}Exception('Unexpected error: \$e');
    }
  }
}
''';
  }
}

/// Generator for Dio datasources
class DioDatasourceGenerator implements DatasourceGenerator {
  @override
  String generate(ModelInfo model, String? baseUrlOverride) {
    final endpointPath = model.getEndpointPath();
    final baseUrl = model.getBaseUrl(baseUrlOverride);

    return '''
import 'package:dio/dio.dart';
import '../../domain/exceptions/${model.fileName}_crud_exception.dart';
import '../../domain/exceptions/server_exception.dart';
import 'interface/datasource.dart';

class ${model.className}Datasource extends DatasourceInterface {
  final Dio dio;
  final String? baseUrl;

  ${model.className}Datasource({required this.dio, this.baseUrl});

  String get _baseUrl => baseUrl ?? '$baseUrl';
  String get _endpoint => '$endpointPath';

  ${_generateCrudMethods(model)}
}
''';
  }

  String _generateCrudMethods(ModelInfo model) {
    return '''
  Future<void> create${model.className}(Map<String, dynamic> data) async {
    try {
      await dio.post('\$_baseUrl\$_endpoint', data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to create ${model.className}: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Create${model.className}Exception('Failed to create ${model.className}: \${e.message}');
    } catch (e) {
      throw Create${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<Map<String, dynamic>> read${model.className}(String id) async {
    try {
      final response = await dio.get('\$_baseUrl\$_endpoint/\$id');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Read${model.className}Exception('${model.className} not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Read${model.className}Exception('${model.className} not found');
      }
      if (e.response != null) {
        throw ServerException('Failed to read ${model.className}: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Read${model.className}Exception('Failed to read ${model.className}: \${e.message}');
    } catch (e) {
      throw Read${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<List<Map<String, dynamic>>> listAll${model.className}() async {
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
        throw ServerException('Failed to list ${model.className}: \${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to list ${model.className}: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw ServerException('Failed to list ${model.className}: \${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<void> update${model.className}(Map<String, dynamic> data) async {
    try {
      final id = data['id'];
      if (id == null) {
        throw Update${model.className}Exception('ID is required for update');
      }
      await dio.put('\$_baseUrl\$_endpoint/\$id', data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to update ${model.className}: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Update${model.className}Exception('Failed to update ${model.className}: \${e.message}');
    } catch (e) {
      throw Update${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete${model.className}(String id) async {
    try {
      await dio.delete('\$_baseUrl\$_endpoint/\$id');
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException('Failed to delete ${model.className}: \${e.response?.statusCode} - \${e.response?.data}');
      }
      throw Delete${model.className}Exception('Failed to delete ${model.className}: \${e.message}');
    } catch (e) {
      throw Delete${model.className}Exception('Unexpected error: \$e');
    }
  }
''';
  }
}

/// Generator for native HTTP datasources
class HttpDatasourceGenerator implements DatasourceGenerator {
  @override
  String generate(ModelInfo model, String? baseUrlOverride) {
    final endpointPath = model.getEndpointPath();
    final baseUrl = model.getBaseUrl(baseUrlOverride);

    return '''
import 'dart:convert';
import 'dart:io';
import '../../domain/exceptions/${model.fileName}_crud_exception.dart';
import '../../domain/exceptions/server_exception.dart';
import 'interface/datasource.dart';

class ${model.className}Datasource extends DatasourceInterface {
  final HttpClient httpClient;
  final String? baseUrl;

  ${model.className}Datasource({HttpClient? httpClient, this.baseUrl})
      : httpClient = httpClient ?? HttpClient();

  String get _baseUrl => baseUrl ?? '$baseUrl';
  String get _endpoint => '$endpointPath';

  ${_generateCrudMethods(model)}
}
''';
  }

  String _generateCrudMethods(ModelInfo model) {
    return '''
  Future<void> create${model.className}(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint');
      final request = await httpClient.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(data));
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to create ${model.className}: \${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Create${model.className}Exception) {
        rethrow;
      }
      throw Create${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<Map<String, dynamic>> read${model.className}(String id) async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint/\$id');
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode == 404) {
        throw Read${model.className}Exception('${model.className} not found');
      }
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to read ${model.className}: \${response.statusCode}');
      }
      
      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Read${model.className}Exception) {
        rethrow;
      }
      throw Read${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<List<Map<String, dynamic>>> listAll${model.className}() async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint');
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to list ${model.className}: \${response.statusCode}');
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

  Future<void> update${model.className}(Map<String, dynamic> data) async {
    try {
      final id = data['id'];
      if (id == null) {
        throw Update${model.className}Exception('ID is required for update');
      }
      final uri = Uri.parse('\$_baseUrl\$_endpoint/\$id');
      final request = await httpClient.putUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(data));
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to update ${model.className}: \${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Update${model.className}Exception) {
        rethrow;
      }
      throw Update${model.className}Exception('Unexpected error: \$e');
    }
  }

  Future<void> delete${model.className}(String id) async {
    try {
      final uri = Uri.parse('\$_baseUrl\$_endpoint/\$id');
      final request = await httpClient.deleteUrl(uri);
      final response = await request.close();
      
      if (response.statusCode >= 400) {
        throw ServerException('Failed to delete ${model.className}: \${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw ServerException('Network error: \${e.message}');
    } catch (e) {
      if (e is ServerException || e is Delete${model.className}Exception) {
        rethrow;
      }
      throw Delete${model.className}Exception('Unexpected error: \$e');
    }
  }
''';
  }
}

/// Factory for creating datasource generators
class DatasourceGeneratorFactory {
  static DatasourceGenerator create(DatasourceType type) {
    switch (type) {
      case DatasourceType.firestore:
        return FirestoreDatasourceGenerator();
      case DatasourceType.dio:
        return DioDatasourceGenerator();
      case DatasourceType.http:
        return HttpDatasourceGenerator();
    }
  }
}

