# Clean Dart Generate

[![pub.dev](https://img.shields.io/pub/v/clean_dart_generate.svg)](https://pub.dev/packages/clean_dart_generate)
[![Dart SDK](https://img.shields.io/badge/Dart%20SDK-%5E3.5.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![pub points](https://img.shields.io/pub/points/clean_dart_generate)](https://pub.dev/packages/clean_dart_generate/score)

**Available on [pub.dev](https://pub.dev/packages/clean_dart_generate)**

**Clean Dart Generate** is a CLI (Command Line Interface) tool that automates code generation following the [Clean Dart](https://github.com/Flutterando/Clean-Dart) architecture principles proposed by [Flutterando](https://github.com/Flutterando). This tool facilitates the creation of datasources, repositories, exceptions, and errors for your models, saving time and ensuring consistency in your Flutter project structure.

> **Learn more about Clean Dart architecture**: [github.com/Flutterando/Clean-Dart](https://github.com/Flutterando/Clean-Dart)

## Features

- **Automatic Generation**: Automatically creates all necessary classes based on existing models
- **Clean Architecture**: Follows the [Clean Dart](https://github.com/Flutterando/Clean-Dart) architecture principles from Flutterando
- **Firebase Firestore**: Generates datasources ready to use with Firebase Firestore
- **Either Pattern**: Implements the Either pattern for functional error handling
- **Error Handling**: Generates structured exceptions and errors for each CRUD operation
- **Organized Structure**: Automatically creates the necessary folder structure

## Prerequisites

- Dart SDK >= 3.5.0
- Flutter (for Flutter projects)
- Models created in `lib/infra/model/`

## Required Dependencies

Before using the generated code, you **must** add the following dependencies to your `pubspec.yaml`:

**Mandatory (always required):**

```yaml
dependencies:
  either_dart: ^latest_version  # Required for Either pattern in repositories
```

**Datasource-specific dependencies (choose based on your datasource type):**

- **Firestore** (default):

  ```yaml
  dependencies:
    cloud_firestore: ^latest_version
  ```
- **Dio**:

  ```yaml
  dependencies:
    dio: ^latest_version
  ```
- **HTTP (native)**:

  ```yaml
  # No additional dependencies needed - uses dart:io
  ```

**Important Notes:**

- `either_dart` is **mandatory** - it's used in all repository interfaces and implementations for functional error handling with the Either pattern
- Choose the datasource dependency based on which datasource type you'll use
- Make sure to run `flutter pub get` after adding these dependencies

## Installation

### Global Installation (Recommended)

```bash
dart pub global activate clean_dart_generate
```

After installing globally, you can run the CLI from anywhere:

```bash
dart run clean_dart_generate
```

### Local Installation (via pub.dev)

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  clean_dart_generate: ^1.0.13
```

Then run:

```bash
dart pub get
```

## Usage

### Step 1: Prepare Your Models

Make sure your models are in the `lib/infra/model/` folder and follow the snake_case naming convention (e.g., `user_model.dart`, `product_model.dart`).

**Important:** Only models marked with the `@CleanDartGenerate()` annotation will have code generated. This allows you to control which models should generate repositories, datasources, and exceptions.

**Example model (`lib/infra/model/user_model.dart`):**

```dart
import 'package:your_app/domain/annotations/endpoint.dart';

@CleanDartGenerate()
@BaseUrl('https://jsonplaceholder.typicode.com')
@Endpoint('/users')
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
```

### Annotations

The CLI uses annotations to configure code generation. These annotations are automatically created in `lib/domain/annotations/endpoint.dart` when you first run the CLI.

#### Available Annotations

**1. `@CleanDartGenerate()`** (Required)

Marks a model for code generation. Only models with this annotation will have repositories, datasources, and exceptions generated.

```dart
@CleanDartGenerate()
class UserModel {
  // ...
}
```

**2. `@Endpoint('/path')`** (Optional)

Defines a custom endpoint path for HTTP datasources (Dio or HTTP). If not specified, the default pattern `/modelnames` is used.

```dart
@CleanDartGenerate()
@Endpoint('/users')
class UserModel {
  // ...
}
```

**For Firestore:** The endpoint is used as the collection name (without slashes).

**3. `@BaseUrl('https://api.example.com')`** (Optional)

Defines the base URL for HTTP datasources (Dio or HTTP). If not specified, defaults to `https://api.example.com`.

```dart
@CleanDartGenerate()
@BaseUrl('https://jsonplaceholder.typicode.com')
@Endpoint('/users')
class UserModel {
  // ...
}
```

#### Annotation Priority

The priority order for base URL resolution is:

1. **Annotation** (`@BaseUrl`) - Highest priority
2. **CLI Override** (`--base-url-override`) - Use `--base-url-override` to explicitly override the annotation
3. **Default** (`https://api.example.com`) - Lowest priority

**Example with CLI override:**

```bash
# Annotation @BaseUrl('https://api.example.com') will be used
dart run clean_dart_generate --dio

# CLI override will be used instead of annotation
dart run clean_dart_generate --dio --base-url-override https://custom.api.com
```

#### Complete Annotation Example

```dart
import 'package:your_app/domain/annotations/endpoint.dart';

@CleanDartGenerate()
@BaseUrl('https://jsonplaceholder.typicode.com')
@Endpoint('/users')
class UserModel {
  // Model implementation
}
```

**Notes:**
- The `@CleanDartGenerate()` annotation is **mandatory** for code generation
- `@Endpoint` and `@BaseUrl` are optional but recommended for HTTP datasources
- For Firestore, only `@Endpoint` affects the collection name
- The annotation file is automatically created in `lib/domain/annotations/endpoint.dart` on first run

### Step 2: Run the CLI

At the root of your Flutter project, run:

```bash
# If installed globally (recommended)
dart run clean_dart_generate [--firestore|--dio|--http] [--base-url-override <url>]

# Or if installed locally via pub.dev
dart run clean_dart_generate [--firestore|--dio|--http] [--base-url-override <url>]
```

**Datasource Options:**

- `--firestore` (default): Generates Firebase Firestore datasources
- `--dio`: Generates Dio HTTP client datasources
- `--http`: Generates native HTTP (dart:io) datasources
- `--base-url-override <url>`: Overrides the base URL from annotation (annotation has priority by default)
- `--help` or `-h`: Shows help message

**Examples:**

```bash
# Generate Firestore datasources (default)
dart run clean_dart_generate --firestore

# Generate Dio datasources
dart run clean_dart_generate --dio

# Generate native HTTP datasources
dart run clean_dart_generate --http

# Generate Dio datasources with custom base URL override
dart run clean_dart_generate --dio --base-url-override https://api.example.com

# Generate HTTP datasources with custom base URL override
dart run clean_dart_generate --http --base-url-override https://jsonplaceholder.typicode.com

# Show help
dart run clean_dart_generate --help
```

### Step 3: Use the Generated Classes

The CLI will automatically generate all necessary classes. You can start using them immediately!

## Generated Structure

The CLI generates the following file structure based on models found in `lib/infra/model/`:

```
lib/
├── domain/
│   ├── errors/
│   │   ├── error.dart                    # Base AppError class
│   │   ├── crud_error.dart               # CRUD errors (Create, Read, Update, Delete)
│   │   └── server_error.dart             # Server errors
│   └── exceptions/
│       ├── server_exception.dart         # Base server exception
│       └── {model}_crud_exception.dart   # CRUD exceptions per model
├── external/
│   ├── datasources/
│   │   ├── interface/
│   │   │   └── datasource.dart          # Base interface for datasources
│   │   └── {model}_datasource.dart      # Implemented datasource (Firebase)
│   └── repositories/
│       └── {model}_repository.dart       # Repository implementation
└── infra/
    ├── model/
    │   └── {model}.dart                  # Your models (you create)
    └── repositories/
        └── {model}_repository_interface.dart  # Repository interface
```

## Complete Example

### Before Running the CLI

You only have the model:

```
lib/infra/model/user_model.dart
```

### After Running the CLI

The CLI automatically generates:

1. **Datasource** (`lib/external/datasources/user_model_datasource.dart`):

   - CRUD methods for Firebase Firestore
   - Firebase exception handling
2. **Repository Interface** (`lib/infra/repositories/user_model_repository_interface.dart`):

   - Interface with CRUD methods using Either pattern
3. **Repository Implementation** (`lib/external/repositories/user_model_repository.dart`):

   - Repository implementation
   - Exception to error conversion
   - Either pattern usage
4. **Exceptions** (`lib/domain/exceptions/user_model_crud_exception.dart`):

   - CreateUserModelException
   - ReadUserModelException
   - UpdateUserModelException
   - DeleteUserModelException
5. **Errors** (`lib/domain/errors/`):

   - AppError (base class)
   - CrudError and its subclasses (CreateError, ReadError, UpdateError, DeleteError)
   - ServerError

### Code Usage

```dart
import 'package:your_app/external/datasources/user_model_datasource.dart';
import 'package:your_app/external/repositories/user_model_repository.dart';
import 'package:your_app/infra/model/user_model.dart';

// Initialize
final datasource = UserModelDatasource();
final repository = UserModelRepository(datasource);

// Create
final user = UserModel(id: '1', name: 'John', email: 'john@email.com');
final result = await repository.createUserModel(user);

result.fold(
  (error) => print('Error: ${error.message}'),
  (_) => print('User created successfully!'),
);

// Read
final readResult = await repository.readUserModel('1');
readResult.fold(
  (error) => print('Error: ${error.message}'),
  (user) => print('User: ${user.name}'),
);
```

## Architecture

This CLI follows the [Clean Dart](https://github.com/Flutterando/Clean-Dart) architecture, proposed by Flutterando, which separates code into layers:

- **Domain**: Business rules, errors, and exceptions
- **Infra**: Interfaces and models
- **External**: External implementations (Firebase, APIs, etc.)

To better understand the principles and concepts behind this architecture, consult the [official Clean Dart documentation](https://github.com/Flutterando/Clean-Dart).

### Data Flow

```
UI/Presentation Layer
    ↓
Repository Interface (Infra)
    ↓
Repository Implementation (External)
    ↓
Datasource (External)
    ↓
Firebase Firestore
```

## Technical Details

### Naming Convention

- Model files must be in `snake_case` (e.g., `user_model.dart`)
- The CLI automatically converts to `PascalCase` for class names (e.g., `UserModel`)
- Firestore collections are created in plural and lowercase (e.g., `usermodels`)

### Datasource Types

The CLI supports multiple datasource types. Choose the one that fits your needs:

**1. Firestore (Default)**

- Uses Firebase Firestore for database operations
- Requires: `cloud_firestore` package
- Best for: Firebase-based projects

**2. Dio**

- Uses Dio HTTP client for REST API calls
- Requires: `dio` package
- Best for: REST API integrations with advanced features (interceptors, etc.)

**3. HTTP (Native)**

- Uses native Dart `dart:io` HttpClient
- Requires: No additional packages
- Best for: Simple HTTP requests without external dependencies

### Required Dependencies

The generated code requires the following dependencies to be added to your `pubspec.yaml`:

**Mandatory (always required):**

```yaml
dependencies:
  either_dart: ^latest_version  # Required for Either pattern in repositories
```

**Datasource-specific:**

- **Firestore**: `cloud_firestore: ^latest_version`
- **Dio**: `dio: ^latest_version`
- **HTTP**: No additional dependencies (uses dart:io)

Make sure to add the appropriate dependencies based on your chosen datasource type before running the generated code.

### CRUD Methods

Each model receives 4 complete CRUD methods:

- `create{Model}`: Creates a new document
- `read{Model}`: Reads a document by ID
- `update{Model}`: Updates an existing document
- `delete{Model}`: Deletes a document by ID

## Contributing

Contributions are welcome! Feel free to:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Author

**Jonatas Porto**

- GitHub: [@JonatasDPorto](https://github.com/JonatasDPorto)
- Pub.dev: [clean_dart_generate](https://pub.dev/packages/clean_dart_generate)
- Repository: [clean-dart-generate](https://github.com/JonatasDPorto/clean-dart-generate)

## Acknowledgments

- [Flutterando](https://github.com/Flutterando) for proposing the [Clean Dart](https://github.com/Flutterando/Clean-Dart) architecture
- Flutter community

---

If this project was useful to you, consider giving it a star on the repository!
