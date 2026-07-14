// 친구 목록/요청/검색과 SocialHub(프레즌스 + 1:1 채팅) 연결을 함께 관리합니다.
// friends.dart 화면은 이 컨트롤러만 구독합니다.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/player.dart';
import '../models/social_hub_event.dart';
import '../services/friend_service.dart';
import '../services/social_socket_service.dart';
import '../services/user_service.dart';
import 'profile_controller.dart' show userServiceProvider;

class FriendChatMessage {
  final String text;
  final DateTime ts;
  final bool mine;
  const FriendChatMessage({required this.text, required this.ts, required this.mine});
}

sealed class FriendsState {
  const FriendsState();
}

class FriendsInitial extends FriendsState {
  const FriendsInitial();
}

class FriendsLoading extends FriendsState {
  const FriendsLoading();
}

class FriendsLoaded extends FriendsState {
  final List<Friend> friends;
  final List<FriendRequest> incomingRequests;
  final Map<int, List<FriendChatMessage>> chatHistory;
  final List<Player> searchResults;

  const FriendsLoaded({
    required this.friends,
    required this.incomingRequests,
    this.chatHistory = const {},
    this.searchResults = const [],
  });

  List<Friend> get online =>
      friends.where((f) => f.status != FriendStatus.offline).toList();
  List<Friend> get offline =>
      friends.where((f) => f.status == FriendStatus.offline).toList();

  FriendsLoaded copyWith({
    List<Friend>? friends,
    List<FriendRequest>? incomingRequests,
    Map<int, List<FriendChatMessage>>? chatHistory,
    List<Player>? searchResults,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      chatHistory: chatHistory ?? this.chatHistory,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}

class FriendsError extends FriendsState {
  final String message;
  const FriendsError(this.message);
}

final friendServiceProvider = Provider((ref) => FriendService());

final friendControllerProvider =
    StateNotifierProvider.autoDispose<FriendController, FriendsState>((ref) {
  final controller = FriendController(
    ref.read(friendServiceProvider),
    ref.read(userServiceProvider),
    ref.read(socialSocketProvider),
  );
  ref.onDispose(controller.disposeSocket);
  return controller;
});

class FriendController extends StateNotifier<FriendsState> {
  final FriendService _friendService;
  final UserService _userService;
  final SocialSocket _socket;
  StreamSubscription<SocialHubEvent>? _sub;

  FriendController(this._friendService, this._userService, this._socket)
      : super(const FriendsInitial());

  /// SocialHub 연결은 로그인 상태가 유지되는 동안 AuthController가 앱 전역
  /// 공유 소켓으로 상시 유지하므로, 여기서는 이미 연결된 소켓의 이벤트 구독만
  /// 맡는다 — 이 화면을 나갈 때 소켓 자체를 끊으면(disposeSocket) 다른
  /// 화면에서의 프레즌스 연결까지 끊어지므로 그렇게 하지 않는다.
  Future<void> load() async {
    state = const FriendsLoading();
    try {
      final friends = await _friendService.getFriends();
      final requests = await _friendService.getRequests();
      state = FriendsLoaded(friends: friends, incomingRequests: requests);

      _sub?.cancel();
      _sub = _socket.events.listen(_onEvent);
    } catch (e) {
      state = FriendsError(e.toString());
    }
  }

  void _onEvent(SocialHubEvent event) {
    event.when(
      friendRequestReceived: (requestId, fromUserId, fromNickname) => _updateLoaded(
        (s) => s.copyWith(incomingRequests: [
          ...s.incomingRequests,
          FriendRequest(
            requestId: requestId,
            fromUserId: fromUserId,
            fromNickname: fromNickname,
            createdAt: DateTime.now(),
          ),
        ]),
      ),
      friendRequestAccepted: (friendUserId, friendNickname) => _updateLoaded(
        (s) => s.copyWith(friends: [
          ...s.friends,
          Friend(userId: friendUserId, nickname: friendNickname, status: FriendStatus.online),
        ]),
      ),
      friendStatusChanged: (friendUserId, status) => _updateLoaded(
        (s) => s.copyWith(
          friends: [
            for (final f in s.friends)
              if (f.userId == friendUserId) f.copyWith(status: status) else f,
          ],
        ),
      ),
      friendMessageReceived: (fromUserId, text, ts) => _appendMessage(
        fromUserId,
        FriendChatMessage(text: text, ts: ts, mine: false),
      ),
    );
  }

  Future<void> sendFriendRequest(int targetUserId) async {
    await _friendService.sendRequest(targetUserId);
  }

  Future<void> acceptRequest(FriendRequest request) async {
    final friend = await _friendService.acceptRequest(request.requestId);
    _updateLoaded((s) => s.copyWith(
          friends: [...s.friends, friend],
          incomingRequests:
              s.incomingRequests.where((r) => r.requestId != request.requestId).toList(),
        ));
  }

  Future<void> rejectRequest(FriendRequest request) async {
    await _friendService.rejectRequest(request.requestId);
    _updateLoaded((s) => s.copyWith(
          incomingRequests:
              s.incomingRequests.where((r) => r.requestId != request.requestId).toList(),
        ));
  }

  Future<void> deleteFriend(int friendUserId) async {
    await _friendService.deleteFriend(friendUserId);
    _updateLoaded((s) => s.copyWith(
          friends: s.friends.where((f) => f.userId != friendUserId).toList(),
        ));
  }

  Future<void> searchUsers(String nickname) async {
    if (nickname.trim().isEmpty) {
      _updateLoaded((s) => s.copyWith(searchResults: []));
      return;
    }
    final results = await _userService.search(nickname);
    _updateLoaded((s) => s.copyWith(searchResults: results));
  }

  Future<void> sendChatMessage(int toUserId, String text) async {
    await _socket.sendFriendMessage(toUserId: toUserId, text: text);
    _appendMessage(toUserId, FriendChatMessage(text: text, ts: DateTime.now(), mine: true));
  }

  void _appendMessage(int peerUserId, FriendChatMessage message) {
    _updateLoaded((s) {
      final history = Map<int, List<FriendChatMessage>>.from(s.chatHistory);
      history[peerUserId] = [...(history[peerUserId] ?? const []), message];
      return s.copyWith(chatHistory: history);
    });
  }

  void _updateLoaded(FriendsLoaded Function(FriendsLoaded) update) {
    final current = state;
    if (current is! FriendsLoaded) return;
    state = update(current);
  }

  /// 공유 소켓 자체는 AuthController가 로그인/로그아웃에 맞춰 관리하므로,
  /// 이 화면을 나갈 때는 로컬 이벤트 구독만 취소한다(소켓 dispose는 하지 않음).
  Future<void> disposeSocket() async {
    await _sub?.cancel();
  }
}
