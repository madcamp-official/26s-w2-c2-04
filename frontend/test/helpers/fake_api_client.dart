// room_service/leaderboard_service/play_service 테스트에서 공유하는 가짜 ApiClient.
// 실제 ApiClient는 TokenStorage(flutter_secure_storage)와 AuthService(http)를 감싸고
// 있어서 순수 단위 테스트에서 플랫폼 채널을 타지 않도록, HTTP 메서드 4개만
// 오버라이드해서 미리 준비한 응답을 돌려줍니다.

import 'package:http/http.dart' as http;
import 'package:splendor_multiplayer/services/api_client.dart';

typedef FakeRequestHandler = http.Response Function(
  String method,
  String path, {
  Map<String, String>? query,
  Object? body,
});

class FakeApiClient extends ApiClient {
  final FakeRequestHandler handler;
  FakeApiClient(this.handler);

  @override
  Future<http.Response> get(String path, {Map<String, String>? query}) async =>
      handler('GET', path, query: query);

  @override
  Future<http.Response> post(String path, {Object? body}) async =>
      handler('POST', path, body: body);

  @override
  Future<http.Response> patch(String path, {Object? body}) async =>
      handler('PATCH', path, body: body);

  @override
  Future<http.Response> delete(String path) async => handler('DELETE', path);
}
