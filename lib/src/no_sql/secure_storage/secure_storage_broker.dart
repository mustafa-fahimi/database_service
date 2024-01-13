import 'package:database_broker/database_broker.dart';

abstract interface class SecureStorageBroker{
  const SecureStorageBroker();

  Future<JobDone> initialize();

  Future<JobDone> write(String key, String value);

  Future<String?> read(String key);

  Future<Map<String, String>> readAll();

  Future<JobDone> delete(String key);

  Future<JobDone> deleteAll();
}
