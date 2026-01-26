import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

String? extractAnnotationValue(String filePath, String annotationName) {
  try {
    // Convert to absolute path
    final absolutePath = p.isAbsolute(filePath)
        ? filePath
        : p.absolute(Directory.current.path, filePath);

    final file = File(absolutePath);
    if (!file.existsSync()) {
      return null;
    }

    // Read file content to check for annotation
    final content = file.readAsStringSync();

    // Check if annotation exists in file (simple search)
    final annotationPattern =
        RegExp('@$annotationName\\([\'"]?([^\'"]+)[\'"]?\\)');
    final match = annotationPattern.firstMatch(content);
    if (match != null) {
      return match.group(1);
    }

    // If not found by regex, try with analyzer
    // Use project root directory (where pubspec.yaml is located)
    final projectRoot = _findProjectRoot(absolutePath);
    if (projectRoot == null) {
      return null;
    }

    final collection = AnalysisContextCollection(includedPaths: [projectRoot]);
    final context = collection.contextFor(absolutePath);
    final result = context.currentSession.getParsedUnit(absolutePath);

    if (result is ParsedUnitResult) {
      final unit = result.unit;

      for (var declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          for (var metadata in declaration.metadata) {
            // Check if this is the annotation we're looking for (may have import prefix)
            final name = metadata.name.name;
            if (name == annotationName) {
              // Extract argument value
              final arguments = metadata.arguments;
              if (arguments is ArgumentList && arguments.arguments.isNotEmpty) {
                final arg = arguments.arguments.first;
                if (arg is StringLiteral) {
                  return arg.stringValue;
                }
              }
            }
          }
        }
      }
    }
  } catch (e) {
    // If there's an error analyzing, return null and use default
    return null;
  }

  return null;
}

String? _findProjectRoot(String filePath) {
  var current = p.dirname(filePath);
  while (current != p.rootPrefix(current) && current != p.dirname(current)) {
    final pubspec = p.join(current, 'pubspec.yaml');
    if (File(pubspec).existsSync()) {
      return current;
    }
    current = p.dirname(current);
  }
  return Directory.current.path;
}

String? extractEndpointFromModel(String filePath) {
  return extractAnnotationValue(filePath, 'Endpoint');
}

String? extractBaseUrlFromModel(String filePath) {
  return extractAnnotationValue(filePath, 'BaseUrl');
}

bool hasCleanDartGenerateAnnotation(String filePath) {
  try {
    // Convert to absolute path
    final absolutePath = p.isAbsolute(filePath)
        ? filePath
        : p.absolute(Directory.current.path, filePath);

    final file = File(absolutePath);
    if (!file.existsSync()) {
      return false;
    }

    // Read file content to check for annotation
    final content = file.readAsStringSync();

    // Check if annotation exists in file (may or may not have arguments)
    final annotationPattern = RegExp('@CleanDartGenerate\\(?\\)?');
    if (annotationPattern.hasMatch(content)) {
      return true;
    }

    // If not found by regex, try with analyzer
    final projectRoot = _findProjectRoot(absolutePath);
    if (projectRoot == null) {
      return false;
    }

    final collection = AnalysisContextCollection(includedPaths: [projectRoot]);
    final context = collection.contextFor(absolutePath);
    final result = context.currentSession.getParsedUnit(absolutePath);

    if (result is ParsedUnitResult) {
      final unit = result.unit;

      for (var declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          for (var metadata in declaration.metadata) {
            final name = metadata.name.name;
            if (name == 'CleanDartGenerate') {
              return true;
            }
          }
        }
      }
    }
  } catch (e) {
    return false;
  }

  return false;
}
