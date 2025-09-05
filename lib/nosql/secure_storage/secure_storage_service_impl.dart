import 'package:database_service/database_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl();

  FlutterSecureStorage? _storage;
  bool _isInitialized = false;

  FlutterSecureStorage get _getStorage {
    if (!_isInitialized || _storage == null) {
      throw DatabaseServiceException(
        error: 'SecureStorageService not initialized. Call initialize() first.',
      );
    }
    return _storage!;
  }

  @override
  Future<JobDone> initialize() async {
    try {
      _storage = const FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        wOptions: WindowsOptions(useBackwardCompatibility: false),
      );
      _isInitialized = true;
      return const JobDone();
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to initialize secure storage: $e',
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    if (key.isEmpty) {
      throw DatabaseServiceException(error: 'Key cannot be empty');
    }
    if (value.isEmpty) {
      throw DatabaseServiceException(error: 'Value cannot be empty');
    }

    try {
      await _getStorage.write(key: key, value: value);
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to write secure data for key "$key": $e',
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    if (key.isEmpty) {
      throw DatabaseServiceException(error: 'Key cannot be empty');
    }

    try {
      final result = await _getStorage.read(key: key);
      return result;
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to read secure data for key "$key": $e',
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    if (key.isEmpty) {
      throw DatabaseServiceException(error: 'Key cannot be empty');
    }

    try {
      final result = await _getStorage.containsKey(key: key);
      return result;
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to check key existence for "$key": $e',
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      final result = await _getStorage.readAll();
      return result;
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to read all secure data: $e',
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    if (key.isEmpty) {
      throw DatabaseServiceException(error: 'Key cannot be empty');
    }

    try {
      await _getStorage.delete(key: key);
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to delete secure data for key "$key": $e',
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _getStorage.deleteAll();
    } catch (e) {
      throw DatabaseServiceException(
        error: 'Failed to delete all secure data: $e',
      );
    }
  }

  Future<void> dispose() async {
    _storage = null;
    _isInitialized = false;
  }
}
