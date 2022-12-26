import 'dart:convert';

import 'package:database_service/src/errors/database_exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseSecurity {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _secureKey = 's_key';

  /// Generate an encryption key for AES data encryption
  Future<void> generateAndSaveSecureKeyIfNotExist() async =>
      _secureStorage.read(key: _secureKey).then(
        (secureStorageKey) async {
          /// If we didn't generate encryption key before, then generate it
          if (secureStorageKey == null) {
            final key = Hive.generateSecureKey();
            await _secureStorage.write(
              iOptions: const IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              mOptions: const MacOsOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              key: _secureKey,
              value: base64UrlEncode(key),
            );
          }
        },
      ).catchError((_) {});

  /// Delete the encryption key from secure storage
  Future<void> deleteSecureKey() async =>
      _secureStorage.delete(key: _secureKey).catchError((_) {});

  /// Retrive the encryption key from secure storage
  Future<HiveCipher?> readEncryptionCipher() async => _secureStorage
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
          return null;
        }
      }).catchError(
        (dynamic e) => throw DatabaseException(message: e.toString()),
      );
}
