## 1.0.13

- Added annotations support for code generation control
  - `@CleanDartGenerate()` annotation to mark models for code generation
  - `@Endpoint('/path')` annotation to define custom API endpoints
  - `@BaseUrl('https://...')` annotation to define base URLs
- Added support for multiple datasource types via CLI flags
  - `--firestore` for Firebase Firestore (default)
  - `--dio` for Dio HTTP client
  - `--http` for native HTTP (dart:io)
- Added `--base-url-override` CLI parameter to override base URL from annotations
- Added `listAll` method to repositories and datasources for fetching lists
- Major code refactoring and organization improvements
  - Separated code into modular structure (core/, generators/, services/, models/)
  - Improved separation of concerns and code maintainability
  - Better error handling and validation
- Improved annotation parsing with regex fallback and analyzer support
- Updated documentation with comprehensive annotations section
- Fixed string interpolation issues in generated datasources
- Improved Portuguese comments translated to English

## 1.0.0

- Initial version.
