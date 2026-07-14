// 방 목록 조회/생성/참가/퇴장 상태를 관리합니다. lobby.dart 화면은 이 컨트롤러만
// 구독하고, RoomService(REST) 호출은 여기서만 이뤄집니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gameroom.dart';
import '../services/room_service.dart';

sealed class LobbyState {
  const LobbyState();
}

class LobbyInitial extends LobbyState {
  const LobbyInitial();
}

class LobbyLoading extends LobbyState {
  const LobbyLoading();
}

class LobbyLoaded extends LobbyState {
  final List<GameRoom> rooms;
  final int page;
  final int total;
  final bool hasMore;
  const LobbyLoaded({
    required this.rooms,
    required this.page,
    required this.total,
    required this.hasMore,
  });
}

class LobbyError extends LobbyState {
  final String message;
  const LobbyError(this.message);
}

final roomServiceProvider = Provider((ref) => RoomService());

final lobbyControllerProvider =
    StateNotifierProvider<LobbyController, LobbyState>((ref) {
  return LobbyController(ref.read(roomServiceProvider));
});

class LobbyController extends StateNotifier<LobbyState> {
  static const _pageLimit = 20;

  final RoomService _roomService;
  LobbyController(this._roomService) : super(const LobbyInitial());

  Future<void> loadRooms() async {
    state = const LobbyLoading();
    try {
      final res = await _roomService.listRooms(page: 1, limit: _pageLimit);
      state = LobbyLoaded(
        rooms: res.rooms,
        page: res.page,
        total: res.total,
        hasMore: res.rooms.length < res.total,
      );
    } catch (e) {
      state = LobbyError(e.toString());
    }
  }

  /// 무한 스크롤: 다음 page를 불러와 기존 목록 뒤에 이어 붙입니다.
  Future<void> loadMore() async {
    final current = state;
    if (current is! LobbyLoaded || !current.hasMore) return;

    try {
      final nextPage = current.page + 1;
      final res =
          await _roomService.listRooms(page: nextPage, limit: _pageLimit);
      final merged = [...current.rooms, ...res.rooms];
      state = LobbyLoaded(
        rooms: merged,
        page: res.page,
        total: res.total,
        hasMore: merged.length < res.total,
      );
    } catch (e) {
      state = LobbyError(e.toString());
    }
  }

  Future<GameRoom> createRoom({
    int maxPlayers = 4,
    bool isPrivate = false,
    String? password,
  }) async {
    final room = await _roomService.createRoom(
      maxPlayers: maxPlayers,
      isPrivate: isPrivate,
      password: password,
    );
    await loadRooms();
    return room;
  }

  Future<GameRoom> joinRoom(int roomId, {String? password}) {
    return _roomService.joinRoom(roomId, password: password);
  }

  Future<void> leaveRoom(int roomId) {
    return _roomService.leaveRoom(roomId);
  }
}
