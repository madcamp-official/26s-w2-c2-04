// 방/유저/친구/리더보드 등 인증이 필요한 REST API 공용 클라이언트.
// Authorization 헤더를 자동으로 붙이고, 401을 받으면 /auth/refresh로 한 번
// 재발급을 시도한 뒤 재요청합니다. room_service/leaderboard_service/play_service가
// 공유해서 쓰며, 각자 헤더를 만들 때 생기는 토큰 누락/중복 코드를 없앱니다.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;
  final AuthService _authService;

  ApiClient({
    http.Client? client,
    TokenStorage? tokenStorage,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _authService = authService ?? AuthService();

  Future<http.Response> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<http.Response> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<http.Response> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<http.Response> delete(String path) => _send('DELETE', path);

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool isRetry = false,
  }) async {
    final accessToken = await _tokenStorage.readAccessToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final encodedBody = body == null ? null : jsonEncode(body);

    final res = await switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'POST' => _client.post(uri, headers: headers, body: encodedBody),
      'PATCH' => _client.patch(uri, headers: headers, body: encodedBody),
      'DELETE' => _client.delete(uri, headers: headers),
      _ => throw ArgumentError('지원하지 않는 HTTP method: $method'),
    };

    if (res.statusCode == 401 && !isRetry && await _tryRefresh()) {
      return _send(method, path, query: query, body: body, isRetry: true);
    }
    return res;
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return false;
    try {
      final result = await _authService.refresh(refreshToken);
      await _tokenStorage.updateAccessToken(result.accessToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 2xx가 아니면 서버 에러 메시지를 담아 ApiException을 던집니다.
  static void ensureOk(http.Response res, [String? fallbackMessage]) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String? message;
    try {
      final json = jsonDecode(res.body);
      message = json['message'] ?? json['error'] ?? json['code'];
    } catch (_) {
      // 본문이 JSON이 아니거나(204 등) 비어있는 경우 무시
    }
    throw ApiException(res.statusCode, message ?? fallbackMessage ?? '요청 실패');
  }
}
