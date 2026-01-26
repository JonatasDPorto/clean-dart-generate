import 'dart:io';
import 'package:path/path.dart' as p;

/// Service responsible for file and directory operations
class FileGeneratorService {
  /// Ensures a directory exists, creating it if necessary
  void ensureDirectory(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Writes content to a file, creating parent directories if needed
  void writeFile(String filePath, String content) {
    final file = File(filePath);
    final parentDir = p.dirname(filePath);
    ensureDirectory(parentDir);
    file.writeAsStringSync(content);
  }

  /// Checks if a file exists
  bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Gets all Dart files in a directory
  List<File> getDartFiles(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      return [];
    }

    return dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  }
}
