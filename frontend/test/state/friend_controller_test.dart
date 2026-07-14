import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/friend.dart';
import 'package:splendor_multiplayer/models/friend_request.dart';
import 'package:splendor_multiplayer/models/player.dart';
import 'package:splendor_multiplayer/models/social_hub_event.dart';
import 'package:splendor_multiplayer/services/friend_service.dart';
import 'package:splendor_multiplayer/services/social_socket_service.dart';
import 'package:splendor_multiplayer/services/user_service.dart';
import 'package:splendor_multiplayer/state/friend_controller.dart';

class _FakeFriendService implements FriendService {
  final List<String> calls = [];

  @override
  Future<List<Friend>> getFriends({FriendStatus? status}) async {
    calls.add('getFriends');
    return [
      const Friend(userId: 1, nickname: '루비사냥꾼', status: FriendStatus.inGame),
      const Friend(userId: 2, nickname: '도시의상인', status: FriendStatus.offline),
    ];
  }

  @override
  Future<List<FriendRequest>> getRequests({String direction = 'incoming'}) async {
    return [
      FriendRequest(
        requestId: 7788,
        fromUserId: 3,
        fromNickname: '은빛상인',
        createdAt: DateTime.utc(2026, 7, 10),
      ),
    ];
  }

  @override
  Future<FriendRequest> sendRequest(int targetUserId) async {
    calls.add('sendRequest($targetUserId)');
    return FriendRequest(
      requestId: 999,
      fromUserId: 1024,
      createdAt: DateTime.utc(2026, 7, 10),
    );
  }

  @override
  Future<Friend> acceptRequest(int requestId) async =>
      const Friend(userId: 3, nickname: '은빛상인', status: FriendStatus.online);

  @override
  Future<void> rejectRequest(int requestId) async {}

  @override
  Future<void> deleteFriend(int friendUserId) async {}
}

class _FakeUserService implements UserService {
  @override
  Future<List<Player>> search(String nickname) async =>
      [const Player(id: 5, nickname: '검색된유저')];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  Future<void> dispose() async => _controller.close();

  void emit(SocialHubEvent event) => _controller.add(event);
}

void main() {
  late _FakeFriendService friendService;
  late _FakeSocialSocket socket;
  late FriendController controller;

  setUp(() {
    friendService = _FakeFriendService();
    socket = _FakeSocialSocket();
    controller = FriendController(friendService, _FakeUserService(), socket);
  });

  test('load는 친구/요청 목록을 불러오고 SocialHub에 연결한다', () async {
    await controller.load(accessToken: 'token');

    final state = controller.state as FriendsLoaded;
    expect(state.friends, hasLength(2));
    expect(state.incomingRequests.single.fromNickname, '은빛상인');
    expect(state.online.single.nickname, '루비사냥꾼');
    expect(state.offline.single.nickname, '도시의상인');
    expect(socket.calls, contains('connect'));
  });

  test('FriendStatusChanged 이벤트가 오면 해당 친구 상태만 바뀐다', () async {
    await controller.load(accessToken: 'token');

    socket.emit(const SocialHubEvent.friendStatusChanged(
      friendUserId: 2,
      status: FriendStatus.online,
    ));
    await Future<void>.delayed(Duration.zero);

    final state = controller.state as FriendsLoaded;
    expect(state.friends.firstWhere((f) => f.userId == 2).status, FriendStatus.online);
  });

  test('FriendMessageReceived 이벤트가 오면 해당 친구의 chatHistory에 쌓인다', () async {
    await controller.load(accessToken: 'token');

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
    await controller.load(accessToken: 'token');

    await controller.sendChatMessage(1, '안녕하세요');

    expect(socket.calls, contains('sendFriendMessage(1,안녕하세요)'));
    final state = controller.state as FriendsLoaded;
    expect(state.chatHistory[1]!.single.mine, isTrue);
  });

  test('acceptRequest는 요청 목록에서 지우고 friends에 추가한다', () async {
    await controller.load(accessToken: 'token');
    final request = (controller.state as FriendsLoaded).incomingRequests.single;

    await controller.acceptRequest(request);

    final state = controller.state as FriendsLoaded;
    expect(state.incomingRequests, isEmpty);
    expect(state.friends.any((f) => f.userId == 3), isTrue);
  });
}
