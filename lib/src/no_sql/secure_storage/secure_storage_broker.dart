import 'package:database_broker/database_broker.dart';

abstract interface class SecureStorageBroker{
  const SecureStorageBroker();

  Future<JobDone> initialize();

  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<Map<String, String>> readAll();

  Future<void> delete(String key);

  Future<void> deleteAll();
}
