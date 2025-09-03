import 'package:database_service/database_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl();

  late FlutterSecureStorage storage;

  @override
  Future<JobDone> initialize() async {
    try {
      storage = const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );
      return const JobDone();
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      final result = await storage.read(key: key);
      return result;
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      final result = await storage.readAll();
      return result;
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await storage.delete(key: key);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }
}
