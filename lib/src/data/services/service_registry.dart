import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/platform/platform_services.dart';

/// Global registry for platform specific implementations.
class ServiceRegistry implements SecureStorage, ShareService, AppPathProvider {
  ServiceRegistry._internal();

  static final ServiceRegistry instance = ServiceRegistry._internal();

  late final FlutterSecureStorage _secureStorage;
  bool get _isWindows => defaultTargetPlatform == TargetPlatform.windows;

  @visibleForTesting
  FlutterSecureStorage get secureStorage => _secureStorage;

  bool _initialized = false;

  /// Registers default implementations for each platform abstraction.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (_isWindows) {
      // Windows secure storage implementation pending.
      _secureStorage = const FlutterSecureStorage();
    } else {
      const androidOptions = AndroidOptions(encryptedSharedPreferences: true);
      const iosOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

      _secureStorage = const FlutterSecureStorage(
        aOptions: androidOptions,
        iOptions: iosOptions,
      );
    }

    _initialized = true;
  }

  @override
  Future<void> delete({required String key}) {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('SecureStorage.delete');
    }
    return _secureStorage.delete(key: key);
  }

  @override
  Future<String?> read({required String key}) {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('SecureStorage.read');
    }
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('SecureStorage.write');
    }
    return _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String> getApplicationDocumentsPath() async {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('AppPathProvider.getApplicationDocumentsPath');
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Future<String> getTemporaryPath() async {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('AppPathProvider.getTemporaryPath');
    }
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  @override
  Future<void> sharePdf({required String fileName, required Uint8List data}) async {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('ShareService.sharePdf');
    }
    await Share.shareXFiles(
      [XFile.fromData(data, name: fileName, mimeType: 'application/pdf')],
    );
  }

  @override
  Future<void> shareText({required String subject, required String text}) async {
    if (_isWindows) {
      throw WindowsPendingImplementation.todo('ShareService.shareText');
    }
    await Share.share(text, subject: subject);
  }
}
