import 'dart:io';
import 'core/config.dart';
import 'services/code_generation_service.dart';
import 'services/usage_service.dart';

/// Main entry point for the Clean Dart Generate CLI
void main(List<String> arguments) {
  // Handle help flag
  if (arguments.contains('--help') || arguments.contains('-h')) {
    UsageService.printUsage();
    exit(0);
  }

  // Parse configuration from arguments
  final config = CliConfig.fromArguments(arguments);

  // Generate code
  final codeGenService = CodeGenerationService();
  codeGenService.generateAll(config);
}
