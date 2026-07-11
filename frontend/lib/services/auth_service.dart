import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_user.dart';
import '../utils/constants.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthUser> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw AuthException(_parseError(res.body) ?? '회원가입 실패');
    }
    return AuthUser.fromJson(jsonDecode(res.body));
  }

  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 401) {
      throw AuthException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
    if (res.statusCode != 200) {
      throw AuthException(_parseError(res.body) ?? '로그인 실패');
    }
    return AuthUser.fromJson(jsonDecode(res.body));
  }

  Future<void> logOut(String accessToken) async {
    await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    // 204 No Content 응답 - 별도 파싱 없음
  }

  String? _parseError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? json['error'];
    } catch (_) {
      return null;
    }
  }
}