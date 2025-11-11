import 'dart:typed_data';

/// Abstract storage for secure secrets.
abstract class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

/// Abstract share service to support future platforms such as Windows.
abstract class ShareService {
  Future<void> sharePdf({required String fileName, required Uint8List data});
  Future<void> shareText({required String subject, required String text});
}

/// Abstract path provider to decouple from platform channels.
abstract class AppPathProvider {
  Future<String> getApplicationDocumentsPath();
  Future<String> getTemporaryPath();
}

/// Windows specific placeholder note used by services.
abstract class WindowsPendingImplementation {
  static UnsupportedError todo(String message) =>
      UnsupportedError('Windows support pending: $message');
}
