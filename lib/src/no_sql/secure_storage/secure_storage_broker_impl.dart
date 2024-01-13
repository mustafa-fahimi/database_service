import 'package:database_broker/database_broker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageBrokerImpl implements SecureStorageBroker {
  SecureStorageBrokerImpl();

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
      throw DatabaseBrokerException(error: e);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
    } catch (e) {
      throw DatabaseBrokerException(error: e);
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      throw DatabaseBrokerException(error: e);
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await storage.readAll();
    } catch (e) {
      throw DatabaseBrokerException(error: e);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await storage.delete(key: key);
    } catch (e) {
      throw DatabaseBrokerException(error: e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      throw DatabaseBrokerException(error: e);
    }
  }
}