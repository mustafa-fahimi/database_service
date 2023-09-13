import 'package:database_broker/src/common/job_done.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class NoSqlBroker {
  const NoSqlBroker();

  /// Initializes the database.
  Future<JobDone> initializeDatabase();

  /// Closes the database.
  Future<JobDone> closeDatabase();

  /// Opens a box with the given [boxName] and returns a [Box] instance.
  ///
  /// The [boxName] parameter is a non-null [String] that represents
  /// the name of the box to be opened.
  ///
  /// Returns a [Future] that completes with a [Box] instance.
  Future<Box<dynamic>> openBox(String boxName);

  /// Closes the box with the given [boxName].
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> closeBox(String boxName);

  /// Writes a value to the specified box with the given key.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> write(String boxName, String key, dynamic value);

  /// Writes multiple entries to the specified box in the NoSQL database.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  ///
  /// The [boxName] parameter specifies the name of the box to write to.
  ///
  /// The [enteries] parameter is a map of key-value pairs to write to the box.
  Future<JobDone> writeMultiple(
    String boxName,
    Map<dynamic, dynamic> enteries,
  );

  /// Reads the value associated with the given [key] from the box
  /// with the given [boxName].
  ///
  /// If the key is not found in the box, [defaultValue] is returned.
  Future<dynamic> read(
    String boxName,
    String key, {
    dynamic defaultValue,
  });

  /// Updates the value of a key in the specified box.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  ///
  /// The [boxName] parameter specifies the name of the box to update the key.
  ///
  /// The [key] parameter specifies the key to update.
  ///
  /// The [value] parameter specifies the new value to set for the key.
  Future<JobDone> update(
    String boxName,
    String key,
    dynamic value,
  );

  /// Adds or updates a value in the specified box with the given key.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> addOrUpdate(
    String boxName,
    String key,
    dynamic value,
  );

  /// Deletes the value associated with the given [key] in the box
  /// with the given [boxName].
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> delete(String boxName, String key);

  /// Deletes multiple entries from the specified box in the database.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  ///
  /// The [boxName] parameter specifies the name of the box from which
  /// entries are to be deleted.
  ///
  /// The [keys] parameter is an iterable of keys of the entries to be deleted.
  Future<JobDone> deleteMultiple(String boxName, Iterable<dynamic> keys);

  /// Clears all the key-value pairs in the box with the given [boxName].
  /// Returns the number of key-value pairs that were cleared.
  Future<int> clearBox(String boxName);

  /// Deletes a box with the given [boxName] from the disk.
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> deleteBoxFromDisk(String boxName);

  /// Deletes the database from the disk.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> deleteDatabaseFromDisk();

  /// Returns a Future that completes with a boolean indicating whether
  /// the given [boxName] has the given [key].
  Future<bool> hasProperty(String boxName, String key);

  /// Registers a [TypeAdapter] for a specific type [T] with the NoSQL broker.
  ///
  /// If [override] is `true`, any previously registered adapter for
  /// the same type will be replaced with the new adapter. Otherwise, an
  /// exception will be thrown if an adapter for the same type has already
  /// been registered.
  ///
  /// Returns a [Future] that completes with a [JobDone] object.
  Future<JobDone> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  });
}
