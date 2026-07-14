// 친구 목록/요청/검색과 SocialHub(프레즌스 + 1:1 채팅) 연결을 함께 관리합니다.
// friends.dart 화면은 이 컨트롤러만 구독합니다.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/player.dart';
import '../models/social_hub_event.dart';
import '../services/friend_message_service.dart';
import '../services/friend_service.dart';
import '../services/social_socket_service.dart';

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
final friendMessageServiceProvider = Provider((ref) => FriendMessageService());

final friendControllerProvider =
    StateNotifierProvider.autoDispose<FriendController, FriendsState>((ref) {
  final controller = FriendController(
    ref.read(friendServiceProvider),
    ref.read(friendMessageServiceProvider),
    ref.read(socialSocketProvider),
  );
  ref.onDispose(controller.disposeSocket);
  return controller;
});

class FriendController extends StateNotifier<FriendsState> {
  final FriendService _friendService;
  final FriendMessageService _messageService;
  final SocialSocket _socket;
  StreamSubscription<SocialHubEvent>? _sub;

  FriendController(this._friendService, this._messageService, this._socket)
      : super(const FriendsInitial());

  /// SocialHub 연결은 로그인 상태가 유지되는 동안 AuthController가 앱 전역
  /// 공유 소켓으로 상시 유지하므로, 여기서는 이미 연결된 소켓의 이벤트 구독만
  /// 맡는다 — 이 화면을 나갈 때 소켓 자체를 끊으면(disposeSocket) 다른
  /// 화면에서의 프레즌스 연결까지 끊어지므로 그렇게 하지 않는다.
  Future<void> load() async {
    state = const FriendsLoading();
    try {
      final friends = await _friendService.getFriends();
      final requests = await _friendService.getIncomingRequests();
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
            userId: fromUserId,
            nickname: fromNickname,
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
    final result = await _friendService.sendRequest(targetUserId);
    // 상대가 이미 나에게 요청을 보내둔 상태였다면 서버가 즉시 수락 처리한다 —
    // 이 경우 SocialHub 푸시는 "원래 요청을 보낸 사람"에게만 가므로(내가 아님),
    // 내 화면에서 friends 목록에 반영하려면 이 응답을 직접 써야 한다.
    if (result is FriendRequestAutoAccepted) {
      _updateLoaded((s) => s.copyWith(friends: [...s.friends, result.friend]));
    }
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
    final results = await _friendService.searchCandidates(nickname);
    _updateLoaded((s) => s.copyWith(searchResults: results));
  }

  /// 친구 대화창을 열 때 영구 저장된 이전 대화를 불러온다(GET
  /// /friends/{userId}/messages). 실시간 송수신은 SocialHub가 계속 처리하므로
  /// 여기서는 화면 진입 시 한 번 과거 이력만 채워 넣는다.
  Future<void> loadHistory(int peerUserId, {required int myUserId}) async {
    try {
      final page = await _messageService.getMessages(peerUserId);
      final messages = [
        for (final m in page.messages)
          FriendChatMessage(text: m.body, ts: m.createdAt, mine: m.senderId == myUserId),
      ];
      _updateLoaded((s) {
        final history = Map<int, List<FriendChatMessage>>.from(s.chatHistory);
        history[peerUserId] = messages;
        return s.copyWith(chatHistory: history);
      });
    } catch (_) {
      // 이력 로딩 실패는 조용히 무시한다 — 실시간 송수신 자체는 계속 동작한다.
    }
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
