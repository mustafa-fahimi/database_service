import 'package:dartz/dartz.dart';
import 'package:database_service/src/database_service.dart';
import 'package:database_service/src/errors/database_failure.dart';
import 'package:database_service/src/no_param.dart';

/// This class includes common functionality of db service with error handling
class DatabaseCommonOperations<R> {
  DatabaseCommonOperations({
    required this.boxName,
    required this.databaseService,
  });
  final String boxName;
  final DatabaseService databaseService;

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
