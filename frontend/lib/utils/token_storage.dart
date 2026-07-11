// 로그인 성공 시 받은 AuthUser(accessToken/refreshToken 포함)를 영속 저장합니다.
// AuthState는 메모리에만 있어서 앱 재시작이나 화면 전환 사이에 토큰이 유실될 수
// 있었는데, 이 저장소를 통해 로비/플레이/리더보드 등 어느 화면에서도 토큰을
// 꺼내 쓸 수 있고, 앱 재시작 시 세션을 복원할 수 있습니다.

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_user.dart';

class TokenStorage {
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveUser(AuthUser user) {
    return _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<AuthUser?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // 저장된 값이 손상된 경우 세션 복원을 포기하고 재로그인을 유도합니다.
      await clear();
      return null;
    }
  }

  Future<String?> readAccessToken() async => (await readUser())?.accessToken;

  Future<String?> readRefreshToken() async =>
      (await readUser())?.refreshToken;

  /// ApiClient가 401을 받아 /auth/refresh로 새 accessToken을 발급받은 뒤
  /// 저장된 사용자 정보의 토큰만 갱신할 때 사용합니다.
  Future<void> updateAccessToken(String accessToken) async {
    final user = await readUser();
    if (user == null) return;
    await saveUser(user.copyWith(accessToken: accessToken));
  }

  Future<void> clear() => _storage.delete(key: _userKey);
}
