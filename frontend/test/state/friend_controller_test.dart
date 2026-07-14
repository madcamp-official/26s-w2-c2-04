import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/friend.dart';
import 'package:splendor_multiplayer/models/friend_message.dart';
import 'package:splendor_multiplayer/models/friend_request.dart';
import 'package:splendor_multiplayer/models/player.dart';
import 'package:splendor_multiplayer/models/social_hub_event.dart';
import 'package:splendor_multiplayer/services/friend_message_service.dart';
import 'package:splendor_multiplayer/services/friend_service.dart';
import 'package:splendor_multiplayer/services/social_socket_service.dart';
import 'package:splendor_multiplayer/state/friend_controller.dart';

class _FakeFriendService implements FriendService {
  final List<String> calls = [];
  SendFriendRequestResult sendRequestResult = FriendRequestSent(
    FriendRequest(requestId: 999, userId: 1024, nickname: '상인', createdAt: DateTime.utc(2026, 7, 10)),
  );

  @override
  Future<List<Friend>> getFriends() async {
    calls.add('getFriends');
    return [
      const Friend(userId: 1, nickname: '루비사냥꾼', status: FriendStatus.inGame),
      const Friend(userId: 2, nickname: '도시의상인', status: FriendStatus.offline),
    ];
  }

  @override
  Future<List<FriendRequest>> getIncomingRequests() async {
    return [
      FriendRequest(
        requestId: 7788,
        userId: 3,
        nickname: '은빛상인',
        createdAt: DateTime.utc(2026, 7, 10),
      ),
    ];
  }

  @override
  Future<SendFriendRequestResult> sendRequest(int targetUserId) async {
    calls.add('sendRequest($targetUserId)');
    return sendRequestResult;
  }

  @override
  Future<Friend> acceptRequest(int requestId) async =>
      const Friend(userId: 3, nickname: '은빛상인', status: FriendStatus.online);

  @override
  Future<void> rejectRequest(int requestId) async {}

  @override
  Future<void> deleteFriend(int friendUserId) async {}

  @override
  Future<List<Player>> searchCandidates(String query) async =>
      [const Player(id: 5, nickname: '검색된유저')];
}

class _FakeFriendMessageService implements FriendMessageService {
  FriendMessagePage page = const FriendMessagePage(messages: [], hasMore: false);

  @override
  Future<FriendMessagePage> getMessages(int peerUserId, {int? beforeId, int? limit}) async => page;
}

class _FakeSocialSocket implements SocialSocket {
  final _controller = StreamController<SocialHubEvent>.broadcast();
  final List<String> calls = [];

  @override
  Stream<SocialHubEvent> get events => _controller.stream;

  @override
  Future<void> connect(String accessToken) async => calls.add('connect');

  @override
  Future<void> sendFriendMessage({required int toUserId, required String text}) async =>
      calls.add('sendFriendMessage($toUserId,$text)');

  @override
  Future<void> setPresence(String status) async {}

  @override
  Future<void> disconnect() async => calls.add('disconnect');

  @override
  Future<void> dispose() async => _controller.close();

  void emit(SocialHubEvent event) => _controller.add(event);
}

void main() {
  late _FakeFriendService friendService;
  late _FakeFriendMessageService messageService;
  late _FakeSocialSocket socket;
  late FriendController controller;

  setUp(() {
    friendService = _FakeFriendService();
    messageService = _FakeFriendMessageService();
    socket = _FakeSocialSocket();
    controller = FriendController(friendService, messageService, socket);
  });

  test('load는 친구/받은 요청 목록을 불러오고 이미 연결된 SocialHub 이벤트를 구독한다', () async {
    await controller.load();

    final state = controller.state as FriendsLoaded;
    expect(state.friends, hasLength(2));
    expect(state.incomingRequests.single.nickname, '은빛상인');
    expect(state.online.single.nickname, '루비사냥꾼');
    expect(state.offline.single.nickname, '도시의상인');
    // SocialHub 연결/해제는 AuthController 책임이라 load()는 connect를 부르지 않는다.
    expect(socket.calls, isNot(contains('connect')));
  });

  test('FriendStatusChanged 이벤트가 오면 해당 친구 상태만 바뀐다', () async {
    await controller.load();

    socket.emit(const SocialHubEvent.friendStatusChanged(
      friendUserId: 2,
      status: FriendStatus.online,
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as FriendsLoaded;
    expect(state.friends.firstWhere((f) => f.userId == 2).status, FriendStatus.online);
  });

  test('FriendMessageReceived 이벤트가 오면 해당 친구의 chatHistory에 쌓인다', () async {
    await controller.load();

    socket.emit(SocialHubEvent.friendMessageReceived(
      fromUserId: 1,
      text: '안녕!',
      ts: DateTime.utc(2026, 7, 10),
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as FriendsLoaded;
    expect(state.chatHistory[1]!.single.text, '안녕!');
    expect(state.chatHistory[1]!.single.mine, isFalse);
  });

  test('sendChatMessage는 소켓으로 보내고 로컬에도(mine=true) 남긴다', () async {
    await controller.load();

    await controller.sendChatMessage(1, '안녕하세요');

    expect(socket.calls, contains('sendFriendMessage(1,안녕하세요)'));
    final state = controller.state as FriendsLoaded;
    expect(state.chatHistory[1]!.single.mine, isTrue);
  });

  test('loadHistory는 영구 저장된 이전 대화를 불러와 chatHistory를 채운다', () async {
    await controller.load();
    messageService.page = FriendMessagePage(
      messages: [
        FriendMessage(
          messageId: 1,
          senderId: 2,
          receiverId: 1024,
          body: '지난 메시지',
          createdAt: DateTime.utc(2026, 7, 9),
        ),
      ],
      hasMore: false,
    );

    await controller.loadHistory(2, myUserId: 1024);

    final state = controller.state as FriendsLoaded;
    expect(state.chatHistory[2]!.single.text, '지난 메시지');
    expect(state.chatHistory[2]!.single.mine, isFalse);
  });

  test('acceptRequest는 요청 목록에서 지우고 friends에 추가한다', () async {
    await controller.load();
    final request = (controller.state as FriendsLoaded).incomingRequests.single;

    await controller.acceptRequest(request);

    final state = controller.state as FriendsLoaded;
    expect(state.incomingRequests, isEmpty);
    expect(state.friends.any((f) => f.userId == 3), isTrue);
  });

  test('sendFriendRequest가 즉시 수락(auto-accept)으로 응답하면 friends에 바로 반영한다', () async {
    await controller.load();
    friendService.sendRequestResult = const FriendRequestAutoAccepted(
      Friend(userId: 9, nickname: '새친구', status: FriendStatus.offline),
    );

    await controller.sendFriendRequest(9);

    final state = controller.state as FriendsLoaded;
    expect(state.friends.any((f) => f.userId == 9), isTrue);
  });
}
