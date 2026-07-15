// 유저 프로필 REST API. backend/Backend/Endpoints/ProfileEndpoints.cs를 그대로
// 따릅니다. 닉네임 변경/아바타 업로드 엔드포인트는 각각 없음(닉네임)/별도 범위
// (아바타, 멀티파트 업로드)라 여기서는 조회만 다룹니다.

import 'dart:convert';
import 'api_client.dart';
import '../models/user_profile.dart';

class UserService {
  final ApiClient _client;

  UserService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<UserProfile> getMyProfile() async {
    final res = await _client.get('/profile/me');
    ApiClient.ensureOk(res, '프로필을 불러오지 못했습니다.');
    return UserProfile.fromJson(jsonDecode(res.body));
  }

  Future<UserProfile> getProfile(int userId) async {
    final res = await _client.get('/profile/$userId');
    ApiClient.ensureOk(res, '프로필을 불러오지 못했습니다.');
    return UserProfile.fromJson(jsonDecode(res.body));
  }
}
