import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _tokenKey = 'ofc.v2.auth.token';

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) => _storage.write(
        key: _tokenKey,
        value: token,
      );

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
