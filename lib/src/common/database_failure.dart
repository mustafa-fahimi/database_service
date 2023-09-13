import 'package:database_broker/src/common/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_failure.freezed.dart';

@freezed
class DatabaseFailure extends Failure with _$DatabaseFailure {
  const factory DatabaseFailure.nullData() = _NullData;
  const factory DatabaseFailure.emptyData() = _EmptyData;
  const factory DatabaseFailure.unknown(String message) = _Unknown;
}
