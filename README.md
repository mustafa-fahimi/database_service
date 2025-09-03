# Database Service

A database broker for SQL and NoSQL databases, providing a unified interface for various database implementations including Sqflite, Drift, Hive, ObjectBox, and Secure Storage.

## Features

- **SQL Databases**: Support for Sqflite (SQLite) and Drift
- **NoSQL Databases**: Support for Hive, ObjectBox, and Flutter Secure Storage
- **Cross-Platform**: Works on Android, iOS, Windows, macOS, and Web
- **Unified Interface**: Consistent API across all database implementations

## Setup

### Web Support Setup

If you're using Sqflite on the web, you need to set up the required WebAssembly binaries and shared worker:

1. Add the dependency to your `pubspec.yaml`:
   ```yaml
   dependencies:
     sqflite_common_ffi_web: ^1.0.1+1
   ```

2. Run the setup command to install the binaries:
   ```bash
   dart run sqflite_common_ffi_web:setup
   ```

   This will create the following files in your `web` folder:
   - `sqlite3.wasm`
   - `sqflite_sw.js`

   **Note**: When SQLite3 and its WASM binary are updated, you may need to run the command again:
   ```bash
   dart run sqflite_common_ffi_web:setup --force
   ```

#### Web Platform Notes

- The database is stored in the browser's IndexedDB
- Use the same web port when debugging (different ports have separate IndexedDB instances)
- The implementation supports cross-tab synchronization when Shared Workers are available
- On browsers without Shared Worker support (like Android Chrome), a basic web worker is used

## Platform Support

| Platform | Sqflite | Drift | Hive | ObjectBox | Secure Storage |
|----------|---------|-------|------|----------|----------------|
| Android  | ✅      | ✅    | ✅   | ✅       | ✅             |
| iOS      | ✅      | ✅    | ✅   | ✅       | ✅             |
| Windows  | ✅      | ✅    | ✅   | ✅       | ❌             |
| macOS    | ✅      | ✅    | ✅   | ✅       | ❌             |
| Web      | ✅      | ❌    | ✅   | ❌       | ❌             |

## Dependencies

- `sqflite`: SQLite database for mobile
- `sqflite_common_ffi`: SQLite for desktop platforms
- `sqflite_common_ffi_web`: SQLite for web platform
- `drift`: Reactive persistence library
- `hive`: Lightweight NoSQL database
- `objectbox`: High-performance NoSQL database
- `objectbox_flutter_libs`: Flutter platform libraries for ObjectBox
- `flutter_secure_storage`: Secure storage for sensitive data
