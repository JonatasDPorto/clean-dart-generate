import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/model_info.dart';
import '../utils/annotation_parser.dart';
import '../extensions.dart';

/// Service responsible for discovering and parsing model files
class ModelDiscoveryService {
  static const String _modelDirectory = 'lib/infra/model';

  /// Finds all models that should have code generated
  List<ModelInfo> discoverModels() {
    final modelDirectory = Directory(_modelDirectory);

    if (!modelDirectory.existsSync()) {
      throw ModelDiscoveryException(
        'Model directory does not exist: $_modelDirectory',
      );
    }

    final modelFiles = modelDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    if (modelFiles.isEmpty) {
      throw ModelDiscoveryException(
        'No model files found in $_modelDirectory',
      );
    }

    final models = <ModelInfo>[];

    for (var file in modelFiles) {
      // Only process files with @CleanDartGenerate() annotation
      if (!hasCleanDartGenerateAnnotation(file.path)) {
        continue;
      }

      final fileName = p.basenameWithoutExtension(file.path);
      final className = _convertFileNameToClassName(fileName);
      final endpoint = extractEndpointFromModel(file.path);
      final baseUrl = extractBaseUrlFromModel(file.path);

      models.add(ModelInfo(
        fileName: fileName,
        className: className,
        endpoint: endpoint,
        baseUrl: baseUrl,
      ));
    }

    if (models.isEmpty) {
      throw ModelDiscoveryException(
        'No models found with @CleanDartGenerate() annotation',
      );
    }

    return models;
  }

  /// Converts snake_case file name to PascalCase class name
  String _convertFileNameToClassName(String fileName) {
    return fileName
        .split('_')
        .map((part) => part.capitalize())
        .join();
  }
}

/// Exception thrown when model discovery fails
class ModelDiscoveryException implements Exception {
  final String message;
  ModelDiscoveryException(this.message);

  @override
  String toString() => 'ModelDiscoveryException: $message';
}

