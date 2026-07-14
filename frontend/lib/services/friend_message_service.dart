// 친구 1:1 메시지 영구 이력 REST API. backend/Backend/Endpoints/FriendMessageEndpoints.cs를
// 따릅니다. 실시간 발신/수신 자체는 SocialHub(SendFriendMessage/FriendMessageReceived,
// social_socket_service.dart)가 맡고, 이 서비스는 화면 진입 시 지난 대화 이력을
// 불러오는 데만 씁니다 — SocialHub.SendFriendMessage가 내부적으로 이 엔드포인트와
// 같은 저장 로직(FriendMessageEndpoints.SendMessageAsync)을 공유하므로 실시간으로
// 보낸 메시지도 이 이력에 그대로 남습니다.

import 'dart:convert';
import 'api_client.dart';
import '../models/friend_message.dart';

class FriendMessagePage {
  final List<FriendMessage> messages; // 오래된 것부터 최신 순
  final bool hasMore;
  const FriendMessagePage({required this.messages, required this.hasMore});
}

class FriendMessageService {
  final ApiClient _client;

  FriendMessageService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<FriendMessagePage> getMessages(int peerUserId, {int? beforeId, int? limit}) async {
    final res = await _client.get(
      '/friends/$peerUserId/messages',
      query: {
        if (beforeId != null) 'beforeId': '$beforeId',
        if (limit != null) 'limit': '$limit',
      },
    );
    ApiClient.ensureOk(res, '메시지를 불러오지 못했습니다.');
    final json = jsonDecode(res.body);
    return FriendMessagePage(
      messages: (json['messages'] as List)
          .map((e) => FriendMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool,
    );
  }
}
