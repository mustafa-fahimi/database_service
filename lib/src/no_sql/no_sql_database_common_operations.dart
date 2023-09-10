import 'package:dartz/dartz.dart';
import 'package:database_broker/src/common/database_failure.dart';
import 'package:database_broker/src/common/no_param.dart';
import 'package:database_broker/src/no_sql/no_sql_database_broker.dart';

/// This class includes common functionality of db service with error handling
class NoSqlDatabaseCommonOperations<R> {
  NoSqlDatabaseCommonOperations({
    required this.boxName,
    required this.databaseService,
  });
  final String boxName;
  final NoSqlDatabaseBroker databaseService;

  /// This method save data with the type [R] to the database service.
  /// If some data is already in the database then it will override data.
  Future<Either<DatabaseFailure, NoParam>> cacheData({
    required String fieldKey,
    required R value,
  }) async =>
      databaseService.addOrUpdate(boxName, fieldKey, value).then(
            (res) => res.fold(
              (dbError) => left<DatabaseFailure, NoParam>(
                dbError,
              ),
              (response) => right<DatabaseFailure, NoParam>(
                const NoParam(),
              ),
            ),
          );

  /// Retrive the data from the database.
  Future<Either<DatabaseFailure, R?>> getCachedData({
    required String fieldKey,
  }) async =>
      databaseService
          .read(boxName, fieldKey)
          .then(
            (res) => res.fold(
              (dbError) => left<DatabaseFailure, R?>(
                dbError,
              ),
              (response) => right<DatabaseFailure, R?>(
                response as R?,
              ),
            ),
          )
          .catchError(
            (dynamic e) => left<DatabaseFailure, R?>(
              DatabaseFailure(message: e.toString()),
            ),
          );
}
