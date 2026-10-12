import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const key = 'unisecure_access_token';
  final storage = const FlutterSecureStorage();
  Future<String?> read() => storage.read(key: key);
  Future<void> write(String value) => storage.write(key: key, value: value);
  Future<void> clear() => storage.delete(key: key);
}
