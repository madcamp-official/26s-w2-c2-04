import 'package:flutter_test/flutter_test.dart';
import 'package:splendor_multiplayer/models/gameroom.dart';
import 'package:splendor_multiplayer/models/room_list_response.dart';
import 'package:splendor_multiplayer/services/room_service.dart';
import 'package:splendor_multiplayer/state/lobby_controller.dart';

GameRoom _room(int id) => GameRoom(
      roomId: id,
      hostId: 9000,
      players: const [],
      createdAt: DateTime.utc(2026, 7, 10),
    );

class _FakeRoomService implements RoomService {
  int listCallCount = 0;

  @override
  Future<RoomListResponse> listRooms({int page = 1, int limit = 20}) async {
    listCallCount++;
    if (page == 1) {
      return RoomListResponse(
        rooms: [_room(1), _room(2)],
        total: 3,
        page: 1,
      );
    }
    return RoomListResponse(rooms: [_room(3)], total: 3, page: 2);
  }

  @override
  Future<GameRoom> createRoom({
    int maxPlayers = 4,
    bool isPrivate = false,
    String? password,
  }) async =>
      _room(99);

  @override
  Future<GameRoom> getRoom(int roomId) async => _room(roomId);

  @override
  Future<GameRoom> joinRoom(int roomId, {String? password}) async =>
      _room(roomId);

  @override
  Future<void> leaveRoom(int roomId) async {}

  @override
  Future<({int gameId, String phase})> startGame(int roomId) async =>
      (gameId: 1, phase: 'PLAYING');

  @override
  Future<void> deleteRoom(int roomId) async {}

  @override
  Future<GameRoom> rankedMatch(
    int playerCount, {
    Duration pollInterval = const Duration(seconds: 2),
    bool Function()? isCancelled,
  }) async =>
      _room(500);

  @override
  Future<void> cancelRankedMatch(int playerCount) async {}
}

void main() {
  test('loadRooms는 1페이지를 불러와 LobbyLoaded 상태로 만든다', () async {
    final controller = LobbyController(_FakeRoomService());

    await controller.loadRooms();

    final state = controller.state;
    expect(state, isA<LobbyLoaded>());
    state as LobbyLoaded;
    expect(state.rooms, hasLength(2));
    expect(state.hasMore, isTrue);
  });

  test('loadMore는 다음 페이지를 이어 붙인다(무한 스크롤)', () async {
    final controller = LobbyController(_FakeRoomService());
    await controller.loadRooms();

    await controller.loadMore();

    final state = controller.state as LobbyLoaded;
    expect(state.rooms.map((r) => r.roomId), [1, 2, 3]);
    expect(state.hasMore, isFalse);
  });

  test('createRoom 이후 목록을 다시 불러온다', () async {
    final fakeService = _FakeRoomService();
    final controller = LobbyController(fakeService);

    final room = await controller.createRoom();

    expect(room.roomId, 99);
    expect(fakeService.listCallCount, 1);
    expect(controller.state, isA<LobbyLoaded>());
  });
}
