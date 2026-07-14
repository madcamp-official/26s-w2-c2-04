// 유저 프로필/전적/검색 REST API. README 2절 스펙을 따르며, 백엔드에는 아직
// 이 엔드포인트들이 없습니다(구현되면 경로/필드만 맞추면 됩니다).

import 'dart:convert';
import 'api_client.dart';
import '../models/player.dart';
import '../models/user_profile.dart';
import '../models/user_stats.dart';

class UserService {
  final ApiClient _client;

  UserService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<UserProfile> getProfile(int userId) async {
    final res = await _client.get('/users/$userId');
    ApiClient.ensureOk(res, '프로필을 불러오지 못했습니다.');
    return UserProfile.fromJson(jsonDecode(res.body));
  }

  Future<UserStats> getStats(int userId) async {
    final res = await _client.get('/users/$userId/stats');
    ApiClient.ensureOk(res, '전적을 불러오지 못했습니다.');
    return UserStats.fromJson(jsonDecode(res.body));
  }

  Future<UserProfile> updateMe({String? nickname, String? avatarUrl}) async {
    final res = await _client.patch(
      '/users/me',
      body: {
        if (nickname != null) 'nickname': nickname,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    ApiClient.ensureOk(res, '프로필 수정에 실패했습니다.');
    return UserProfile.fromJson(jsonDecode(res.body));
  }

  Future<List<Player>> search(String nickname) async {
    final res = await _client.get('/users/search', query: {'nickname': nickname});
    ApiClient.ensureOk(res, '유저 검색에 실패했습니다.');
    final json = jsonDecode(res.body);
    return (json['users'] as List)
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
