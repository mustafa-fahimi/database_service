import 'dart:convert';

import 'package:database_broker/src/no_sql/errors/secure_key_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NoSqlDatabaseSecurity {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _secureKey = 'tokenizer';

  /// Generate an encryption key for AES data encryption
  Future<void> generateAndSaveSecureKeyIfNotExist() async =>
      _secureStorage.read(key: _secureKey).then(
        (secureStorageKey) async {
          /// If we didn't generate encryption key before, then generate it
          if (secureStorageKey == null) await _writeSecureKey();
        },
      ).catchError(
        (dynamic e) => throw SecureKeyException(
          action: SecureKeyActions.read,
          error: e.toString(),
        ),
      );

  List<int> _generateNewSecureKey() => Hive.generateSecureKey();

  Future<void> _writeSecureKey() async {
    try {
      await _secureStorage.write(
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        mOptions: const MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        key: _secureKey,
        value: base64UrlEncode(_generateNewSecureKey()),
      );
    } catch (e) {
      throw SecureKeyException(
        action: SecureKeyActions.write,
        error: e.toString(),
      );
    }
  }

  /// Delete the encryption key from secure storage
  Future<void> deleteSecureKey() async =>
      _secureStorage.delete(key: _secureKey).catchError(
            (dynamic e) => throw SecureKeyException(
              action: SecureKeyActions.delete,
              error: e.toString(),
            ),
          );

  /// Retrive the encryption key from secure storage
  Future<HiveCipher> readEncryptionCipher() async => _secureStorage
          .read(
        key: _secureKey,
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        mOptions: const MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      )
          .then((secureStorageKey) {
        if (secureStorageKey != null) {
          final encryptionKey = base64Url.decode(secureStorageKey);
          return HiveAesCipher(encryptionKey);
        } else {
          return throw const SecureKeyException(
            action: SecureKeyActions.read,
            error: 'Secure key is null',
          );
        }
      }).catchError(
        (dynamic e) => throw SecureKeyException(
          action: SecureKeyActions.read,
          error: e.toString(),
        ),
      );
}
