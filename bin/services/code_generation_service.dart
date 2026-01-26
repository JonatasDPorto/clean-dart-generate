import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/config.dart';
import '../generators/annotation_generator.dart';
import '../generators/datasource_generator.dart';
import '../generators/repository_generator.dart';
import '../generators/exception_generator.dart';
import '../generators/error_generator.dart';
import '../models/model_info.dart';
import '../services/file_generator_service.dart';
import '../services/model_discovery_service.dart';

/// Main service that orchestrates code generation
class CodeGenerationService {
  final FileGeneratorService _fileService;
  final ModelDiscoveryService _modelDiscovery;
  final RepositoryGenerator _repositoryGenerator;
  final ExceptionGenerator _exceptionGenerator;
  final ErrorGenerator _errorGenerator;
  final AnnotationGenerator _annotationGenerator;

  CodeGenerationService({
    FileGeneratorService? fileService,
    ModelDiscoveryService? modelDiscovery,
  })  : _fileService = fileService ?? FileGeneratorService(),
        _modelDiscovery = modelDiscovery ?? ModelDiscoveryService(),
        _repositoryGenerator = RepositoryGenerator(),
        _exceptionGenerator = ExceptionGenerator(),
        _errorGenerator = ErrorGenerator(),
        _annotationGenerator = AnnotationGenerator();

  /// Generates all code based on configuration
  void generateAll(CliConfig config) {
    try {
      final models = _modelDiscovery.discoverModels();
      
      _createAnnotationFile();
      _createDatasources(models, config);
      _createRepositories(models);
      _createExceptions(models);
      _createErrors();
      
      print('✓ Code generation completed successfully!');
      print('✓ Generated code for ${models.length} model(s)');
    } on ModelDiscoveryException catch (e) {
      print('Error: ${e.message}');
      exit(1);
    } catch (e) {
      print('Unexpected error: $e');
      exit(1);
    }
  }

  void _createAnnotationFile() {
    final annotationDir = 'lib/domain/annotations';
    _fileService.ensureDirectory(annotationDir);
    
    final endpointFile = p.join(annotationDir, 'endpoint.dart');
    if (!_fileService.fileExists(endpointFile)) {
      _fileService.writeFile(
        endpointFile,
        _annotationGenerator.generateEndpointAnnotation(),
      );
    }
  }

  void _createDatasources(List<ModelInfo> models, CliConfig config) {
    // Create datasource interface
    final interfaceDir = 'lib/external/datasources/interface';
    _fileService.ensureDirectory(interfaceDir);
    _fileService.writeFile(
      p.join(interfaceDir, 'datasource.dart'),
      _generateDatasourceInterface(),
    );

    // Create datasources for each model
    final datasourceDir = 'lib/external/datasources';
    _fileService.ensureDirectory(datasourceDir);
    
    final generator = DatasourceGeneratorFactory.create(config.datasourceType);
    
    for (var model in models) {
      final filePath = p.join(
        datasourceDir,
        '${model.fileName}_datasource.dart',
      );
      _fileService.writeFile(
        filePath,
        generator.generate(model, config.baseUrlOverride),
      );
    }
    
    print('✓ Generated ${config.datasourceType.name} datasources');
  }

  void _createRepositories(List<ModelInfo> models) {
    final externalDir = 'lib/external/repositories';
    final infraDir = 'lib/infra/repositories';
    
    _fileService.ensureDirectory(externalDir);
    _fileService.ensureDirectory(infraDir);

    for (var model in models) {
      // External repository implementation
      _fileService.writeFile(
        p.join(externalDir, '${model.fileName}_repository.dart'),
        _repositoryGenerator.generateRepositoryClass(model),
      );

      // Infrastructure repository interface
      _fileService.writeFile(
        p.join(infraDir, '${model.fileName}_repository_interface.dart'),
        _repositoryGenerator.generateRepositoryInterface(model),
      );
    }
    
    print('✓ Generated repositories');
  }

  void _createExceptions(List<ModelInfo> models) {
    final exceptionDir = 'lib/domain/exceptions';
    _fileService.ensureDirectory(exceptionDir);

    // Create server exception (shared)
    _fileService.writeFile(
      p.join(exceptionDir, 'server_exception.dart'),
      _exceptionGenerator.generateServerException(),
    );

    // Create CRUD exceptions for each model
    for (var model in models) {
      _fileService.writeFile(
        p.join(exceptionDir, '${model.fileName}_crud_exception.dart'),
        _exceptionGenerator.generateCrudException(model),
      );
    }
    
    print('✓ Generated exceptions');
  }

  void _createErrors() {
    final errorDir = 'lib/domain/errors';
    _fileService.ensureDirectory(errorDir);

    _fileService.writeFile(
      p.join(errorDir, 'error.dart'),
      _errorGenerator.generateErrorClass(),
    );
    
    _fileService.writeFile(
      p.join(errorDir, 'crud_error.dart'),
      _errorGenerator.generateCrudErrorClass(),
    );
    
    _fileService.writeFile(
      p.join(errorDir, 'server_error.dart'),
      _errorGenerator.generateServerErrorClass(),
    );
    
    print('✓ Generated errors');
  }

  String _generateDatasourceInterface() {
    return '''
abstract class DatasourceInterface {
}
''';
  }
}

