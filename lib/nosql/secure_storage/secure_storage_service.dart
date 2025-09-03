
import 'package:database_service/database_service.dart';

abstract interface class SecureStorageService {
  const SecureStorageService();

  Future<JobDone> initialize();

  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<Map<String, String>> readAll();

  Future<void> delete(String key);

  Future<void> deleteAll();
}
