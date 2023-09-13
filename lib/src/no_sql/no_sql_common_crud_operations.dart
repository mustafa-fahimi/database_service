import 'package:dartz/dartz.dart';
import 'package:database_broker/src/common/database_failure.dart';
import 'package:database_broker/src/common/just_ok.dart';
import 'package:database_broker/src/no_sql/broker/no_sql_broker.dart';

/// This class includes common functionality of db service with error handling
class NoSqlCommonCrudOperations<R> {
  NoSqlCommonCrudOperations({
    required this.boxName,
    required this.databaseService,
  });
  final String boxName;
  final NoSqlBroker databaseService;

  /// This method save data with the type [R] to the database service.
  /// If some data is already in the database then it will override data.
  Future<Either<DatabaseFailure, JustOk>> cacheData({
    required String fieldKey,
    required R value,
  }) async =>
      databaseService.addOrUpdate(
        boxName,
        fieldKey,
        value,
      );

  /// Retrive the data from the database.
  Future<Either<DatabaseFailure, R?>> getCachedData({
    required String fieldKey,
  }) async =>
      databaseService.read(boxName, fieldKey).then(
            (res) => res.fold(
              (dbError) => left<DatabaseFailure, R?>(
                dbError,
              ),
              (response) => right<DatabaseFailure, R?>(
                response as R?,
              ),
            ),
          );
}
