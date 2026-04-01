import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'access_token';
  static const _keyRole = 'user_role';
  static const _keyUserId = 'user_id';

  static Future<void> saveToken(String token) async =>
      await _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: _keyToken);

  static Future<void> saveRole(String role) async =>
      await _storage.write(key: _keyRole, value: role);

  static Future<String?> getRole() async =>
      await _storage.read(key: _keyRole);

  static Future<void> saveUserId(String userId) async =>
      await _storage.write(key: _keyUserId, value: userId);

  static Future<String?> getUserId() async =>
      await _storage.read(key: _keyUserId);

  static Future<void> saveAll({
    required String token,
    required String role,
    required String userId,
  }) async {
    await Future.wait([
      saveToken(token),
      saveRole(role),
      saveUserId(userId),
    ]);
  }

  static Future<void> clear() async => await _storage.deleteAll();
}