/// Service for displaying CLI usage information
class UsageService {
  static void printUsage() {
    print('''
Clean Dart Generate - CLI tool for generating Clean Dart architecture code

Usage:
  dart run clean_dart_generate [options]

Options:
  --firestore                Generate Firestore datasources (default)
  --dio                      Generate Dio HTTP datasources
  --http                     Generate native HTTP datasources
  --base-url-override <url>  Override base URL from annotation (annotation has priority by default)
  --help, -h                 Show this help message

Examples:
  dart run clean_dart_generate --firestore
  dart run clean_dart_generate --dio
  dart run clean_dart_generate --http
  dart run clean_dart_generate --dio --base-url-override https://api.example.com
  dart run clean_dart_generate --http --base-url-override https://jsonplaceholder.typicode.com
''');
  }
}
